/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{collectArrayList, ArrayList, HashMap, map}
import std.ast.*

class JsonableAttr <: Attr {
    JsonableAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    /**
     * Whether @jsonable is put on a class
     */
    var isClass = true

    var typeName = ""

    var variables = ArrayList<VarDecl>()

    var variableDescriptions = HashMap<String, String>()

    static func parse(attrTokens: Tokens): JsonableAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "jsonable",
            validKeys: ["dump"]
        )
        return JsonableAttr(map)
    }
}

public macro jsonable(input: Tokens): Tokens {
    let jsonableAttr = JsonableAttr()
    for (m in getChildMessages("field")) {
        if (m.hasItem("fieldDesc")) {
            let s = m.getString("fieldDesc")
            let items = s.split(":", 2) // Format: ${name}:${desc}
            jsonableAttr.variableDescriptions.put(items[0], items[1])
        }
    }
    return transformJsonable(input, jsonableAttr)
}

public macro jsonable(attr: Tokens, input: Tokens): Tokens {
    let jsonableAttr = JsonableAttr.parse(attr)

    for (m in getChildMessages("field")) {
        if (m.hasItem("fieldDesc")) {
            let s = m.getString("fieldDesc")
            let items = s.split(":", 2) // Format: ${name}:${desc}
            jsonableAttr.variableDescriptions.put(items[0], items[1])
        }
    }

    let content = transformJsonable(input, jsonableAttr)
    if (jsonableAttr.dump) {
        printTokens(content)
    }
    return content
}

func transformJsonable(input: Tokens, jsonableAttr: JsonableAttr): Tokens {
    let decl = parseDecl(input)
    if (let Some(classDecl) <- (decl as ClassDecl)) {
        return transformJsonableClass(classDecl, jsonableAttr)
    } else if (let Some(structDecl) <- (decl as StructDecl)) {
        return transformJsonableStruct(structDecl, jsonableAttr)
    } else {
        throw Exception("@jsonable should be used on class/struct declarations")
    }
}

/**
 * Transform
 * @jsonable
 * class F {
 *   let a: String
 *   let b: String
 *   ...
 * }
 * as
 * class F {
 *   let a: String
 *   let b: String
 *
 *   public init(...) { ... }
 *   static func getTypeSchema(): TypeSchema { ...}
 *   static func fromJsonValue(json: JsonValue): T { ... }
 *   func toJsonValue(): JsonValue { ... }
 * }
 */
func transformJsonableType(typeDecl: Decl, superTypes: ArrayList<TypeNode>, body: Body, jsonableAttr: JsonableAttr): Tokens {
    let name = typeDecl.identifier
    let allSuperTypes = if (superTypes.isEmpty()) {
        quote(Jsonable<$name>)
    } else {
        quote(Jsonable<$name> & $(superTypes.toTokens()))
    }

    jsonableAttr.typeName = name.value
    jsonableAttr.variables = getMemberVariables(body)

    let ctorMethod = buildCtorMethod(jsonableAttr)
    let getTypeSchemaMethod = buildGetTypeSchemaMethod(jsonableAttr)
    let fromJsonMethod = buildFromJsonMethod(jsonableAttr)
    let toJsonMethod = buildToJsonMethod(jsonableAttr)

    let genericTypeParamTokens = getGenericTypeParamsTokens(typeDecl)
    let genericConstraintTokens = getGenericConstraintsTokens(typeDecl)
    let classOrStruct = if (jsonableAttr.isClass) {
        Token(TokenKind.CLASS)
    } else {
        Token(TokenKind.STRUCT)
    }

    // Compose all `Tokens`
    return quote(
        $(typeDecl.modifiers) $classOrStruct $name $genericTypeParamTokens <: $allSuperTypes $genericConstraintTokens {
            $(body.decls)
            $ctorMethod
            $getTypeSchemaMethod
            $fromJsonMethod
            $toJsonMethod
        }
    )
}

func transformJsonableClass(classDecl: ClassDecl, jsonableAttr: JsonableAttr): Tokens {
    jsonableAttr.isClass = true
    return transformJsonableType(classDecl, classDecl.superTypes, classDecl.body, jsonableAttr)
}

func transformJsonableStruct(structDecl: StructDecl, jsonableAttr: JsonableAttr): Tokens {
    jsonableAttr.isClass = false
    return transformJsonableType(structDecl, structDecl.superTypes, structDecl.body, jsonableAttr)
}

func getMemberVariables(body: Body): ArrayList<VarDecl> {
    let result = ArrayList<VarDecl>()
    for (decl in body.decls) {
        if (decl.isVarDecl()) {
            let varDecl = (decl as VarDecl).getOrThrow()
            result.append(varDecl)
        }
    }
    return result
}

/**
 * For each member variable, create a named parameter and a initialization expression for it.
 * public init(v!: type, ...) {
 *    this.v = v
 * }
 **/
func buildCtorMethod(jsonableAttr: JsonableAttr): Tokens {
    let params = ArrayList<Tokens>()
    let paramsWithDefaultValue = ArrayList<Tokens>()

    for (varDecl in jsonableAttr.variables) {
        let v = newIdentifierToken(varDecl.identifier.value)
        let tyName = varDecl.declType.toTokens()
        try {
            let initExpr = varDecl.expr
            paramsWithDefaultValue.append(quote($v!: $tyName = $initExpr))
        } catch (_: ASTException) {
            params.append(quote($v!: $tyName))
        }
    }
    params.appendAll(paramsWithDefaultValue)
    let comma = Token(TokenKind.COMMA)

    let body: Tokens = joinTokens(
        jsonableAttr.variables |>
            map { varDecl: VarDecl =>
                let id =  newIdentifierToken(varDecl.identifier.value)
                return quote(this.$id = $id)
            } |>
            collectArrayList,
        Token(TokenKind.NL)
    )
    return quote(
        public init($(joinTokens(params, comma))) {
            $body
        }
    )
}

