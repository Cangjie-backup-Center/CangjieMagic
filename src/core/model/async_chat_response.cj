/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{ChatMessage, ChatMessageRole, Dialog}

import std.sync.AtomicBool

public struct AsyncChatChunk {
    public AsyncChatChunk(
        let message!: ChatMessage,
        let done!: Bool = false,
        let usage!: Option<ChatUsage> = None) { }
}

public class AsyncChatResponse <: Iterator<String> & ToString {
    public let model: String
    public let chunks: Iterator<AsyncChatChunk>
    // The following fields will be set when the response stream is finished
    private var _usage: Option<ChatUsage> = None
    private let _chatHistory = Dialog()
    private let finished = AtomicBool(false)

    private var role = ChatMessageRole.Assistant
    private let content = StringBuilder()

    public init(model: String, chunks: Iterator<AsyncChatChunk>) {
        this.model = model
        this.chunks = chunks
    }

    override public func next(): Option<String> {
        if (finished.load()) {
            return None
        }
        while (let Some(chunk) <- chunks.next()) {
            if (chunk.message.role != this.role) {
                throw ModelException("Inconsistent message role")
            }
            content.append(chunk.message.content)
            if (chunk.done) {
                this._chatHistory.addMessage(
                    ChatMessage(this.role, content.toString())
                )
                this._usage = chunk.usage
                finished.store(true)
                return None
            } else {
                return chunk.message.content
            }
        }
        throw UnsupportedException("Unreachable")
    }

    public prop stream: Iterator<String> {
        get() { this }
    }

    public prop usage: Option<ChatUsage> {
        get() {
            if (!finished.load()) {
                return None
            } else {
                _usage
            }
        }
    }

    /**
     * This method is synchronous, it will wait until the chat response completes.
     */
    public prop dialog: Dialog {
        get() {
            if (!finished.load()) {
                // Consume all chunks
                for (_ in this) { }
            }
            this._chatHistory
        }
    }

    public func toString(): String {
        if (!finished.load()) {
            return "Unfinished"
        }
        let strBuilder = StringBuilder()
        strBuilder.append("ChatResult: model[${model}] usage[${usage.toString()}]")
        for (msg in this.dialog) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}