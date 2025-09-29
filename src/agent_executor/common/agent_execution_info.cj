/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.agent.*
import magic.core.message.*
import magic.core.rag.{Retrieval, RetrievalInfo}
import magic.parser.TagChannel
import magic.core.interaction.*
import magic.tokenizer.TokenizerLoader
import magic.log.LogUtils

import std.collection.ArrayList
import std.sync.{Mutex, AtomicBool}

/**
 * Bookkeeping information during the agent execution
 */
public class AgentExecutionInfo <: AgentExecution {
    /**
     * Internal chat messages between the agent and llm
     * These messages represent the execution traces
     */
    private let messageList: MessageList

    /**
     * The agent request, which is the user question
     */
    private var request: Option<AgentRequest> = None

    /**
     * The final answer of the agent, which is set by the agent executor
     */
    private var answer: Option<String> = None

    /**
     * Messages about solving the request, which are used to build the chat round
     * Some messages (like error-fixing messages) are excluded
     */
    protected let stepMessages = MessageList()

    /**
     * Retrieved documents during execution
     */
    private let _retrievalInfo = ArrayList<RetrievalInfo>()

    /**
     * The cancellation mark
     */
    private let cancellation = AtomicBool(false)

    /**
     * A communication channel to transfer verbose events during the agent execution
     * Only access this field when setting `verbose: true` in AgentRequest
     */
    protected var _events: Option<EventStream> = None

    public init(agent: Agent, request: AgentRequest) {
        let tokenizer = TokenizerLoader.default()
        this.messageList = MessageList()
        this._events = request.eventStream
        // Use bounded message list?
        // this.messageList = BoundedMessageList(
        //     agent.model.contextLength,
        //     computeFn: { str => return tokenizer.countToken(str) }
        // )
    }

    /**
     * Use the same prop name as thread for convention
     */
    protected prop hasPendingCancellation: Bool {
        get() { this.cancellation.load() }
    }

    override public func markCancellation(): Unit {
        LogUtils.debug("Mark cancellation for the agent execution")
        this.cancellation.store(true)
    }

    override public prop retrievalInfo: ArrayList<RetrievalInfo> {
        get() { this._retrievalInfo }
    }

    override public prop messages: MessageList {
        get() { this.messageList }
    }

    public func addRequest(request: AgentRequest): Unit {
        this.request = request

        // Add previous execution messages from the parent agent if any
        if (let Some(parentContext) <- request.parentContext) {
            let strBuilder = StringBuilder("--- Previous Context ---\n")
            for (msg in parentContext) {
                strBuilder.append("${msg}\n")
            }
            strBuilder.append("--- End of Previous Context ---\n")
            this.messageList.addMessage(Message.assistant(strBuilder.toString()))
        }
        // Remove the @ tags from the question
        var newQuestion = request.question
        // Merge all imported files
        let strBuilder = StringBuilder()
        for ((path, content) in request.importedFiles) {
            newQuestion = newQuestion.replace("@${path}", path.toString()) // Remove the @ tag
            strBuilder.append(
                "<file-content path=${path}>\n${content}\n</file-content>\n"
            )
        }
        // Add messages in the following order:
        // 1. Add the user question as the first user message
        this.messageList.addMessage(Message.user(newQuestion, image: request.image))
        // 2. Add imported files as user messages
        // Note that the imported file are separated from the user question
        // This is to avoid imported files being put to next chat rounds
        if (strBuilder.size > 0) {
            this.messageList.addMessage(Message.user(strBuilder.toString()))
        }

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

