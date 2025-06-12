/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{ArrayList, map, collectArray}
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
 * func foo(<args>) { ... }
 * AS
 * func __prompt_foo(<args>) { ... }

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
    let promptFuncDecl = parseFuncDecl(transformPromptFunc(funcDecl))
    let agentName = newIdentifierToken("__agent_of_${funcDecl.identifier.value}")
    let anonymousAgent = transformAgent(quote($modifier class $agentName { }), agentAttr)

    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)
    let args: Tokens = joinTokens(
        getFuncParamNames(funcDecl) |>
            map { name: String => newIdentifierToken(name) } |>
            collectArray,
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

/**
 * Rename the template function
 * and insert a `StringBuilder` to the function body.
 */
func transformPromptFunc(funcDecl: FuncDecl): Tokens {
    // Make sure that there is no `return`s in the template function.
    if (hasReturnExpr(funcDecl)) {
        throw DslException("Template functions cannot contain return expressions.")
    }
    let modifier = funcDecl.modifiers
    let name = funcDecl.identifier
    let newName = newIdentifierToken("${name.value}${TEMPLATE_FUNC_NAME_POSTFIX}")
    let paramList = funcDecl.funcParams
    let retType = checkFuncRetString(funcDecl)
    let funcBody = funcDecl.block.nodes
    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)

    return quote (
        $modifier func $newName $genericTypeParam ( $paramList ): $retType $genericConstraint {
            let $PROMPT_BUILDER = StringBuilder()
            $funcBody
            return $PROMPT_BUILDER.toString()
        }
    )
}


/**
 * Check whether the return type of a function is String.
 */
func checkFuncRetString(funcDecl: FuncDecl): Token {
    try {
        let ty = funcDecl.declType
        if (!ty.isRefType()) {
            eprintln("Function ${funcDecl.identifier.value} should return String")
            return Token(TokenKind.IDENTIFIER, "String")
        }
        let refTy: RefType = ty.asRefType()
        let id = refTy.identifier
        if (!(id.kind == TokenKind.IDENTIFIER && id.value == "String")) {
            eprintln("Function ${funcDecl.identifier.value} should return String")
        }
        return Token(TokenKind.IDENTIFIER, "String")
    } catch (_: ASTException) {
        return Token(TokenKind.IDENTIFIER, "String")
    }
}