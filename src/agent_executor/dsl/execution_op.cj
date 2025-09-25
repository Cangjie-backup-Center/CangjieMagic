/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.agent_executor.common.{AgentTask, PromptBuilder, AnswerTool, BuiltinToolUtils}
import magic.core.agent.*
import magic.core.tool.{Tool, ToolRequest}
import magic.core.message.{Message, MessageList}
import magic.core.model.ChatResponse
import magic.config.Config
import magic.model.ModelUtils
import magic.prompt.Template
import magic.parser.{Tag, WithTag, ParserUtils, ParserException}
import magic.log.LogUtils
import magic.jsonable.{Jsonable, TypeSchema, JsonUtils, FromJsonValue, ToJsonValue}

import std.collection.{ArrayList, HashMap, map, collectArray}
import stdx.encoding.json.*

public type ExecutionOp = (ExecutionState) -> ExecutionState

public struct OnCase {
    let condition: String
    let op: ExecutionOp
    let default: Bool

    public init(condition: String, op: ExecutionOp) {
        this.condition = condition
        this.op = op
        this.default = false
    }

    public init(op: ExecutionOp) {
        this.condition = ""
        this.op = op
        this.default = true
    }
}

/**
 * ExecutionOpSet provides a set of operations for executing in the DslExecutor.
 * It includes operations like planning, thinking, invoking tools, and handling subtasks.
 */
public struct ExecutionOpSet {
    private static func chatWithOperation(state: ExecutionState,
                                          operationPrompt: String,
                                          tools!: Array<Tool>,
                                          stop!: Option<Array<String>>): ChatResponse {
        let agent = state.task.agent
        // Prepare input messages
        LogUtils.debug(agent.name, operationPrompt)
        state.execution.addMessage(Message.system(operationPrompt))
        // Call the LLM
        try {
            return state.task.chatLLM(
                state.execution.messages, stop: stop, tools: tools
            )
        } finally {
            state.execution.removeLastMessage()
        }
    }

    private static func chatWithOperation(state: ExecutionState,
                                          operationPrompt: String,
                                          stop!: Option<Array<String>>): Message {
        return chatWithOperation(state, operationPrompt, tools: [], stop: stop).message
    }

    //-----------------------------------------------------------

    public static func plan(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        let msg = chatWithOperation(state, PLAN_PROMPT, stop: [])
        // Parse the response and add the message to the state
        LogUtils.info(state.task.agent.name, "Plan: ${msg.content}")
        state.execution.addStepMessage(
            Message.assistant(msg.content.withTag(Tag.THOUGHT)), // Add plan as a thought
        )
        state.task.notify(Tag.PLAN, msg.content)
        return state
    }

    public static func think(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        let msg = chatWithOperation(state, THINK_PROMPT, stop: [Tag.ACTION, Tag.THOUGHT.close])
        // Parse the response and add the message to the state
        LogUtils.info(state.task.agent.name, "Thought: ${msg.content}")
        state.execution.addStepMessage(
            Message.assistant(msg.content.withTag(Tag.THOUGHT)),
        )
        state.task.notify(Tag.THOUGHT, msg.content)
        return state
    }

    public static func action(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        // Inject the `answer` special tool
        var isInjected = false
        let schema = state.task.request.outputSchema
        let answerTool = BuiltinToolUtils.buildAnswerTool(schema)
        if (state.task.agent.toolManager.findTool(answerTool.name).isNone()) {
            state.task.agent.toolManager.addTool(answerTool)
            isInjected = true
        }
        try {
            let chatResp = if (Config.enableModelToolCall) {
                chatWithOperation(
                    state,
                    getActionPrompt(),
                    tools: state.task.availableTools,
                    stop: [Tag.OBSERVATION]
                )
            } else {
                let prompt = getActionPromptWithTools().format([
                    ("tools", PromptBuilder.buildAgentToolsPrompt(state.task))
                ])
                chatWithOperation(
                    state,
                    prompt,
                    tools: [],
                    stop: [Tag.OBSERVATION]
                )
            }
            return doInvokeTool(state, chatResp)
        } finally {
            // Remove the injected tool
            if (isInjected) {
                state.task.agent.toolManager.delTool(answerTool)
            }
        }
    }

    /**
     * Parse the tool request from the chat response:
     * If the chat response does not contain a tool request,
     * extract the request from the message content
    */
    private static func parseToolRequests(chatResp: ChatResponse): Array<ToolRequest> {
        if (!chatResp.toolRequests.isEmpty()) {
            return chatResp.toolRequests
        }
        // First, try to parse tool request array
        try {
            return ParserUtils.extractToolRequestArray(chatResp.message.content)
        } catch (ex: ParserException) {
            LogUtils.debug("Failed to extract tool request array")
        }
        // Otherwise, try to parse a single tool request
        try {
            let toolRequest = ParserUtils.extractToolRequest(chatResp.message.content)
            return [toolRequest]
        } catch (ex: ParserException) {
            LogUtils.debug("Failed to extract tool request")
            // If function call is enabled and failing to extract the tool request,
            // treat the content as the final answer
            if (Config.enableModelToolCall && !Config.enableJsonRetry) {
                LogUtils.info("Failed to extract tool request. Treat the content as the final answer.")
                return [
                    ToolRequest(
                        name: AnswerTool.NAME,
                        args: JsonUtils.buildJsonObject([
                            ("result", chatResp.message.content)
                        ])
                    )
                ]
            } else {
                throw ex
            }
        }
    }

