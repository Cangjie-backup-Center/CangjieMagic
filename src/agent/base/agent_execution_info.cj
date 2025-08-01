/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent.base

import magic.core.agent.*
import magic.core.message.*
import magic.core.rag.{Retrieval, RetrievalInfo}
import magic.parser.TagChannel
import magic.core.interaction.*
import magic.tokenizer.TokenizerLoader

import std.collection.ArrayList
import std.collection.concurrent.BlockingQueue
import std.sync.Mutex

/**
 * Bookkeeping information during the agent execution
 */
public class AgentExecutionInfo <: AgentExecution {
    /**
     * Internal chat messages between the agent and llm
     * These messages represent the execution traces
     */
    private let messageList: MessageList

    private var request: Option<AgentRequest> = None
    private var answer: Option<String> = None
    protected let stepMessages = MessageList()

    /**
     * Retrieved documents during execution
     */
    private let _retrievalInfo = ArrayList<RetrievalInfo>()

    override public prop retrievalInfo: ArrayList<RetrievalInfo> {
        get() { this._retrievalInfo }
    }

    public init(agent: Agent) {
        let tokenizer = TokenizerLoader.default()
        this.messageList = MessageList()
        // Use bounded message list?
        // this.messageList = BoundedMessageList(
        //     agent.model.contextLength,
        //     computeFn: { str => return tokenizer.countToken(str) }
        // )
    }

    override public prop messages: MessageList {
        get() { this.messageList }
    }

    public func addRequest(request: AgentRequest): Unit {
        this.request = request
        this.messageList.addMessage(Message.user(request.question, image: request.image))
    }

    public func addMessage(msg: Message): Unit {
        this.messageList.addMessage(msg)
    }

    public func addMessages(msgs: Array<Message>): Unit {
        for (msg in msgs) {
            this.addMessage(msg)
        }
    }

    public func removeLastMessage(): Unit {
        this.messageList.removeLast()
    }

    public func addStepMessage(msg: Message): Unit {
        this.messageList.addMessage(msg)
        this.stepMessages.addMessage(msg)
    }

    override public func setAnswer(answer: String): Unit {
        this.answer = answer
    }

    protected func addRetrieval(query: String, retrieval: Retrieval): Unit {
        this.retrievalInfo.add(RetrievalInfo(query, retrieval))
    }

    /**
     * A communication channel to transfer verbose events during the agent execution
     * Only access this field when setting `verbose: true` in AgentRequest
     */
    protected var _events: Option<EventStream> = None
    private let mutex = Mutex()
    public prop events: EventStream {
        get() {
            synchronized(this.mutex) {
                if (let Some(value) <- _events) {
                    return value
                }
                let value = EventStream()
                _events = value
                return value
            }
        }
    }

    override public prop chatRound: ChatRound {
        get() {
            let req = this.request.getOrThrow({ => AgentExecutionException("User request is not set") })
            let answer = this.answer.getOrThrow({ => AgentExecutionException("Answer is not set") })
            return ChatRound(
                Message.user(req.question, image: req.image),
                Message.assistant(answer),
                this.stepMessages
            )
        }
    }
}

