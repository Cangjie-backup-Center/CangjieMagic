/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{map, collectArrayList}
import std.ast.*

/**
 * @ai[...] has the same attributes as @agent[...]
 */
public macro ai(input: Tokens): Tokens {
    let agentAttr = AgentAttr()
    return transformAi(input, agentAttr)
}

public macro ai(attr: Tokens, input: Tokens): Tokens {
    let agentAttr = AgentAttr.parse(attr)
    let content = transformAi(input, agentAttr)
    if (agentAttr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform the function as quick use of an agent.
 * @ai[...]
 * func foo(<args>{ ... }
 * AS
 * func __prompt_foo(<args>{ ... }
 * @agent[...]
 * class __agent_foo {}
 * func foo(<args>{
 *   let agent = __agent_foo()
 *   let question = __prompt_foo(<args>)
 *   return agent.chat(question)
 * }
 */
func transformAi(input: Tokens, agentAttr: AgentAttr): Tokens {
    let decl = parseDecl(input)
    if (!decl.isFuncDecl()) {
        throw DslException("@ai should be called on function declarations")
    }
    let funcDecl = decl.asFuncDecl()
    let modifier = funcDecl.modifiers
    let promptFuncDecl = parseFuncDecl(transformTemplate(funcDecl.toTokens()))
    let agentName = newIdentifierToken("__agent_of_${funcDecl.identifier.value}")
    let anonymousAgent = transformAgent(quote($modifier class $agentName { }), agentAttr)

    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)
    let args: Tokens = joinTokens(
            getFuncParamNameList(funcDecl) |>
                map({ name: String => newIdentifierToken(name) }) |>
                collectArrayList,
            Token(TokenKind.COMMA)
        )
    let retType = checkFuncRetString(funcDecl)

    return quote(
        $anonymousAgent
        $promptFuncDecl
        $modifier func $(funcDecl.identifier) $genericTypeParam ( $(funcDecl.funcParams) ): $retType $genericConstraint {
            let agent = $agentName()
            let question = $(promptFuncDecl.identifier)($args)
            return agent.chat(question)
        }
    )
}
