/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.{ArrayList, map, collectArray}

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
                "terminal", "dump", "title", "thumbnail", "category"
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

    /*let template = attr.template.getOrThrow({ =>
        DslException("@ui must have a template attribute.")
    })
    if (!exists(template)) {
        throw DslException("`template` refers to non-existing file: ${template}")
    }*/
    let toolAttrs = ArrayList<Tokens>()
    for (key in ["description", "parameters", "filterable", "terminal"]) {
        if (let Some(tokens) <- attr.getTokens(key)) {
            toolAttrs.add(quote($(newIdentifierToken(key)): $tokens))
        }
    }
    let toolAttr = joinTokens(toolAttrs, Token(TokenKind.COMMA))

    let tempAttrs = ArrayList<Tokens>()
    for (key in ["thumbnail", "title", "category"]) {
        if (let Some(tokens) <- attr.getTokens(key)) {
            tempAttrs.add(quote($(newIdentifierToken(key)): $tokens))
        }
    }
    let tempAttr = joinTokens(tempAttrs, Token(TokenKind.COMMA))

    return quote(
        @template[$tempAttr]
        $modifier func $templateFnName $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint $(funcDecl.block)

        @tool[$toolAttr]
        $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
            $templateFnName($args)
        }
    )
}

// private func transformUI(input: Tokens, attr: UIAttr): Tokens {
//     let decl = parseDecl(input)
//     if (!decl.isFuncDecl()) {
//         throw DslException("@ui should be called on function declarations")
//     }
//     let funcDecl = decl.asFuncDecl()
//     let templateFunc = if (attr.template.isSome()) {
//         transformTemplateFile(funcDecl, attr)
//     } else {
//         transformComposition(funcDecl, attr)
//     }

//     let toolAttrs = ArrayList<Tokens>()
//     for (key in ["description", "parameters", "filterable", "terminal", "dump", "uitype"]) {
//         if (let Some(tokens) <- attr.getTokens(key)) {
//             toolAttrs.add(quote($(newIdentifierToken(key)): $tokens))
//         }
//     }
//     let toolAttr = joinTokens(toolAttrs, Token(TokenKind.COMMA))
//     let modifier = funcDecl.modifiers
//     let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
//     let genericConstraint = getGenericConstraintsTokens(funcDecl)
//     let args: Tokens = joinTokens(
//         getFuncParamNames(funcDecl) |>
//             map { name: String => newIdentifierToken(name) } |>
//             collectArray,
//         Token(TokenKind.COMMA)
//     )
//     let retType = checkFuncRetString(funcDecl)
//     let templateFnName = newIdentifierToken("__template_of_${funcDecl.identifier.value}")
//     quote(
//         $templateFunc

//         @tool[$toolAttr](
//             $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
//                 $templateFnName($args)
//             }
//         )
//     )
// }

// private func transformTemplateFile(funcDecl: FuncDecl, attr: UIAttr): Tokens {
//     let path = attr.template.getOrThrow()
//     if (!exists(path)) {
//         throw DslException("`template` refers to non-existing file: ${path}")
//     }
//     let templateFnName = newIdentifierToken("__template_of_${funcDecl.identifier.value}")
//     return quote(
//         @template[path: $(newLiteralToken(path))](
//             private func $templateFnName ( $(funcDecl.funcParams) ): String { }
//         )
//     )
// }

// func fetchArgument(callExpr: CallExpr, argName: String): Expr {
//     for (arg in callExpr.arguments) {
//         if (arg.identifier.value == argName) {
//             return arg.expr
//         }
//     }
//     throw UnsupportedException()
// }

// private func transformComposition(funcDecl: FuncDecl, attr: UIAttr): Tokens {
//     let body = quote(let components = ArrayList<HTMLComponent>())
//     var index = 0
//     for (node in funcDecl.block.nodes) {
//         let call  = (node as CallExpr).getOrThrow()
//         let name = (call.callFunc as RefExpr).getOrThrow().identifier.value
//         // Check names
//         body.append(quote(
//             components.add(HTMLComponent($call, $index))
//         ))
//         index = index + 1
//     }
//     let templateFnName = newIdentifierToken("__template_of_${funcDecl.identifier.value}")
//     return quote(
//         private func $templateFnName ( $(funcDecl.funcParams) ): String {
//             $body
//             mergeHTMLComponents("title", components)
//         }
//     )
// }
