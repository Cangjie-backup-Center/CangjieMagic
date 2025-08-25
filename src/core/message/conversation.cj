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

    /**
     * Slice the conversation, used by compactBy
     */
    private operator func [](range: Range<Int64>): Conversation {
        let result = Conversation()
        for (chatRound in this.chatRounds[range]) {
            result.chatRounds.add(chatRound)
        }
        return result
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
     * `firstN` means first first N chat rounds to be compact
     * `keepOrigin` means whether save the original conversation messages
     */
    public func compactBy(compactor: ConversationCompactor,
                          firstN!: Option<Int64> = None,
                          keepOrigin!: Bool = true): String {
        let end = min(firstN ?? this.chatRounds.size, this.chatRounds.size)
        // Whether the full conversation is to be compact
        // If so, there is no need to create a new conversation
        let conversation2Compact = if (end == this.chatRounds.size) {
            this
        } else {
            this[0..end]
        }
        let summary = compactor.compact(conversation2Compact)
        this.compactedConversations.add(
            CompactedConversation(
                if (keepOrigin) { conversation2Compact.chatRounds.toArray() } else { None },
                summary
            )
        )
        // Reset the current conversation
        if (end == this.chatRounds.size) {
            this.chatRounds.clear()
        } else {
            this.chatRounds.remove(0..end)
        }
        return summary
    }
}