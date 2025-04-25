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
import magic.instrumentor.Instrumentor

import std.collection.{filter, collectArray}

//====================================================================================

public struct ModelUtils {
    private static func parseChatResponse(response: ChatResponse): Option<ChatMessage> {
        let messages = response.dialog |>
            filter { msg: ChatMessage =>
                msg.role == ChatMessageRole.Assistant && !msg.content.isEmpty()
            } |>
            collectArray
        LogUtils.debug("#Response-Message: ${response.dialog.size}; #Assistant-Message: ${messages.size}")
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
        return ChatMessage(
            msg.role,
            content,
            name: msg.name,
            image: msg.image,
            reason: msg.reason
        )
    }

    private static func makeChatImpl(model: ChatModel, request: ChatRequest, who!: Option<String> = None): Option<ChatMessage> {
        if (let Some(response) <- Instrumentor.doInstrumentBeforeChatModel(model, request, who: who)) {
            return ModelUtils.parseChatResponse(response)
        }
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
    }

    public static func makeChat(model: ChatModel,
                                dialog: Dialog,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<ChatMessage> {
        let request = ChatRequest(dialog, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request)
    }

    public static func makeChat(model: ChatModel,
                                messages: Array<ChatMessage>,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<ChatMessage> {
        let request = ChatRequest(Dialog(messages), temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request)
    }

    public static func makeChat(name: String,
                                model: ChatModel,
                                dialog: Dialog,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<ChatMessage> {
        let request = ChatRequest(dialog, temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request, who: name)
    }

    public static func makeChat(name: String,
                                model: ChatModel,
                                messages: Array<ChatMessage>,
                                temperature!: Option<Float64> = None,
                                stop!: Option<Array<String>> = None): Option<ChatMessage> {
        let request = ChatRequest(Dialog(messages), temperature: temperature, stop: stop)
        return ModelUtils.makeChatImpl(model, request, who: name)
    }

    public static func makeChatGet<T>(name: String,
                                      model: ChatModel,
                                      messages: Array<ChatMessage>,
                                      getFn!: (ChatMessage) -> Option<T>): Option<T> {
        LogUtils.info(name, messages)
        if (let Some(msg) <- ModelUtils.makeChat(name, model, messages)) {
            LogUtils.info(name, msg)
            return getFn(msg)
        } else {
            return None
        }
    }

    public static func agentMakeChat(agent: Agent, messages: Array<ChatMessage>): Option<ChatMessage> {
        LogUtils.info(agent.name, messages)
        return ModelUtils.makeChat(agent.name, agent.model, messages)
    }

    public static func agentMakeChatGet<T>(agent: Agent, messages: Array<ChatMessage>,
                                           getFn!: (ChatMessage) -> Option<T>): Option<T> {
        return ModelUtils.makeChatGet<T>(agent.name, agent.model, messages, getFn: getFn)
    }
}
