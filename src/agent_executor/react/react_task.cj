/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.agent_executor.common.{AgentTask, PromptBuilder}
import magic.core.message.{Message, MessageList}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.sleep2
import magic.parser.{TagStreamParser, ParserException, WithTag, Tag}

protected class ReactTask <: AgentTask {
    protected init(agent: Agent, request: AgentRequest) {
        super(agent, request)

        PromptBuilder()
            .system(ReactPromptUtils.buildReactSystemPrompt(this))
            .tool(PromptBuilder.buildAgentToolsPrompt(this))
            .system(this.agent.systemPrompt)
            .retrieval(PromptBuilder.buildAgentRetrievalPrompt(this))
            .memory(PromptBuilder.buildAgentMemoryPrompt(this))
            .conversation(request.conversation, withStepMessage: true)
            .request(request)
            .fillTo(this)
    }

    /**
     * Internal auxiliary method
     */
    private func addAndLogMessage(msg: Message, step!: Bool = true): Unit {
        if (step) {
            this.execution.addStepMessage(msg)
        } else {
            this.execution.addMessage(msg)
        }
        LogUtils.info(this.agent.name, msg)
    }

    /**
     * If the answer is generated, return its value;
     * otherwise, just add messages to the messageList
     */
    private func handleStep(step: ReactStep): Option<String> {
        match (step) {
            case ReactStep.Thought(thought) =>
                this.addAndLogMessage(Message.assistant(thought.withTag(Tag.THOUGHT)))
            case ReactStep.Action(tc) =>
                if (tc.thought != "") {
                    this.addAndLogMessage(Message.assistant(tc.thought.withTag(Tag.THOUGHT)))
                }
                // LLM may generate parallel tools to run, but we run them sequentially currently
                this.addAndLogMessage(Message.assistant(tc.text.withTag(Tag.ACTION)))
                for (toolRequest in tc.requests) {
                    let observation = this.invokeTool(toolRequest)
                    this.addAndLogMessage(Message.assistant(observation.withTag(Tag.OBSERVATION)))
                    this.notify(Tag.OBSERVATION, observation)
                }
            case ReactStep.Answer(answer) =>
                if (answer.thought != "") {
                    addAndLogMessage(Message.assistant(answer.thought.withTag(Tag.THOUGHT)))
                }
                return answer.content
            case ReactStep.Failure(failureInfo) =>
                match (failureInfo.level) {
                    case FailureLevel.Repairable =>
                        // If the model returns an empty reply, just retry;
                        // else, add hint messages to fix.
                        if (!failureInfo.message.isEmpty()) {
                            // Add the reply message to the messageList and fix the failure
                            addAndLogMessage(Message.assistant(failureInfo.message), step: false)
                            addAndLogMessage( // and add the repair message
                                Message.user("Output is invalid because ${failureInfo.reason}. ${failureInfo.suggestion}"),
                                step: false
                            )
                        } else {
                            LogUtils.info(this.agent.name, "React backoff")
                            sleep2(1000) // Backoff when getting empty messages
                        }
                    case FailureLevel.Fatal =>
                        throw AgentExecutionException(failureInfo.reason)
                }
        }
        return None
    }

    private func notifyStep(step: ReactStep): Unit {
        match (step) {
            case Action(toolCall) =>
                if (!toolCall.thought.isEmpty()) {
                    this.notify(Tag.THOUGHT, toolCall.thought)
                }
                // tool call is notified in its own event handler
            case Thought(thought) =>
                this.notify(Tag.THOUGHT, thought)
            case Answer(answer) =>
                if (!answer.thought.isEmpty()) {
                    this.notify(Tag.THOUGHT, answer.thought)
                }
                this.notify(Tag.ANSWER, answer.content)
            case Failure(_) => ()
        }
    }

