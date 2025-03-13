/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.message

import std.collection.ArrayList

/**
 * A collection of chat messages
 */
public class Dialog <: ToString & Iterable<ChatMessage> {
    private let messages: ArrayList<ChatMessage>

    public init() {
        this.messages = ArrayList<ChatMessage>()
    }

    public init(messages: ArrayList<ChatMessage>) {
        this.messages = messages.clone()
    }

    public init(messages: Array<ChatMessage>) {
        this.messages = ArrayList<ChatMessage>(messages)
    }

    public func clone(): Dialog {
        return Dialog(messages.clone())
    }

    public func addMessage(msg: ChatMessage): Unit {
        messages.append(msg)
    }

    public func addMessage(messages: Array<ChatMessage>): Unit {
        this.messages.appendAll(messages)
    }

    public func clear(): Unit {
        messages.clear()
    }

    public func removeLast(): ChatMessage {
        if (messages.isEmpty()) {
            throw Exception("Remove the last message from an empty history")
        }
        return messages.remove(messages.size-1)
    }

    public func iterator(): Iterator<ChatMessage> {
        return messages.iterator()
    }

    public operator func[](index: Int64): ChatMessage {
        return messages[index]
    }

    public prop size: Int64 {
        get() { messages.size }
    }

    public func isEmpty(): Bool {
        messages.isEmpty()
    }

    public func toString(): String {
        let strBuilder = StringBuilder()
        for (msg in messages) {
            strBuilder.append(msg.toString())
        }
        return strBuilder.toString()
    }
}
