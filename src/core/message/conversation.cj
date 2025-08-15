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
        public let question: Message, // The question message from the user
        public let answer: Message, // The answer message from the assistant
        public let steps: MessageList) {// Optional execution step messages, if any
    }

    override public func toString(): String {
        return "Question: ${question}\nSteps:\n${steps}\nAnswer: ${answer}"
    }
}

public class CompactedConversation {
    public CompactedConversation(
        /**
         * Chat rounds of the conversation
         */
        public let chatRounds: Option<Array<ChatRound>>,

        /**
         * Summary of the conversation
         */
        public let summary: String
    ) { }
}

/**
 * A conversation is a collection of QA chat rounds.
 */
public class Conversation <: Iterable<ChatRound> {
    /**
     * Chat round of the current conversation
     */
    private let chatRounds = ArrayList<ChatRound>()

    /**
     * Previous compacted conversations and their summary
     */
    private let compactedConversations = ArrayList<CompactedConversation>()

    public init() { }

    public init(round: ChatRound) {
        this.addChatRound(round)
    }

    public func addChatRound(round: ChatRound): Unit {
        this.chatRounds.add(round)
    }

    public func addChatRound(question: Message, answer: Message, steps!: MessageList = MessageList()): Unit {
        this.addChatRound(ChatRound(question, answer, steps))
    }

    override public func iterator(): Iterator<ChatRound> {
        return this.chatRounds.iterator()
    }

    public prop compacts: Array<CompactedConversation> {
        get() {
            return this.compactedConversations.toArray()
        }
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

    /**
     * Compact the current conversation and save the summary
     * `keepOrigin` means whether save the original conversation messages
     */
    public func compactBy(compactor: ConversationCompactor, keepOrigin!: Bool = true): String {
        let summary = compactor.compact(this)
        this.compactedConversations.add(
            CompactedConversation(
                if (keepOrigin) { this.chatRounds.toArray() } else { None },
                summary
            )
        )
        // Remove the current conversation
        this.chatRounds.clear()
        return summary
    }
}