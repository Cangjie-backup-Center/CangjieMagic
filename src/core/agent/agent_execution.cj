/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.{ChatRound, MessageList}
import magic.core.rag.RetrievalInfo

import std.collection.ArrayList

/**
 * Provide APIs to access the agent execution information
 */
public interface AgentExecution {
    prop messages: MessageList

    /**
     * Only access this field when setting verbose: true in AgentRequest
     */
    prop verboseInfo: Iterator<String>

    prop retrievalInfo: ArrayList<RetrievalInfo>

    prop chatRound: ChatRound

    func setAnswer(answer: String): Unit
}

