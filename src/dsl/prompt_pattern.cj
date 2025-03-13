/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.*
import std.ast.*

class PromptPatternAttr <: Attr {
    PromptPatternAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    prop autoToString: Bool {
        get() { getBool("autoToString") }
    }

    let elementNames = ArrayList<String>()

    static func parse(attrTokens: Tokens): PromptPatternAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "promptPattern",
            validKeys: ["autoToString"]
        )
        return PromptPatternAttr(map)
    }
}

public macro promptPattern(input: Tokens): Tokens {
    let promptPatternAttr = PromptPatternAttr()
    for (m in getChildMessages("element")) {
        if (m.hasItem("elementName")) {
            let name = m.getString("elementName")
            promptPatternAttr.elementNames.append(name)
        }
    }
    return transformPromptPattern(input, promptPatternAttr)
}

public macro promptPattern(attr: Tokens, input: Tokens): Tokens {
    let promptPatternAttr = PromptPatternAttr.parse(attr)
    for (m in getChildMessages("element")) {
        if (m.hasItem("elementName")) {
            let name = m.getString("elementName")
            promptPatternAttr.elementNames.append(name)
        }
    }
    let content = transformPromptPattern(input, promptPatternAttr)
    if (promptPatternAttr.dump) {
        printTokens(content)
    }
    return content
}

func transformPromptPattern(input: Tokens, promptPatternAttr: PromptPatternAttr): Tokens {
    let decl = parseDecl(input)
    if (decl.isClassDecl()) {
        return transformPromptPatternClass(decl.asClassDecl(), promptPatternAttr)
    } else {
        throw Exception("@promptPattern should be used on class declarations")
    }
}

/**
 * Transform
 * @promptPattern
 * class F {
 *   @element let a: String
 *   @element let b: String
 *   ...
 * }
 * as
 * class F {
 *   let a: String
 *   let b: String
 *   ...
 *   public init(a!: String, b!: String) {
 *     this.a = a
 *     this.b = b
 *   }
 *   public static func getElementNames(): Array<String> { return ["a", "b"] }
 * }
 */
func transformPromptPatternClass(classDecl: ClassDecl, promptPatternAttr: PromptPatternAttr): Tokens {
    let genericTypeParamTokens = getGenericTypeParamsTokens(classDecl)
    let genericConstraintTokens = getGenericConstraintsTokens(classDecl)

    let classNameToken = classDecl.identifier
    let classDeclBody = classDecl.body.decls

    let ctorMethod = buildCtorMethod(promptPatternAttr)
    let getElementNamesMethod = buildElementNamesMethod(promptPatternAttr)
    let toStringMethod = buildToStringMethod(promptPatternAttr)

    // Compose all `Tokens`
    return quote(
        $(classDecl.modifiers) class $classNameToken $genericTypeParamTokens $genericConstraintTokens {
            $classDeclBody
            $ctorMethod
            $getElementNamesMethod
            $toStringMethod
        }
    )
    // TODO: check `toString` must be implemented
}

func buildCtorMethod(promptPatternAttr: PromptPatternAttr): Tokens {
    let params: Tokens = joinTokens(
        promptPatternAttr.elementNames |>
            map { name: String => quote($(newIdentifierToken(name))!: String) } |>
            collectArrayList,
        Token(TokenKind.COMMA)
    )
    let body: Tokens = joinTokens(
        promptPatternAttr.elementNames |>
            map { name: String =>
                let id =  newIdentifierToken(name)
                return quote(this.$id = $id)
            } |>
            collectArrayList,
        Token(TokenKind.NL)
    )
    return quote(
        public init($params) {
            $body
        }
    )
}

func buildElementNamesMethod(promptPatternAttr: PromptPatternAttr): Tokens {
    let values: Tokens = joinTokens(
        promptPatternAttr.elementNames |> map({ name: String => newLiteralToken(name) }) |> collectArrayList,
        Token(TokenKind.COMMA)
    )
    return quote(
        public static func getElementNames(): Array<String> {
            return [ $values ]
        }
    )
}

func buildToStringMethod(promptPatternAttr: PromptPatternAttr): Tokens {
    if (promptPatternAttr.autoToString == false) {
        return Tokens()
    }
    let body = quote(let sb = StringBuilder())
    for (elemName in promptPatternAttr.elementNames) {
        let title = newLiteralToken(elemName.toAsciiTitle())
        let elemField = newIdentifierToken(elemName)
        body.append(quote(
            sb.append("# ")
            sb.append($title)
            sb.append("\n")
            sb.append($elemField)
            sb.append("\n")
        ))
    }

    return quote(
        public func toString(): String {
            $body
            return sb.toString()
        }
    )
}