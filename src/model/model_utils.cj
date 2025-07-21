/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model

import magic.core.agent.Agent
import magic.core.message.*
import magic.core.model.*
import magic.log.LogUtils
import magic.config.Config
import magic.utils.{getEnv, sleep2}

import std.collection.{filter, collectArray}

//====================================================================================

public struct ModelUtils {
    private static func parseChatResponse(response: ChatResponse): Option<Message> {
        let messages = response.messageList |>
            filter { msg: Message =>
                msg.role == MessageRole.Assistant && !msg.content.isEmpty()
            } |>
            collectArray
        LogUtils.debug("#Response-Message: ${response.messageList.size}; #Assistant-Message: ${messages.size}")
        if (messages.isEmpty()) {
            LogUtils.error("The chat model did not reply a valid assistant message")
            return None
        } else if (messages.size > 1) {
            throw ModelException("There are multiple assistant reply messages")
        }
        let msg = messages[0]
        var content = msg.content
        // If the reasoning content and result content is merged,
        // we may filter the reasoning content if necessary.
        if (Config.filterThink) {
            let tag = "</think>"
            if (let Some(idx) <- msg.content.lastIndexOf(tag)) {
                content = content[(idx + tag.size)..]
            }
        }
        return Message(
            msg.role,
            content,
            name: msg.name,
            image: msg.image,
            reason: msg.reason
        )
    }

    private static func makeChatImpl(model: ChatModel, request: ChatRequest, who!: Option<String> = None): Option<Message> {
        LogUtils.debug('--------------- Begin of chat model request ------------')
        try {
            if (let Some(name) <- who) {
            LogUtils.debug('  --------------- [Request Messages] ------------')
                LogUtils.debug(name, request.messageList)
            } else {
                LogUtils.debug(request.messageList)
            }
            LogUtils.debug('  --------------- [End of Request Messages] ------------')
            // The LLM may return an empty reply?
            for (_ in 0..Config.modelRetryNumber) {
                let response = model.create(request)
                if (let Some(msg) <- ModelUtils.parseChatResponse(response)) {
                    return msg
                }
                // Backoff
                sleep2(500)
            }
            return None
        } finally {
            LogUtils.debug('--------------- End of chat model request ------------')
        }
    }

    public static func makeChat(model: ChatModel,
                                messageList: MessageList,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<Message> {
        let request = ChatRequest(messageList, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request)
    }

    public static func makeChat(name: String,
                                model: ChatModel,
                                messageList: MessageList,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<Message> {
        let request = ChatRequest(messageList, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request, who: name)
    }

    public static func agentMakeChat(agent: Agent, messages: MessageList, stop!: Option<Array<String>> = None): Option<Message> {
        let request = ChatRequest(messages, temperature: agent.temperature, stop: stop)
        return ModelUtils.makeChatImpl(agent.model, request, who: agent.name)
    }
}
