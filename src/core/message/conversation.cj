/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.message

import std.collection.{ArrayList}

/**
 * A single chat round in a conversation, consisting of a question and an answer
 * along with the optional execution step messages.
 */
public struct ChatRound <: ToString {
    public ChatRound(
        public let question: String, // The question message from the user
        public let answer: String, // The answer message from the assistant
        public let steps: MessageList) {// Optional execution step messages, if any
    }

    override public func toString(): String {
        return "Question: ${question}\nSteps:\n${steps}\nAnswer: ${answer}"
    }
}

/**
 * A conversation is a collection of QA chat rounds.
 */
public class Conversation <: Iterable<ChatRound> {
    private let chatRounds = ArrayList<ChatRound>()

    public init() { }

    public init(round: ChatRound) {
        this.addChatRound(round)
    }

    public func addChatRound(round: ChatRound): Unit {
        this.chatRounds.add(round)
    }

    public func addChatRound(question: String, answer: String, steps!: MessageList = MessageList()): Unit {
        this.addChatRound(ChatRound(question, answer, steps))
    }

    override public func iterator(): Iterator<ChatRound> {
        return this.chatRounds.iterator()
    }

    public operator func [](index: Int64): ChatRound {
        return this.chatRounds[index]
    }

    public prop size: Int64 {
        get() { this.chatRounds.size }
    }

    public func isEmpty(): Bool {
        return this.chatRounds.isEmpty()
    }

    public func clear(): Unit {
        this.chatRounds.clear()
    }
}