    //------------------------------------------------------
    protected func runOnce(): Option<String> {
        LogUtils.info(this.agent.name, "Run Step")
        let step = try {
            // Add a hint message
            this.execution.addMessage(
                Message.system(REACT_STEP_PROMPT)
            )
            this.getNextReactStep()
        } finally {
            // Remove the hint message
            this.execution.removeLastMessage()
        }

        this.notifyStep(step)
        if (let Some(answer) <- handleStep(step)) {
            return answer
        } else {
            return None
        }
    }

    private func getNextReactStep(): ReactStep {
        // The LLM may generates [Observation] itself,
        // I.e., it may generate
        // [Thought] ... [Thought]
        // [Action] ... [/Action]
        // [Observation] ... [Observation],
        // so we truncate it with `stop` words.
        try {
            let msg = this.chatLLM(this.execution.messages, stop: [Tag.OBSERVATION]).message
            return ReactStep.fromStr(msg.content)
        } catch (ex: Exception) {
            LogUtils.error(this.agent.name, ex.toString())
            return ReactStep.Failure(
                FailureInfo(
                    FailureLevel.Fatal,
                    message: "",
                    reason: "Fail to get chat model response",
                    suggestion: ""
                )
            )
        }
    }

    /**
     * Summarize an answer according to the react execution history.
     **/
    protected func summarize(): String {
        let messages = MessageList(
            ReactPromptUtils.buildReactSummarizePrompt(this)
        )
        let msg = this.chatLLM(messages).message
        return Tag.extract(msg.content, Tag.ANSWER).getOrThrow({ =>
            AgentExecutionException("Chat model response has no answers")
        })
    }

    //-----------------------------------------------------------------------------------------
    // The following methods are used to implement asynchronous execution,
    // but these are outdated implementations with bugs (they may directly pass incorrect LLM outputs to verbose info).
    // These methods are currently not in use and are temporarily retained for reference.
    func asyncRunOnce(): Option<AsyncReactAnswer> {
        LogUtils.info(this.agent.name, "Run Step")
        // Add a hint message
        this.execution.addMessage(
            Message.system(REACT_STEP_PROMPT)
        )
        let asyncReactStep = this.getAsyncReactStep()
        // remove the hint message
        this.execution.removeLastMessage()
        try {
            let tag = asyncReactStep.peekTag()
            if (tag == Tag.THOUGHT || tag == Tag.ACTION) {
                let step = asyncReactStep.getStepOf(tag)
                this.handleStep(step)
                this.notifyStep(step)
                return None
            } else if (tag == Tag.ANSWER) {
                let (thought, asyncAnswer) = asyncReactStep.getAsyncAnswer()
                if (!thought.trimAscii().isEmpty()) {
                    this.addAndLogMessage(Message.assistant(thought))
                }
                return asyncAnswer
            } else {
                throw UnsupportedException()
            }
        } catch (ex: ParserException) {
            // Add the repair message
            this.execution.addMessage(
                Message.system("You should generate valid tags of required syntax!")
            )
            return None
        }
    }

    private func getAsyncReactStep(): AsyncReactStep {
        // The LLM may generates [Observation] itself,
        // I.e., it may generate
        // [Thought] ... [/Thought]
        // [Action] ... [/Action]
        // [Observation} ... [/Observation],
        // so we truncate it with `stop` words.
        let asyncChatResp = agent.model.asyncCreate(
            ChatRequest(this.execution.messages, stop: [Tag.OBSERVATION])
        )
        let parser = TagStreamParser(asyncChatResp.iter(withReason: false))
        return AsyncReactStep(parser)
    }

    /**
     * Summarize an answer according to the react execution history.
     **/
    func asyncSummarize(): AsyncReactAnswer {
        let asyncChatResp = agent.model.asyncCreate(
            ChatRequest(ReactPromptUtils.buildReactSummarizePrompt(this))
        )
        let parser = TagStreamParser(asyncChatResp.iter())
        let asyncReactStep = AsyncReactStep(parser)
        let (_, asyncAnswer) = asyncReactStep.getAsyncAnswer()
        return asyncAnswer
    }
}