func isOption(typeNode: TypeNode): Bool {
    if (let Some(varType) <- (typeNode as RefType)) {
        return varType.identifier.value == "Option"
    }
    return false
}

func buildGetTypeSchemaMethod(jsonableAttr: JsonableAttr): Tokens {
    let body = Tokens()
    for (varDecl in jsonableAttr.variables) {
        let varName = varDecl.identifier.value
        let varNameToken = newLiteralToken(varName)
        let tyName = varDecl.declType.toTokens()

        let desc = jsonableAttr.variableDescriptions.get(varName) ?? ""
        let descToken = if (desc.contains("\n")) {
            newMultilineStringLiteralToken(desc)
        } else {
            newLiteralToken(desc)
        }

        let required = newLiteralToken(!isOption(varDecl.declType))
        body.append(quote(
            fields.append(FieldSchema($varNameToken, $descToken, $tyName.getTypeSchema(), required: $required))
        ))
    }
    return quote(
        public static func getTypeSchema(): TypeSchema {
            let fields = ArrayList<FieldSchema>()
            $body
            return TypeSchema.Obj(fields.toArray())
        }
    )
}

func getDefaultValueOfType(typeNode: TypeNode): Option<Tokens> {
    if (let Some(varType) <- (typeNode as RefType)) {
        return match (varType.identifier.value) {
            case "Option" => Some(quote(JsonNull()))
            case "Array" => Some(quote(JsonArray()))
            case "String" => Some(quote(JsonString("")))
            case _ => Some(quote(JsonObject()))
        }
    }
    if (let Some(varType) <- (typeNode as PrimitiveType)) {
        if (varType.keyword.value.startsWith("Int")) {
            return Some(quote(JsonInt(0)))
        } else if (varType.keyword.value.startsWith("Float")) {
            return Some(quote(JsonFloat(0.0)))
        } else if (varType.keyword.value.startsWith("Bool")) {
            return Some(quote(JsonBool(false)))
        } else if (varType.keyword.value.startsWith("Rune")) {
            return Some(quote(JsonString("")))
        } else {
            return Option.None
        }
    }
    return Option.None
}

func buildFromJsonMethod(jsonableAttr: JsonableAttr): Tokens {
    let className = newIdentifierToken(jsonableAttr.typeName)

    // Build the field initialization
    // return Cls(
    //   <fieldName>: <FieldType>.fromJsonValue(jo.get("<fieldName>").getOrDefault({ => <defaultValue> }))
    //   ...
    // )
    //
    let body: Tokens = joinTokens(
        jsonableAttr.variables |>
            map { varDecl: VarDecl =>
                let varName = varDecl.identifier.value
                let fieldName = newIdentifierToken(varName)
                // Special identifier like `type`
                let fieldNameStr = if (varName.startsWith("`")) {
                    newLiteralToken(varName[1..(varName.size - 1)])
                } else {
                    newLiteralToken(varName)
                }
                let varType = varDecl.declType
                if (let Some(defaultValue) <- getDefaultValueOfType(varType)) {
                    return quote(
                        $fieldName: $varType.fromJsonValue(jo.get($fieldNameStr).getOrDefault({ => $defaultValue }))
                    )
                } else{
                    return quote(
                        $fieldName: $varType.fromJsonValue(jo.get($fieldNameStr).getOrThrow({ => throw JsonableException("Get JSON object field error")}))
                    )
                }

            } |>
            collectArrayList,
        Token(TokenKind.COMMA)
    )
    return quote(
        public static func fromJsonValue(json: JsonValue): $className {
            let jo: JsonObject = match (json.kind()) {
                case JsonKind.JsObject => json.asObject()
                case _ => throw JsonableException("Get JSON object error.")
            }
            return $className(
                $body
            )
        }
    )
}

func buildToJsonMethod(jsonableAttr: JsonableAttr): Tokens {
    let body = Tokens()
    for (varDecl in jsonableAttr.variables) {
        let varName = varDecl.identifier.value

        let fieldName = if (varName.startsWith("`")) {
            varName[1..(varName.size - 1)]
        } else {
            varName
        }
        let tempVar = newIdentifierToken("__TEMP_OF__${fieldName}")
        // A field of type Option means it's a non-required fields,
        // so, if its value is JsonNull, skip it.
        if (isOption(varDecl.declType)) {
            body.append(quote(
                let $tempVar = $(newIdentifierToken(varName)).toJsonValue()
                match ($tempVar.kind()) {
                    case JsonKind.JsNull => ()
                    case _ => map.put($(newLiteralToken(fieldName)), $tempVar)
                }
            ))
        } else {
            body.append(quote(
                map.put($(newLiteralToken(fieldName)), $(newIdentifierToken(varName)).toJsonValue())
            ))
        }
    }

    return quote(
        public func toJsonValue(): JsonValue {
            let map = HashMap<String, JsonValue>()
            $body
            return JsonObject(map)
        }
    )
}