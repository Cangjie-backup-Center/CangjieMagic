/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.agent.{Agent, AgentRequest, AgentExecution, AgentExecutionException}
import magic.core.message.{MessageList, ChatRound, Message, BoundedMessageList}
import magic.core.rag.{Retrieval, RetrievalInfo}
import magic.parser.TagChannel
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
        this.messageList = BoundedMessageList(
            agent.model.contextLength,
            computeFn: { str => return tokenizer.countToken(str) }
        )
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

    protected func addVerboseInfo(info: String): Unit {
        this.verboseChannel.put(info)
    }

    override public func setAnswer(answer: String): Unit {
        this.answer = answer
    }

    protected func addRetrieval(query: String, retrieval: Retrieval): Unit {
        this.retrievalInfo.add(RetrievalInfo(query, retrieval))
    }

    /**
     * A communication channel to transfer verbose information during the agent execution
     */
    protected var _verboseChannel: Option<TagChannel> = None
    private let mutex = Mutex()
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
    override public prop verboseInfo: Iterator<String> {
        get() {
            this.verboseChannel
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

