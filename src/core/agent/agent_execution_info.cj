/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Dialog
import magic.core.rag.{Retrieval, RetrievalInfo}
import magic.parser.TagChannel

import std.collection.ArrayList
import std.collection.concurrent.BlockingQueue
import std.sync.ReentrantMutex

/**
 * Bookkeeping information during the agent execution
 */
public class AgentExecutionInfo {
    /**
     * Internal chat history between the agent and llm
     */
    public let dialog: Dialog

    /**
     * Retrieved documents during execution
     */
    public let retrievalInfo: ArrayList<RetrievalInfo>

    public init() {
        this.dialog = Dialog()
        this.retrievalInfo = ArrayList<RetrievalInfo>()
    }

    public init(dialog: Dialog) {
        this.dialog = dialog
        this.retrievalInfo = ArrayList<RetrievalInfo>()
    }

    protected func addRetrieval(query: String, retrieval: Retrieval): Unit {
        this.retrievalInfo.append(RetrievalInfo(query, retrieval))
    }

    /**
     * A communication channel to transfer verbose information during the agent execution
     */
    protected var _verboseChannel: Option<TagChannel> = None
    private let mutex = ReentrantMutex()
    protected prop verboseChannel: TagChannel {
        get() {
            synchronized(this.mutex) {
                if (let Some(ch) <- _verboseChannel) { return ch }
                let ch = TagChannel()
                _verboseChannel = ch
                return ch
            }
        }
    }

    /**
     * Only access this field when setting verbose: true in AgentRequest
     */
    public prop verboseInfo: Iterator<String> {
        get() {
            this.verboseChannel
        }
    }
}

