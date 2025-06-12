/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.agent_executor.common.AgentTask
import magic.core.message.{Message, MessageList}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.sleep2
import magic.parser.{TagStreamParser, ParserException}

protected class ReactTask <: AgentTask {
    protected init(agent: Agent, request: AgentRequest) {
        super(agent, request)
        this.execution.addMessages(ReactPromptUtils.buildReactPrompt(this))
        this.execution.addQuestion(request.question)
        LogUtils.info(agent.name, "----- Build Agent Task -----")
        LogUtils.info(agent.name, this.execution.messages)
        LogUtils.info(agent.name, "----- End of Build Agent Task -----")
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
                this.addAndLogMessage(Message.assistant(tc.text.withTag(Tag.ACTION)))
                let observation = this.invokeTool(tc.request)
                this.addAndLogMessage(Message.assistant(observation.withTag(Tag.OBSERVATION)))
                if (this.request.verbose) {
                    this.execution.verboseChannel.put(observation, Tag.OBSERVATION)
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

    //------------------------------------------------------

    protected func runOnce(): Option<AgentResponse> {
        LogUtils.info(this.agent.name, "Step #${this.step}")
        this.step += 1
        // Add a hint message
        this.execution.addMessage(
            Message.system("Decide what to do next. Output a pair of ${Tag.THOUGHT} and ${Tag.ACTION}, a pair of ${Tag.THOUGHT} and ${Tag.ANSWER}, or a single ${Tag.ANSWER}")
        )
        let step = this.getNextReactStep()
        // Remove the hint message
        this.execution.removeLastMessage()
        if (let Some(answer) <- handleStep(step)) {
            return AgentResponse(answer, execution: this.execution)
        }
        return None
    }

    private func getNextReactStep(): ReactStep {
        // The LLM may generates [Observation] itself,
        // I.e., it may generate
        // [Thought] ... [Thought]
        // [Action] ... [/Action]
        // [Observation] ... [Observation],
        // so we truncate it with `stop` words.
        try {
            match (ModelUtils.makeChat(this.agent.model,
                                       this.execution.messages,
                                       stop: [Tag.OBSERVATION])) {
                case Some(msg) =>
                    return ReactStep.fromStr(msg.content)
                case None =>
                    return ReactStep.Failure(
                        FailureInfo(
                            FailureLevel.Repairable,
                            message: "",
                            reason: "Fail to get valid assistant response",
                            suggestion: "Follow the guidelines. Generate the ${Tag.THOUGHT} first and then output ${Tag.ACTION} or ${Tag.ANSWER}"
                        )
                    )
            }
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
    protected func summarize(): AgentResponse {
        let messages = ReactPromptUtils.buildReactSummarizePrompt(this)
        let answer = ModelUtils.agentMakeChatGet(this.agent, messages) { msg: Message =>
            Tag.extract(msg.content, Tag.ANSWER)
        }
        return AgentResponse(
            answer.getOrThrow({ => AgentExecutionException("Fail to get chat model response") }),
            execution: this.execution
        )
    }

    //------------------------------------------------------------

    func asyncRunOnce(): Option<AsyncReactAnswer> {
        LogUtils.info(this.agent.name, "Step #${this.step}")
        this.step += 1
        // Add a hint message
        this.execution.addMessage(
            Message.system("Decide what to do next. Output a pair of ${Tag.THOUGHT} and ${Tag.ACTION}, a pair of ${Tag.THOUGHT} and ${Tag.ANSWER}, or a single ${Tag.ANSWER}")
        )
        let asyncReactStep = this.getAsyncReactStep()
        // remove the hint message
        this.execution.removeLastMessage()
        try {
            let tag = asyncReactStep.peekTag()
            if (tag == Tag.THOUGHT) {
                this.handleStep(asyncReactStep.getStepOf(Tag.THOUGHT))
                return None
            } else if (tag == Tag.ACTION) {
                this.handleStep(asyncReactStep.getStepOf(Tag.ACTION))
                return None
            } else if (tag == Tag.ANSWER) {
                if (this.request.verbose) {
                    asyncReactStep.parser.onChunkFn = None
                    // The Tag.ANSWER has been put into the channel by the AsyncStepParser
                    // Put a close tag but does not put the answer
                    this.execution.verboseChannel.put(Tag.ANSWER.getCloseTag())
                    this.execution.verboseChannel.close()
                }
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
        let onChunkFn: Option<(String)->Unit> = if (this.request.verbose) {
            { chunk: String => this.execution.verboseChannel.put(chunk) }
        } else {
            None
        }
        let parser = TagStreamParser(asyncChatResp.iter(withReason: false), onChunkFn: onChunkFn)
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
        if (this.request.verbose) {
            // Put a pair of close tags but does not put the answer
            this.execution.verboseChannel.put("", Tag.ANSWER)
            this.execution.verboseChannel.close()
        }
        let (_, asyncAnswer) = asyncReactStep.getAsyncAnswer()
        return asyncAnswer
    }
}