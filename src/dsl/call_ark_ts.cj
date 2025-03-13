/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.ArrayList

private class CallArkTsAttr <: Attr {
    CallArkTsAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    prop name: String {
        get() { getLiteral("name").getOrThrow() }
    }

    prop context: Tokens {
        get() { getTokens("context").getOrThrow() }
    }

    static func parse(attrTokens: Tokens): CallArkTsAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "callArkTs",
            validKeys: ["name", "context", "dump"]
        )
        return CallArkTsAttr(map)
    }
}

public macro callArkTs(input: Tokens): Tokens {
    let attr = CallArkTsAttr()
    return transformCallArkTs(input, attr)
}

public macro callArkTs(attr: Tokens, input: Tokens): Tokens {
    let callArkTsAttr = CallArkTsAttr.parse(attr)

    let content = transformCallArkTs(input, callArkTsAttr)
    if (callArkTsAttr.dump) {
        printTokens(content)
    }
    return content
}

private func transformCallArkTs(input: Tokens, callArkTsAttr: CallArkTsAttr): Tokens {
    let decl = parseDecl(input)
    if (!decl.isFuncDecl()) {
        throw DslException("@callArkTs should be called on function declarations")
    }
    let funcDecl = decl.asFuncDecl()
    let retType = funcDecl.declType
    let name = newLiteralToken(callArkTsAttr.name)

    let modifiers = funcDecl.modifiers
    modifiers.removeIf({ m: Modifier => m.keyword.value == "foreign" })

    return quote (
        $modifiers func $(funcDecl.identifier) ( $(funcDecl.funcParams) ): $retType {
            let context = $(callArkTsAttr.context)
            let fut = spawn {
                let queue = BlockingQueue<Option<$retType>>()
                context.postJSTask {
                    let promise = context.global.callMethod(
                        $name, $(buildArkTsArgs(funcDecl))
                    ).asPromise()
                    promise.then(
                        context.function { context, callInfo =>
                            let result = $(convertToCJValue(quote(callInfo[0]), retType))
                            queue.enqueue(result)
                            return context.undefined().toJSValue()
                        },
                        onRejected: context.function { context, callInfo =>
                            queue.enqueue(None)
                            return context.undefined().toJSValue()
                        }
                    )
                }
                return queue.dequeue()
            }
            return fut.get().getOrThrow()
        }
    )
}

private func buildArkTsArgs(funcDecl: FuncDecl): Tokens {
    let funcParams: ArrayList<FuncParam> = funcDecl.funcParams
    let args = ArrayList<Tokens>()
    // Iterate all parameters.
    for (i in 0..funcParams.size) {
        let paramName = funcParams[i].identifier.toTokens()
        let paramTy = funcParams[i].paramType
        args.append(convertToJSValue(paramName, paramTy))
    }
    return quote([$(joinTokens(args, Token(TokenKind.COMMA)))])
}

/**
 * The name may be a identifier, like abc,
 * or an array element access, like abc[i].
 * Extract the index if it's an access.
 */
private func extractIndexName(name: String): String {
    if (let Some(start) <- name.indexOf("[")) {
        let end = name.indexOf("]") ?? name.size - 1
        return name[(start + 1)..end]
    }
    return ""
}

private func convertToJSValue(name: Tokens, ty: TypeNode): Tokens {
    let tyName = getTypeName(ty)
    match (tyName) {
        case "Int64" | "Int" => quote(context.number(Int32($name)).toJSValue())
        case "Int32" | "Float64" => quote(context.number($name).toJSValue())
        case "String" => quote(context.string($name).toJSValue())
        case "Bool" => quote(context.boolean($name).toJSValue())
        case "Array" =>
            let innerTy = ty.asRefType().typeArguments[0] // Get T of Array<T>
            let idx = newIdentifierToken(extractIndexName(name.toString()) + "_i") // Introduce a new index variable
            let elem = quote($name[$idx])
            quote(
                context.array(
                    Array($name.size, { $idx: Int64 =>
                        $(convertToJSValue(elem, innerTy))
                    })
                ).toJSValue()
            )
        case _ => throw DslException("Unsupported type `${tyName}`")
    }
}


private func convertToCJValue(name: Tokens, ty: TypeNode): Tokens {
    let tyName = getTypeName(ty)
    match (tyName) {
        case "Int" => quote(Int($name.asNumber().toFloat64()))
        case "Int64" => quote(Int64($name.asNumber().toFloat64()))
        case "Int32" => quote(Int32($name.asNumber().toFloat64()))
        case "Float64" => quote($name.asNumber().toFloat64())
        case "String" => quote($name.asString().toString())
        case "Bool" => quote($name.asBoolean().toBool())
        case "Array" =>
            let innerTy = ty.asRefType().typeArguments[0] // Get T of Array<T>
            let tmpArr = newIdentifierToken("arr_${extractIndexName(name.toString())}_i") // Introduce a new tmp variable
            let idx = newIdentifierToken("idx_${extractIndexName(name.toString())}_i") // Introduce a new index variable
            let elem = quote($tmpArr[$idx])
            quote(
                { =>
                    let $tmpArr = $name.asArray()
                    return Array($tmpArr.size, { $idx: Int64 =>
                        $(convertToCJValue(elem, innerTy))
                    })
                }()
            )
        case _ => throw DslException("Unsupported type `${tyName}`")
    }
}