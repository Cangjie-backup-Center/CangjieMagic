/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Dialog
import magic.core.rag.{Retrieval, RetrievalInfo}

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
    protected var _verboseChannel: Option<SimpleChannel> = None
    private let mutex = ReentrantMutex()
    protected prop verboseChannel: SimpleChannel {
        get() {
            synchronized(this.mutex) {
                if (let Some(ch) <- _verboseChannel) { return ch }
                let ch = SimpleChannel()
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
/**
 * A simple channel to transfer verbose information between threads
 */
protected class SimpleChannel <: Iterator<String> {
    private static const EOF = "__SIMPLE_CHANNEL_EOF__"
    private var finished = false

    private let queue = BlockingQueue<String>()

    public func next(): Option<String> {
        if (finished) {
            return None
        }
        let msg = this.queue.dequeue()
        if (msg == EOF) {
            finished = true
            return None
        } else {
            return msg
        }
    }

    protected func put(msg: String): Unit {
        this.queue.enqueue(msg)
    }

    protected func close(): Unit {
        this.queue.enqueue(EOF)
    }
}