    private static func doInvokeTool(state: ExecutionState, chatResp: ChatResponse): ExecutionState {
        LogUtils.debug(state.task.agent.name, "To invoke tool: ${chatResp}")
        var toolRequests = try {
            parseToolRequests(chatResp)
        } catch (ex: ParserException) {
            LogUtils.error(state.task.agent.name, "Failed to parse tool request: ${ex.message}")
            let guideline = "The Json object of tool call is invalid. Please think about it and try again."
            if (Config.enableModelToolCall) {
                state.execution.addMessage( // Not add as a step message
                    Message.assistant("${chatResp.message.content}\n")
                )
                state.execution.addMessage(Message.user(guideline))
            } else {
                state.execution.addMessage(
                    Message.assistant("```json\n${chatResp.message.content}\n```".withTag(Tag.ACTION)),
                )
                state.execution.addMessage(Message.user(guideline.withTag(Tag.OBSERVATION)))
            }
            return state

        }
        // We also add reasoning content to the step messages
        if (let Some(reason) <- chatResp.message.reason) {
            Message.assistant(reason) // Without tag?
        }
        // LLM may generate parallel tools to run, but we run them sequentially currently
        // Execute each tool
        LogUtils.info(state.task.agent.name, "Tool call: ${toolRequests.toJsonValue().toJsonString()}")
        // If parallel tool call is disabled, we only run the first tool request
        if (!Config.enableParallelToolCall && toolRequests.size > 1) {
            toolRequests = [toolRequests[0]]
        }
        for (toolRequest in toolRequests) {
            // Add action to the message list
            // If function call is not enabled, we wrap the messages with tags
            // to guide the LLM generating formatted response
            if (Config.enableModelToolCall) {
                state.execution.addStepMessage(
                    Message.assistant("${toolRequest.toJsonValue().toJsonString()}\n")
                )
            } else {
                state.execution.addStepMessage(
                    Message.assistant("```json\n${toolRequest.toJsonValue().toJsonString()}\n```".withTag(Tag.ACTION)),
                )
            }

            // No need to notify the tool request here because it's notified during invoking the tool
            let observation = state.task.invokeTool(toolRequest)
            // Special terminal tools may stop the execution
            if (let Some(stopInfo) <- state.task.stopInfo) {
                // state.task.execution.addStepMessage(Message.assistant(stopInfo.result.withTag(Tag.ANSWER)))
                state.task.notify(Tag.ANSWER, stopInfo.result)
                return state
            }

            // Add tool call result to the message list
            if (Config.enableModelToolCall) {
                state.execution.addStepMessage(
                    Message.user(observation),
                )
            } else {
                state.execution.addStepMessage(
                    Message.user(observation.withTag(Tag.OBSERVATION)),
                )
            }
            LogUtils.info(state.task.agent.name, "Observation: ${observation}")
            state.task.notify(Tag.OBSERVATION, observation)
        }
        return state
    }

    public static func done(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        state.answer = "Task completed!"
        return state
    }

    public static func answer(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        let prompt = state.task.request.outputSchema
            .map { schema =>
                ANSWER_WITH_STRUCTURE_OUTPUT_PROMPT.format([
                    ("output_schema", (schema as TypeSchema).getOrThrow())
                ])
            }
            .getOrDefault({ => ANSWER_PROMPT})
        let msg = chatWithOperation(state, prompt, stop: [])
        // Parse the response
        LogUtils.info(state.task.agent.name, "ANSWER: ${msg.content}")
        // state.task.execution.addStepMessage(Message.assistant(msg.content.withTag(Tag.ANSWER)))
        if (state.task.request.verbose) {
            if (let Some(subtask) <- state.subtask) {
                let answer = "Solve the subtask ${subtask.description}\nAnswer: ${msg.content.withoutTag(Tag.ANSWER)}"
                state.task.notify(Tag.OBSERVATION, answer)
            } else {
                state.task.notify(Tag.OBSERVATION, msg.content)
            }
        }
        state.answer = msg.content.withoutTag(Tag.ANSWER)
        return state
    }

    public static func loop(op: ExecutionOp): ExecutionOp {
        return { state: ExecutionState =>
            var currState = state
            while (true) {
                if (currState.done) {
                    return state
                }
                currState = op(currState)
            }
            return currState
        }
    }

    public static func tool(tools: Array<Tool>): ExecutionOp {
        return { state: ExecutionState =>
            if (state.done) {
                return state
            }
            var currState = state
            for (tool in tools) {
                // Prepare input messages
                let chatResp = if (Config.enableModelToolCall) {
                    chatWithOperation(currState, TOOL_PROMPT, tools: tools, stop: [])
                } else {
                    let prompt = TOOL_PROMPT.format(
                        ("tool", tool.toJsonValue().toJsonString()),
                        ("tool_name", tool.name),
                    )
                    chatWithOperation(currState, prompt, tools: [], stop: [])
                }
                currState = doInvokeTool(currState, chatResp)
            }
            return currState
        }
    }

