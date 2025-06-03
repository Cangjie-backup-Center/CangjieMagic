/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.{ArrayList, map, collectArray}

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

    static func parse(attrTokens: Tokens): TemplateAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "template",
            validKeys: ["prefix", "path", "dump"]
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

private func escapeStringForTemplate(input: String): String {
    // Escape `${` to `\${` to prevent it from being interpreted as a variable in the template engine
    return input.replace("\${", "\\\${")
}