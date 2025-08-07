/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model

import magic.core.agent.Agent
import magic.core.message.*
import magic.core.model.*
import magic.core.tool.Tool
import magic.log.LogUtils
import magic.config.Config
import magic.utils.{getEnv, sleep2}

import std.collection.{filter, collectArray}

//====================================================================================

public struct ModelUtils {
    private static func parseChatResponse(response: ChatResponse): Option<ChatResponse> {
        let message = response.message
        if (message.role != MessageRole.Assistant) {
            LogUtils.error("The chat model did not reply an assistant message")
            return None
        }
        if (message.content.isEmpty() && response.toolRequest.isNone()) {
            LogUtils.error("The chat model replied an empty message")
            return None
        }
        return response
    }

    private static func makeChatImpl(model: ChatModel, request: ChatRequest, who!: Option<String> = None): Option<ChatResponse> {
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
                                stop!: Option<Array<String>> = None): Option<ChatResponse> {
        let request = ChatRequest(messageList, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request)
    }

    public static func makeChat(name: String,
                                model: ChatModel,
                                messageList: MessageList,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<ChatResponse> {
        let request = ChatRequest(messageList, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request, who: name)
    }

    public static func agentMakeChat(agent: Agent,
                                     messages: MessageList,
                                     stop!: Option<Array<String>> = None,
                                     tools!: Array<Tool> = []): Option<ChatResponse> {
        let request = ChatRequest(messages, temperature: agent.temperature, stop: stop, tools: tools)
        return ModelUtils.makeChatImpl(agent.model, request, who: agent.name)
    }
}
