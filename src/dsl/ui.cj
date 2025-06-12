/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.{ArrayList, map, collectArray}
import std.regex.{Regex, MatchData}

private class UIAttr <: Attr {
    UIAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    prop template: Option<String> {
        get() {
            getLiteral("template")
        }
    }

    static func parse(attrTokens: Tokens): UIAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "ui",
            validKeys: [
                "template", "parameters", "description", "filterable",
                "terminal", "dump"
            ]
        )
        return UIAttr(map)
    }
}

/**
 * This macro is used to define a UI tool.
 * Its function body has a single string literal that is the template content.
 */
public macro ui(input: Tokens): Tokens {
    let attr = UIAttr()
    return transformUI(input, attr)
}

public macro ui(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = UIAttr.parse(attrTokens)
    let content = transformUI(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform the function as a render of a template.
 * @ui
 * func foo(<args>) { <body> }
 * AS
 * @template
 * func __template_of_foo(<args>) { <body> }
 * @tool
 * func foo(<args>): String { __template_of_foo(<args>) }
 */
private func transformUI(input: Tokens, attr: UIAttr): Tokens {
    let decl = parseDecl(input)
    if (!decl.isFuncDecl()) {
        throw DslException("@ui should be called on function declarations")
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
    let retType = checkFuncRetString(funcDecl)
    let templateFnName = newIdentifierToken("__template_of_${funcDecl.identifier.value}")

    let template = attr.template.getOrThrow({ =>
        DslException("@ui must have a template attribute.")
    })
    if (!exists(template)) {
        throw DslException("`template` refers to non-existing file: ${template}")
    }
    let toolAttrs = ArrayList<Tokens>()
    for (key in ["description", "parameters", "filterable", "terminal"]) {
        if (let Some(tokens) <- attr.getTokens(key)) {
            toolAttrs.append(quote($(newIdentifierToken(key)): $tokens))
        }
    }
    let toolAttr = joinTokens(toolAttrs, Token(TokenKind.COMMA))

    return quote(
        @template[
            path: $(newLiteralToken(template))
        ]
        $modifier func $templateFnName $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint { }

        @tool[$toolAttr]
        $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
            $templateFnName($args)
        }
    )
}
