/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.agent.AgentTask
import magic.core.message.{ChatMessage, Dialog}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.sleep2

protected class ReactTask <: AgentTask {
    protected init(agent: Agent, request: AgentRequest) {
        super(agent, request)
        this.execInfo.dialog.addMessage([
            ChatMessage.system(ReactPromptUtils.buildReactFullSystemPrompt(this)),
            ChatMessage.user(request.question)
        ])
        LogUtils.info(agent.name, "----- Build Agent Task -----")
        LogUtils.info(agent.name, this.execInfo.dialog)
        LogUtils.info(agent.name, "----- End of Build Agent Task -----")
    }

    /**
     * Internal auxiliary method
     */
    private func addAndLogMessage(msg: ChatMessage): Unit {
        this.execInfo.dialog.addMessage(msg)
        LogUtils.info(this.agent.name, msg)
    }

    /**
     * If the answer is generated, return its value;
     * otherwise, just add messages to the dialog
     */
    private func handleStep(step: ReactStep): Option<String> {
        match (step) {
            case ReactStep.Thought(thought) =>
                this.addAndLogMessage(ChatMessage.assistant(thought.withTag(THOUGHT_TAG)))
            case ReactStep.Action(tu) =>
                for (msg in tu.invoke(this)) {
                    this.addAndLogMessage(msg)
                }
            case ReactStep.Answer(answer) =>
                if (answer.thought != "") {
                    addAndLogMessage(ChatMessage.assistant(answer.thought.withTag(THOUGHT_TAG)))
                }
                addAndLogMessage(ChatMessage.assistant(answer.content.withTag(ANSWER_TAG)))
                return answer.content
            case ReactStep.Failure(failureInfo) =>
                match (failureInfo.level) {
                    case FailureLevel.Repairable =>
                        // If the model returns an empty reply, just retry;
                        // else, add hint messages to fix.
                        if (!failureInfo.message.isEmpty()) {
                            // Add the reply message to the dialog and fix the failure
                            addAndLogMessage(ChatMessage.assistant(failureInfo.message))
                            addAndLogMessage(ChatMessage.user( // and add the repair message
                                "Output is invalid because ${failureInfo.reason}. ${failureInfo.suggestion}"
                            ))
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
        this.execInfo.dialog.addMessage(
            ChatMessage.system("Decide what to do next. Output [Thought], [Action], or [Final Answer]")
        )
        let step = this.getNextReactStep()
        // Remove the hint message
        this.execInfo.dialog.removeLast()
        if (let Some(answer) <- handleStep(step)) {
            return AgentResponse(answer, execInfo: this.execInfo)
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
                                       this.execInfo.dialog,
                                       stop: ["[Observation]"])) {
                case Some(msg) =>
                    return ReactStep.fromStr(msg.content)
                case None =>
                    return ReactStep.Failure(
                        FailureInfo(
                            FailureLevel.Repairable,
                            message: "",
                            reason: "Fail to get valid assistant response",
                            suggestion: "Follow the guidelines. Generate the [Thought] first and then output [Action] or [Final Answer]"
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

    //------------------------------------------------------------

    func asyncRunOnce(): Option<AsyncReactFinalAnswer> {
        LogUtils.info(this.agent.name, "Step #${this.step}")
        this.step += 1
        // Add a hint message
        this.execInfo.dialog.addMessage(
            ChatMessage.system("Decide what to do next. Output [Thought], [Action], or [Final Answer]")
        )
        let asyncReactStep = this.getAsyncReactStep()
        // remove the hint message
        this.execInfo.dialog.removeLast()
        let tag = asyncReactStep.peekTag()
        if (tag == THOUGHT_TAG) {
            this.handleStep(asyncReactStep.getStepOf(THOUGHT_TAG))
            return None
        } else if (tag == ACTION_TAG) {
            this.handleStep(asyncReactStep.getStepOf(ACTION_TAG))
            return None
        } else if (tag == ANSWER_TAG) {
            if (this.request.verbose) {
                this.execInfo.verboseChannel.put("\n")
                this.execInfo.verboseChannel.put(ANSWER_TAG.getCloseTag())
                this.execInfo.verboseChannel.close()
                asyncReactStep.reader.enableVerbose = false
            }
            let (thought, asyncAnswer) = asyncReactStep.getAsyncFinalAnswer()
            this.addAndLogMessage(ChatMessage.assistant(thought))
            return asyncAnswer
        } else {
            throw UnsupportedException()
        }
    }

    private func getAsyncReactStep(): AsyncReactStep {
        // The LLM may generates [Observation] itself,
        // I.e., it may generate
        // [Thought] ... [Thought]
        // [Action] ... [/Action]
        // [Observation] ... [Observation],
        // so we truncate it with `stop` words.
        let asyncChatResp = agent.model.asyncCreate(
            ChatRequest(this.execInfo.dialog, stop: ["[Observation]"])
        )
        let verboseFn: Option<(String)->Unit> = if (this.request.verbose) {
            { data: String => this.execInfo.verboseChannel.put(data) }
        } else {
            None
        }
        let reader = AsyncReactStepReader(asyncChatResp, verboseFn: verboseFn)
        reader.enableVerbose = this.request.verbose
        return AsyncReactStep(reader)
    }
}