    public static func divide(state: ExecutionState): Array<ExecutionState> {
        if (state.done) {
            return [state]
        }
        let msg = chatWithOperation(state, DIVIDE_PROMPT, stop: [])
        LogUtils.info(state.task.agent.name, "Subtask Division: ${msg.content}")
        // If the content does not contain ```json ... ```, treat the content as a json value
        let jsonStr = ParserUtils.extractFirstCode(msg.content, "json") ?? msg.content.trimAscii()
        let json = JsonValue.fromStr(jsonStr).asObject()
        // Parse the content
        let subtasks = Array<Subtask>.fromJsonValue(json.get("subtasks").getOrThrow())

        return subtasks |> map { subtask: Subtask =>
            if (state.task.request.verbose) {
                let info = "Generate subtask:\n${subtask.toJsonValue().toJsonString()}"
                state.task.notify(Tag.THOUGHT, info)
            }

            // Build the system prompt to solve the subtask
            let prompts = ArrayList<String>()
            prompts.add(state.task.agent.systemPrompt)
            prompts.add("# Guideline")
            prompts.add(all: subtask.guidelines)
            prompts.add("# Background")
            prompts.add(subtask.background)
            let sysPrompt = String.join(prompts.toArray(), delimiter: "\n")

            let subtaskState = ExecutionState(
                AgentTask(
                    state.task.agent,
                    AgentRequest(subtask.description, verbose: state.task.request.verbose),
                )
            )
            // Set the verbose event stream
            subtaskState.task.execution._events = state.task.execution._events
            // Save the current state as its parent state
            subtaskState.parent = state
            // Bound with the subtask
            subtaskState.subtask = subtask
            // Add prompts
            subtaskState.execution.addMessage(Message.system(sysPrompt))
            subtaskState.execution.addRequest(AgentRequest(subtask.description))
            LogUtils.info(state.task.agent.name, subtaskState.execution.messages)
            return subtaskState
        } |> collectArray
    }

    public static func each(op: ExecutionOp): (Array<ExecutionState>) -> Array<ExecutionState> {
        return { states: Array<ExecutionState> =>
            return states |> map { state: ExecutionState =>
                if (let Some(subtask) <- state.subtask) {
                    if (state.task.request.verbose) {
                        let info = "To solve the subtask: ${subtask.description}"
                        state.task.notify(Tag.THOUGHT, info)
                    }
                }
                op(state)
            } |> collectArray
        }
    }

    private static func buildSubtaskDesc(states: Array<ExecutionState>): String {
        let subtaskDesc = String.join(
            states |> map { state => state.extractSubtaskInfo() } |> collectArray,
            delimiter: ",\n"
        )
        return "Subtasks: [\n${subtaskDesc}\n]"
    }

    public static func summary(states: Array<ExecutionState>): ExecutionState {
        // All sub-states share the same parent state
        let state = states[0].parent.getOrThrow()
        // Build prompt of subtasks
        let subtaskDesc = ExecutionOpSet.buildSubtaskDesc(states)
        state.execution.addStepMessage(
            Message.assistant("Multiple subtasks are generated and executed:\n${subtaskDesc}".withTag(Tag.THOUGHT)),
        )

        let prompt = SUMMARY_PROMPT.format(
            ("subtasks", subtaskDesc)
        )
        let msg = chatWithOperation(state, prompt, stop: [])
        LogUtils.info(state.task.agent.name, "Subtask Summary: ${msg.content}")
        state.task.notify(Tag.OBSERVATION, msg.content)
        state.execution.addStepMessage(
            Message.assistant(msg.content.withTag(Tag.OBSERVATION)),
        )

        return state
    }

    public static func switch(onCases: Array<OnCase>): ExecutionOp {
        return { state: ExecutionState =>
            if (state.done) {
                return state
            }
            for (c in onCases) {
                if (c.default == true) {
                    LogUtils.info(state.task.agent.name, "DEFAULT CASE")
                    return c.op(state)
                }
                let prompt = CHECK_CONDITION_PROMPT.format([
                    ("condition", c.condition)
                ])
                let msg = chatWithOperation(state, prompt, stop: [])
                // Parse the response
                LogUtils.info(state.task.agent.name, "CHECK-CONDITION: ${c.condition} -> ${msg.content}")
                if (msg.content.contains("Conclusion: True")) {
                    return c.op(state)
                }
            }
            LogUtils.info(state.task.agent.name, "NO satisfied cases")
            return state
        }
    }

    public static func switch(onCase: OnCase): ExecutionOp {
        return switch([onCase])
    }

    public static func onCase(condition: String, op: ExecutionOp): OnCase {
        return OnCase(condition, op)
    }

    public static func otherwise(op: ExecutionOp): OnCase {
        return OnCase(op)
    }
}