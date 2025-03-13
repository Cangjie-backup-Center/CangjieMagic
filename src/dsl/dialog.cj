/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*

class DialogAttr <: Attr {
    DialogAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    prop agent: Tokens {
        get() { getTokens("agent").getOrThrow() }
    }

    static func parse(attrTokens: Tokens): DialogAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "dialog",
            validKeys: ["agent"],
        )
        return DialogAttr(map)
    }
}

public macro dialog(input: Tokens): Tokens {
    let emptyAttr = DialogAttr()
    return transformDialog(input, emptyAttr)
}

public macro dialog(attr: Tokens, input: Tokens): Tokens {
    let dialogAttr = DialogAttr.parse(attr)
    let content = transformDialog(input, dialogAttr)
    if (dialogAttr.dump) {
        printTokens(content)
    }
    return content
}

func transformDialog(input: Tokens, dialogAttr: DialogAttr): Tokens {
    // 1. Process dialog-related tokens
    var transformedTokens = transformDialogTokens(input)
    // 3. Wrap the dialog into a lambda function (as its scope) and call it immediately
    // 4. transform if the last expression is an infer expression
    let lambda = quote({ => $transformedTokens })
    // Compose as a call of the lambda
    return quote(
        { =>
            let __CURR_DIALOG__ = Dialog()
            let __CURR_AGENT__ = $(dialogAttr.agent)
            $transformedTokens
        }()
    )
}

func transformDialogTokens(tokens: Tokens): Tokens {
    let transformedTokens = Tokens()
    var (lastPos, currPos) = (-1, 0)
    while (currPos < tokens.size) {
        let currToken = tokens[currPos]
        match (currToken.kind) {
            case TokenKind.RSHIFT => // >>
                transformedTokens.append(quote(
                    __CURR_DIALOG__.clear()
                ))
            case TokenKind.ARROW => // ->
                if (lastPos >= 0 && tokens[lastPos].kind == TokenKind.STRING_LITERAL) {
                    // Remove the last token that is appended during the previous iteration
                    transformedTokens.remove(transformedTokens.size - 1)
                    // Parse the chat expression and append its transformed tokens
                    let (chatExprTokens, endPos) = ChatExprParser.parse(tokens, lastPos)
                    currPos = endPos // We may set lastPos = -1 here?
                    transformedTokens.append(chatExprTokens)
                } else {
                    transformedTokens.append(currToken)
                }
            case _ =>
                transformedTokens.append(currToken)
        }
        lastPos = currPos
        currPos += 1
    }
    return transformedTokens
}

/**
 * Parsing "..." -> variable [: type]?
 **/
class ChatExprParser <: Parser {
    init(tokens: Tokens, currPos: Int64) {
        super(tokens, currPos: currPos)
    }

    func doParse(): (Tokens, Int64) {
        // "..." -> <var> [':' <type>]?
        let chatMessage = currToken
        skipCurrToken(TokenKind.STRING_LITERAL)
        skipCurrToken(TokenKind.ARROW)
        let varToken = currToken
        let tempToken = newIdentifierToken("${currToken.value}__TEMP__")
        let content = match (parseType()) {
            case Some(ty) =>
                quote(
                    let $tempToken = __CURR_AGENT__.chatGet<$ty>(AgentRequest($chatMessage, dialog: __CURR_DIALOG__))
                    __CURR_DIALOG__.addMessage(ChatMessage.user($chatMessage))
                    match ($tempToken) {
                        case Some(v) =>
                            __CURR_DIALOG__.addMessage(ChatMessage.assistant(v.toJsonValue().toJsonString()))
                        case None =>
                            __CURR_DIALOG__.addMessage(ChatMessage.assistant("Generate JSON object failed"))
                    }
                    let $varToken = $tempToken.getOrThrow()
                )
            case None =>
                quote(
                    let $varToken = __CURR_AGENT__.chat(AgentRequest($chatMessage, dialog: __CURR_DIALOG__)).content
                    __CURR_DIALOG__.addMessage(ChatMessage.user($chatMessage))
                    __CURR_DIALOG__.addMessage(ChatMessage.assistant($varToken))
                )
        }
        return (content, currPos)
    }

    func parseType(): Option<Tokens> {
        if (!lookupNextToken(TokenKind.COLON)) {
            return None
        }
        skipNextToken(TokenKind.COLON)
        // Collect tokens until meeting a newline
        let result = Tokens()
        while (currToken.kind != TokenKind.NL) {
            result.append(currToken)
            forwardPosition(skipNL: false)
        }
        if (result.size == 0) {
            throw DslException("Parse chat expression error. Missing type.")
        }
        return result
    }

    static func parse(tokens: Tokens, currPos: Int64): (Tokens, Int64) {
        let parser = ChatExprParser(tokens, currPos)
        return parser.doParse()
    }
}
