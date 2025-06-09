/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.message

import std.collection.{ArrayList}

/**
 * A collection of chat messages
 */
public open class MessageList <: ToString & Iterable<Message> {
    protected let messages: ArrayList<Message>

    public init() {
        this.messages = ArrayList<Message>()
    }

    public init(messages: Collection<Message>) {
        this.messages = ArrayList<Message>(messages)
    }

    public open func addMessage(msg: Message): Unit {
        messages.append(msg)
    }

    public open func removeLast(): Message {
        if (messages.isEmpty()) {
            throw Exception("Remove the last message from an empty history")
        }
        return messages.remove(messages.size - 1)
    }

    public func addMessages(messages: Array<Message>): Unit {
        for (msg in messages) {
            this.addMessage(msg)
        }
    }

    public func clear(): Unit {
        messages.clear()
    }

    public func iterator(): Iterator<Message> {
        return messages.iterator()
    }

    public operator func [](index: Int64): Message {
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
            strBuilder.append("\n")
        }
        return strBuilder.toString()
    }

    public func toArray(): Array<Message> {
        return messages.toArray()
    }
}
