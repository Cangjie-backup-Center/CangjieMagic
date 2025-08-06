/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{ArrayList, map, collectArray}
import std.ast.*

private class ToolsetAttr <: Attr {
    private static let ATTR_NAMES = [
        "dump"
    ]

    ToolsetAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    // Whether @toolset is used with a class or struct.
    var isClass = false

    let internalTools = ArrayList<String>()

    static func parse(attrTokens: Tokens): ToolsetAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "toolset",
            validKeys: ToolsetAttr.ATTR_NAMES
        )
        return ToolsetAttr(map)
    }
}

public macro toolset(input: Tokens): Tokens {
    let attr = ToolsetAttr()
    for (m in getChildMessages("tool")) {
        if (m.hasItem("internalTool")) {
            let name = m.getString("internalTool")
            attr.internalTools.add(name)
        }
    }
    return transformToolset(input, attr)
}

public macro toolset(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = ToolsetAttr.parse(attrTokens)
    for (m in getChildMessages("tool")) {
        if (m.hasItem("internalTool")) {
            let name = m.getString("internalTool")
            attr.internalTools.add(name)
        }
    }
    let content = transformToolset(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform the function
 * @toolset
 * struct/class <name> {
 *   @tool <func-decl>
 * }
 * AS
 * struct/class <name> <: Toolset {
 *   public override iterator(): Iterator<Tool> {
 *      [<tool-names>]
 *   }
 *   ...
 * }
 */
private func transformToolset(input: Tokens, attr: ToolsetAttr): Tokens {
    let decl = parseDecl(input)
    if (let Some(classDecl) <- (decl as ClassDecl)) {
        return transformToolsetClass(classDecl, attr)
    } else if (let Some(structDecl) <- (decl as StructDecl)) {
        return transformToolsetStruct(structDecl, attr)
    } else {
        throw DslException("@toolset should be used with class/struct declarations")
    }
}

private func transformToolsetClass(classDecl: ClassDecl, attr: ToolsetAttr): Tokens {
    attr.isClass = true
    return transformToolsetType(classDecl, classDecl.superTypes, classDecl.body, attr)
}

private func transformToolsetStruct(structDecl: StructDecl, attr: ToolsetAttr): Tokens {
    attr.isClass = false
    return transformToolsetType(structDecl, structDecl.superTypes, structDecl.body, attr)
}

private func transformToolsetType(typeDecl: Decl, superTypes: ArrayList<TypeNode>, body: Body, attr: ToolsetAttr): Tokens {
    let name = typeDecl.identifier
    let allSuperTypes = if (superTypes.isEmpty()) {
        quote(Toolset)
    } else {
        quote(Toolset & $(superTypes.toTokens()))
    }

    let genericTypeParamTokens = getGenericTypeParamsTokens(typeDecl)
    let genericConstraintTokens = getGenericConstraintsTokens(typeDecl)
    let classOrStruct = if (attr.isClass) {
        Token(TokenKind.CLASS)
    } else {
        Token(TokenKind.STRUCT)
    }

    let toolNames = joinTokens(
        attr.internalTools |>
            map { name: String => newIdentifierToken(name) } |>
            collectArray,
        Token(TokenKind.COMMA)
    )

    // Compose all `Tokens`
    return quote(
        $(typeDecl.modifiers) $classOrStruct $name $genericTypeParamTokens <: $allSuperTypes $genericConstraintTokens {
            $(body.decls)
            public override prop tools: Array<Tool> {
                get() {
                    [ $toolNames ]
                }
            }
        }
    )
}

