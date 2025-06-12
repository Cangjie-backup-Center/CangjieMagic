/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{Message, MessageRole, MessageList}

import std.sync.AtomicBool

public struct AsyncChatChunk <: ToString {
    protected AsyncChatChunk(
        public let message!: Message,
        let done!: Bool = false,
        let usage!: Option<ChatUsage> = None) { }

    override public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("AsyncChatChunk: Usage[${usage.toString()}]\n")
        strBuilder.append("${this.message}")
        strBuilder.toString()
    }
}

/**
 * Wrap the async chat chunks as a string iterator
 */
private class ContentIterator <: Iterator<String> {
    ContentIterator(
        private let asyncChatResp: AsyncChatResponse,
        private let withReason: Bool
    ) { }

    override public func next(): Option<String> {
        return match (this.asyncChatResp.next()) {
            case Some(chunk) =>
                if (withReason) {
                    chunk.message.reason ?? chunk.message.content
                } else {
                    chunk.message.content
                }
            case None => None
        }
    }
}

public class AsyncChatResponse <: ToString {
    public let model: String
    public let chunks: Iterator<AsyncChatChunk>
    // The following fields will be set when the response stream is finished
    private var _usage: Option<ChatUsage> = None
    private let _messageList = MessageList()
    private let finished = AtomicBool(false)

    private var role = MessageRole.Assistant
    private let content = StringBuilder()

    protected init(model: String, chunks: Iterator<AsyncChatChunk>) {
        this.model = model
        this.chunks = chunks
    }

    protected func next(): Option<AsyncChatChunk> {
        if (finished.load()) {
            return None
        }
        while (let Some(chunk) <- chunks.next()) {
            if (chunk.message.role != this.role) {
                throw ModelException("Inconsistent message role")
            }
            content.append(chunk.message.content)
            if (chunk.done) {
                this._messageList.addMessage(
                    Message(this.role, content.toString())
                )
                this._usage = chunk.usage
                finished.store(true)
                return None
            } else {
                return chunk
            }
        }
        throw UnsupportedException("Unreachable")
    }

    public func iter(withReason!: Bool = true): Iterator<String> {
        ContentIterator(this, withReason)
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
    public prop messageList: MessageList {
        get() {
            if (!finished.load()) {
                // Consume all chunks
                while (let Some(_) <- this.next()) { }
            }
            this._messageList
        }
    }

    public func toString(): String {
        if (!finished.load()) {
            return "Unfinished"
        }
        let strBuilder = StringBuilder()
        strBuilder.append("ChatResult: model[${model}] usage[${usage.toString()}]")
        for (msg in this.messageList) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}