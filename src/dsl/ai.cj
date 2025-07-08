/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{ArrayList, map, collectArray}
import std.ast.*

private class AiAttr <: Attr {
    private static let ATTR_NAMES = [
        "model",
        "prompt",
        "temperature",
        "tools",
        "validator",
        "dump"
    ]

    AiAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    static func parse(attrTokens: Tokens): AiAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "ai",
            validKeys: AiAttr.ATTR_NAMES
        )
        return AiAttr(map)
    }

    prop model: Option<String> {
        get() { getString("model") }
    }

    prop prompt : Option<String> {
        get() { getString("prompt") }
    }

    prop temperature: Option<Float64> {
        get() {
            if (let Some(v) <- getLiteral("temperature")) {
                try {
                    return Float64.tryParse(v)
                } catch (_: IllegalArgumentException) {
                    throw DslException("Invalid temperature attribute")
                }
            }
            return None
        }
    }

    /**
     * tools: [
     *   stdioMCP("...", ABC: "VALUE", ...)
     *   httpMCP("...")
     *   id
     * ]
     */
    private var _tools: Option<Array<AgentToolAttr>> = None
    prop tools: Array<AgentToolAttr> {
        get() {
            if (let Some(v) <- _tools) {
                return v
            }
            if (let Some(tokens) <- getTokens("tools")) {
                let result = ArrayList<AgentToolAttr>()
                for (toolTokens in ArrayParser(tokens).parseArrayOfTokens()) {
                    result.add(AgentToolAttr.parse(toolTokens)) 
                }
                _tools = result.toArray()
                return _tools.getOrThrow()
            }
            return []
        }
    }    
} 

/**
 * @ai[...] has the same attributes as @agent[...]
 */
public macro ai(input: Tokens): Tokens {
    let attr = AiAttr()
    return transformAi(input, attr)
}

public macro ai(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = AiAttr.parse(attrTokens)
    let content = transformAi(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform the function
 * @ai[...]
 * foreign func foo(<args>): <ret-ty>
 * AS
 * func foo(<args>): <ret-ty> {
 *   let agent = AiFuncAgent(
 *     ...
 *   )
 *   return agent.run<ret-ty>(question)
 * }
 */
private func transformAi(input: Tokens, attr: AiAttr): Tokens {
    let decl = parseDecl(input)
    if (!decl.isFuncDecl()) {
        throw DslException("@ai should be used on function declarations")
    }
    let funcDecl = decl.asFuncDecl()
    if (!isForeignFunc(funcDecl)) {
        throw DslException("@ai can only be used on foreign functions")
    }
    let modifier = filterModifiers(funcDecl)
    let funcName = newIdentifierToken(funcDecl.identifier.value)
    let funcParams: ArrayList<FuncParam> = funcDecl.funcParams
    let retType = getRetTypeTokens(funcDecl)

    // Iterate all parameters.
    let parameters = ArrayList<Tokens>()
    let arguments = ArrayList<Tokens>()
    for (i in 0..funcParams.size) {
        let param: FuncParam = funcParams[i]
        let paramName: String = param.identifier.value
        let paramTy = param.paramType
        parameters.add(
            quote(($(newLiteralToken(paramName)), $paramTy.getTypeSchema()))
        )
        arguments.add(
            quote($( newIdentifierToken(paramName) ).toJsonValue() )
        )
    }

    let modelTk = if (let Some(v) <- attr.model) {
        newLiteralToken(v)
    } else {
        newIdentifierToken("None")
    }

    let temperatureTk = if (let Some(v) <- attr.temperature) {
        newLiteralToken(v)
    } else {
        newIdentifierToken("None")
    }

    let funcPromptTk = if (let Some(v) <- attr.prompt) {
        newLiteralToken(v)
    } else {
        newIdentifierToken("None")
    }

    let executorTks = if (attr.tools.isEmpty()) {
        quote(AgentExecutorManager.create("naive"))
        // quote(AgentExecutorManager.create("tool-loop"))
    } else {
        quote(AgentExecutorManager.create("tool-loop"))
    }

    let addTools = Tokens()
    for (i in 0..attr.tools.size) {
        match (attr.tools[i]) {
            case AgentToolAttr.StdioMcp(_commandLine, _env) =>
                let commandLine = newLiteralToken(_commandLine)
                let env = joinTokens(
                    _env.iterator() |>
                        map { tuple: (String, Token) =>
                            let key = newLiteralToken(tuple[0])
                            let value = tuple[1]
                            return quote( ($key, $value) )
                        } |>
                        collectArray,
                    Token(TokenKind.COMMA)
                )
                let client = newIdentifierToken("_client_${i}")
                addTools.append(
                    quote(
                        let $client = StdioMCPClient($commandLine, env: [$env])
                        tm.addTools($client.getTools())
                    )
                )
            case AgentToolAttr.HttpMcp(_url) =>
                let url = newLiteralToken(_url)
                let client = newIdentifierToken("_client_${i}")
                addTools.append(
                    quote(
                        let $client = SseMCPClient($url)
                        tm.addTools($client.getTools())
                    )
                )
            case AgentToolAttr.NativeFunc(_tool) =>
                let tool = newIdentifierToken(_tool)
                addTools.append(
                    quote(
                        tm.addTool($tool)
                    )
                )
        }
    }

    return quote (
        func $funcName ( $funcParams ): $retType {
            let tm = SimpleToolManager()
            $addTools
            let agent = AiFuncAgent(
                model: $modelTk,
                temperature: $temperatureTk,
                executor: $executorTks,
                tools: tm.getTools(),
                funcPrompt: $funcPromptTk,
                funcName: $(newLiteralToken(funcName.value)),
                parameters: [$(joinTokens(parameters, Token(TokenKind.COMMA)))],
                retType: $retType.getTypeSchema(),
            )
            return agent.run<$retType>([
                $( joinTokens(arguments, Token(TokenKind.COMMA)) )
            ])
        }
    )
}

private func isForeignFunc(funcDecl: FuncDecl): Bool {
    for (modifier in funcDecl.modifiers) {
        if (modifier.keyword.kind == TokenKind.FOREIGN) {
            return true
        }
    }
    return false
}

private func filterModifiers(funcDecl: FuncDecl): ArrayList<Modifier> {
    let modifiers = funcDecl.modifiers.clone()
    for (i in 0..modifiers.size) {
        if (modifiers[i].keyword.kind == TokenKind.FOREIGN) {
            modifiers.remove(at: i)
            break
        }
    }
    return modifiers
}