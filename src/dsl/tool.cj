/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

public import std.convert.Parsable
import std.collection.{map, collectArrayList, ArrayList, HashMap}
import std.ast.*

/**
 * Since ToolAttr is special that will contain multiple attributes with the same key,
 * we cannot use a hashmap to store its attributes.
 */
private class ToolAttr <: Attr {

    init(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    var insideAgent = false

    prop description: String {
        get() { getString("description") ?? "" }
    }

    private var _parameters: Option<HashMap<String, String>> = None

    prop parameters: HashMap<String, String> {
        get() {
            if (let Some(v) <- _parameters) { return v }

            let result = HashMap<String, String>()
            if (let Some(tokens) <- getTokens("parameters")) {
                let tokenMap = MapParser(tokens).parseMapOf(TokenKind.STRING_LITERAL)
                for ((name, token) in tokenMap) {
                    result.add(name, token.value)
                }
            }
            _parameters = Some(result)
            return result
        }
    }

    prop examples: ArrayList<String> {
        get() {
            let result = ArrayList<String>()
            if (let Some(tokens) <- getTokens("examples")) {
                let tokenArray = ArrayParser(tokens).parseArrayOf(TokenKind.STRING_LITERAL)
                for (token in tokenArray) {
                    result.add(token.value)
                }
            }
            return result
        }
    }

    prop filterable: Bool {
        get() {
            getBool("filterable", default: true)
        }
    }

    prop terminal: Bool {
        get() {
            getBool("terminal", default: false)
        }
    }

    static func parse(attrTokens: Tokens): ToolAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "tool",
            validKeys: ["description", "parameters", "examples", "filterable", "terminal", "dump"]
        )
        return ToolAttr(map)
    }
}

/**
 * For each `@tool` function,
 * 1. rename the function
 * 2. replace the function as an object of a wrapper type
 * 3. generate the wrapper type
 * 4. if the function is defined inside a class, the wrapper type is omitted
 */
public macro tool(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = ToolAttr.parse(attrTokens)
    if (insideParentContext("agent")) {
        attr.insideAgent = true
    }
    let content = transformTool(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

private func transformTool(input: Tokens, attr: ToolAttr): Tokens {
    let funcDecl: FuncDecl = parseFuncDecl(input)
    let funcName = funcDecl.identifier.value
    setItem("internalTool", funcName) // Notify @agent

    let callNativeFuncTool = buildCallNativeFuncTool(attr, funcDecl)

    let toolImplFuncName = newIdentifierToken("${TOOL_IMPL_PREFIX}${funcName}")
    let toolWrapperClassName = newIdentifierToken("__wrapper_class_of_${funcName}")

    let content = if (funcDecl.block.nodes.isEmpty()) { // Only declaration without function body
        callNativeFuncTool
    } else {
        // If `@tool` defines an internal tool, we transform it as a prop
        if (attr.insideAgent) {
            quote(
                $(renameFunction(funcDecl, toolImplFuncName))
                $(funcDecl.modifiers) prop $(funcDecl.identifier): Tool {
                    get() { $callNativeFuncTool }
                }
            )
        } else {
            quote(
                $(renameFunction(funcDecl, toolImplFuncName))
                $(funcDecl.modifiers) class $toolWrapperClassName <: NativeFuncTool {
                    init() {
                        $callNativeFuncTool
                    }
                    $(renameFunctionAsOperator(funcDecl))
                }
                $(funcDecl.modifiers) let $(funcDecl.identifier) = $toolWrapperClassName()
            )
        }
    }
    return content
}

/**
 * Generate the following code:
 * ```
 * NativeFuncTool(name: ...,
                  description: ...,
                  parameters: [("paramName", "paramDesc", TypeSchema.XXX), ...],
                  execFn: ...)
 * ```
 */
private func buildCallNativeFuncTool(toolAttr: ToolAttr, funcDecl: FuncDecl): Tokens {
    let modifier = funcDecl.modifiers
    let funcName = newLiteralToken(funcDecl.identifier.value)
    let funcParams: ArrayList<FuncParam> = funcDecl.funcParams
    // Iterate all parameters.
    let parameters = ArrayList<Tokens>()
    for (i in 0..funcParams.size) {
        let param: FuncParam = funcParams[i]
        let paramName: String = param.identifier.value
        let paramTy = param.paramType
        let paramDesc: String = toolAttr.parameters.get(paramName) ?? ""

        parameters.add(
            quote(($(newLiteralToken(paramName)), $(newLiteralToken(paramDesc)), $paramTy.getTypeSchema()))
        )
    }
    let retType = getRetTypeTokens(funcDecl)

    let examples = toolAttr.examples |>
        map { ex: String => newLiteralToken(ex) } |>
        collectArrayList

    let execFunc = transformToolExecuteLambda(toolAttr, funcDecl)
    if (toolAttr.insideAgent) {
        return quote(NativeFuncTool(
            name: $funcName,
            description: $(newMultilineStringLiteralToken(toolAttr.description)),
            parameters: [$(joinTokens(parameters, Token(TokenKind.COMMA)))],
            // retType: $retType.getTypeSchema(),
            examples: [$(joinTokens(examples, Token(TokenKind.COMMA)))],
            filterable: $(newLiteralToken(toolAttr.filterable)),
            terminal: $(newLiteralToken(toolAttr.terminal)),
            execFn: $execFunc
        ))
    } else {
        return quote(super(
            name: $funcName,
            description: $(newMultilineStringLiteralToken(toolAttr.description)),
            parameters: [$(joinTokens(parameters, Token(TokenKind.COMMA)))],
            // retType: $retType.getTypeSchema(),
            examples: [$(joinTokens(examples, Token(TokenKind.COMMA)))],
            filterable: $(newLiteralToken(toolAttr.filterable)),
            terminal: $(newLiteralToken(toolAttr.terminal)),
            execFn: $execFunc
        ))
    }
}

/**
 * ```
 * { args: Array<ToJsonValue> =>
 *   return <tool_name>(args[0], ..., args[N])
 * }
 * ```
 */
private func transformToolExecuteLambda(toolAttr: ToolAttr, funcDecl: FuncDecl): Tokens {
    let toolImplFuncName = newIdentifierToken("${TOOL_IMPL_PREFIX}${funcDecl.identifier.value}")
    let funcParams: ArrayList<FuncParam> = funcDecl.funcParams

    let argConversion = Tokens()
    let args = ArrayList<Token>()
    // Iterate all parameters.
    for (i in 0..funcParams.size) {
        let paramName = funcParams[i].identifier.value
        let paramTy = funcParams[i].paramType
        let rawArg = quote(args[$(newLiteralToken(paramName))])
        let arg: Token = newIdentifierToken("arg_${i}")
         argConversion.append(quote(
            let $arg = $paramTy.fromJsonValue($rawArg)
            // let $arg = $paramTy.fromJsonStr($rawArg)
        ))
        args.add(arg)
    }
    let argsTokens = joinTokens(args, Token(TokenKind.COMMA))
    return quote({ args: HashMap<String, JsonValue> =>
        $argConversion
        return $toolImplFuncName($argsTokens).toString()
    })
}
