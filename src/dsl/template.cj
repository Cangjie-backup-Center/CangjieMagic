/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.{ArrayList, map, collectArray}
import std.regex.{Regex, MatchData}

private class TemplateAttr <: Attr {
    TemplateAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    prop path: Option<String> {
        get() {
            getLiteral("path")
        }
    }

    prop prefix: Option<String> {
        get() {
            getLiteral("prefix")
        }
    }

    prop compile: Bool {
        get() {
            getBool("compile", default: true)
        }
    }

    static func parse(attrTokens: Tokens): TemplateAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "template",
            validKeys: ["prefix", "path", "compile", "dump"]
        )
        return TemplateAttr(map)
    }
}

/**
 * This macro is used to define a template.
 * Its function body has a single string literal that is the template content.
 */
public macro template(input: Tokens): Tokens {
    let attr = TemplateAttr()
    return transformTemplate(input, attr)
}

public macro template(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = TemplateAttr.parse(attrTokens)
    let content = transformTemplate(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform the function as a render of a template.
 * @template
 * func foo(<args>) { <body> }
 * AS
 * func foo(<args>) {
 *   let engine = TemplateEngine()
 *   engine.set("<arg0>", <arg0>)
 *   engine.set("<arg1>", <arg1>)
 *   ...
 *   return engine.render(<body>)
 * }
 */
private func transformTemplate(input: Tokens, attr: TemplateAttr): Tokens {
    let decl = parseDecl(input)
    if (!decl.isFuncDecl()) {
        throw DslException("@template should be called on function declarations")
    }
    let funcDecl = decl.asFuncDecl()
    let modifier = funcDecl.modifiers
    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)
    let args: Tokens = joinTokens(
        getFuncParamNames(funcDecl) |>
            map { name: String => newIdentifierToken(name) } |>
            collectArray,
        Token(TokenKind.COMMA)
    )

    let prefix = attr.prefix ?? ""
    let template = if (let Some(path) <- attr.path) {
        if (!exists(path)) {
            throw DslException("`include` refers to non-existing file: ${path}")
        }
        escapeStringForTemplate(readFile(path))
    } else {
        let body = funcDecl.block.nodes[0]
        if (funcDecl.block.nodes.size != 1 || !body.isStringLiteral()) {
            throw DslException("@template should have a single string literal as the body")
        }
        body.asLitConstExpr().literal.value
    }

    let retType = checkFuncRetString(funcDecl)
    // When compile is true, we compile the template into a function body
    // Otherwise, we use the TemplateEngine to render the template during execution
    if (attr.compile) {
        let body = TemplateCompiler().compile(prefix + template)
        return quote(
            $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
                let sb = StringBuilder()
                $body
                return sb.toString()
            }
        )
    } else {
        let initContext = Tokens()
        for (name in getFuncParamNames(funcDecl)) {
            initContext.append(quote(
                engine.set($(newLiteralToken(name)), $(newIdentifierToken(name)))
            ))
        }
        return quote(
            $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
                let engine = TemplateEngine()
                $initContext
                return engine.render($(newMultilineStringLiteralToken(prefix + template)))
            }
        )
    }
}

private func escapeStringForTemplate(input: String): String {
    // Escape `${` to `\${` to prevent it from being interpreted as a variable in the template engine
    return input.replace("\${", "\\\${")
}

class TemplateCompiler {
    private static const ESCAPED_NEWLINE = "#^#"

    public func compile(template: String): Tokens {
        // Since the regex does not support DOTALL, we replace all newlines with a special symbol
        let template2 = template.replace("\n", ESCAPED_NEWLINE)
        return this.compileLoops(template2)
    }

    private func compileLoops(template: String): Tokens {
        // Regex to match loops in the format "{for item in <expr>}...{/for}"
        // <expr> allows identifiers, member access, array access, and map access
        let regex = Regex("{%\\s*for\\s+(\\w+)\\s+in\\s+([\\w\\d\\.\\[\\]\"']+)\\s*%}(.*?){%\\s*/for\\s*%}")
        let matcher = regex.matcher(template)
        // Split "...{for ...}xxx{/for}...{for ...}xxx{/for}..."
        let subStrings = matcher.split()
        // And find all variables
        let loops: Array<MatchData> = matcher.findAll() ?? []
        if (subStrings.size != loops.size + 1) {
            throw DslException("Template format error: the number of loops does not match the number of substrings")
        }
        // Compile loop content and construct the final string
        let tokens = Tokens()
        tokens.append(this.compileExprs(subStrings[0]))
        for (i in 0..loops.size) {
            tokens.append(this.compileLoop(loops[i]))
            tokens.append(this.compileExprs(subStrings[i+1]))
        }
        // Replace the special symbol with newlines
        return tokens
    }

    private func compileLoop(loop: MatchData): Tokens {
        let itemVar = newIdentifierToken(loop.matchStr(1))
        let array = this.parseExpr(loop.matchStr(2))
        let loopBody = this.compileLoops(loop.matchStr(3))
        return quote(
            for ($itemVar in $array) {
                $loopBody
            }
        )
    }

    private func compileExprs(template: String): Tokens {
        // Regex to match placeholder expressions in the format
        // like "{% expr %}"
        let regex = Regex("{%\\s*(.+?)\\s*%}")
        let matcher = regex.matcher(template)
        // Split "... {expr1}...{expr2}...{exprN}..."
        let subStrings = matcher.split() |>
            map { s => s.replace(ESCAPED_NEWLINE, "\n") } |> // Recover ESCAPED_NEWLINE
            collectArray
        // And find all expressions
        let exprs = match (matcher.findAll()) {
            case Some(mdArray) => mdArray |>
                map { md: MatchData =>
                    this.parseExpr(md.matchStr(1).replace(ESCAPED_NEWLINE, "\n"))
                } |>
                collectArray
            case None => Array<Expr>()
        }
        if (subStrings.size != exprs.size + 1) {
            throw DslException("Template format error: the number of variables does not match the number of substrings")
        }
        // Construct the string part by part
        let tokens = Tokens()
        tokens.append(quote(
            sb.append( $(newMultilineStringLiteralToken(subStrings[0])) )
        ))
        for (i in 0..exprs.size) {
            tokens.append(quote(
                sb.append( $(exprs[i]) .toString() )
                sb.append( $(newMultilineStringLiteralToken(subStrings[i+1])) )
            ))
        }
        return tokens
    }

    /**
     * Parse the expression string into an AST expression
     */
    private func parseExpr(str: String): Expr {
        try {
            return parseExpr(cangjieLex(str))
        } catch (ex: IllegalArgumentException) {
            // eprintln("Invalid expression `${str}` in template")
            throw DslException("Invalid expression `${str}` in template")
        } catch (ex: ParseASTException) {
            // eprintln("Failed to parse expression `${str}` in template")
            throw DslException("Failed to parse expression `${str}` in template")
        }
    }
}