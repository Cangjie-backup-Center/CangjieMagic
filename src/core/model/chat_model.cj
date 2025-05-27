/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.ChatMessage
import magic.core.tokenizer.Tokenizer

public interface ChatModel <: Model {

    /**
     * The context length of the chat model
     */
    prop contextLength: Int64

    /**
     * Synchronous API of the chat model
     */
    func create(request: ChatRequest): ChatResponse

    /**
     * Quick usage of the create method
     * Since there is a bug in cjc 0.53.x, we cannot add this method.
     * Fix it later.
     */
    // func create(messages: Array<ChatMessage>): ChatResponse {
    //     return create(ChatRequest(messages))
    // }

    /**
     * Asynchronous API of the chat model
     */
    func asyncCreate(request: ChatRequest): AsyncChatResponse
}
