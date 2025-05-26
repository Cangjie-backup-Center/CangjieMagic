/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.agent.*
import magic.core.tool.Tool
import magic.core.message.{ChatMessage, Dialog}
import magic.core.model.{ChatRequest}
import magic.agent_executor.react.{ReactPromptUtils, ToolCall}
import magic.agent_executor.common.AgentTask
import magic.model.ModelUtils
import magic.prompt.Template
import magic.parser.{Tag, WithTag, OutputParserUtils}
import magic.tool.NativeFuncTool
import magic.log.LogUtils
import magic.jsonable.Jsonable
import magic.jsonable.TypeSchema

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.*

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
    // A special fake tool
    static let ANSWER_TOOL = NativeFuncTool(
        name: "_answer_",
        description: "This is a special tool that can only be used after you complete all the steps and resolve the task. You use this tool to provide the user with the final answer. If you interact with them using this tool without finishing the task, the user will get upset.",
        parameters: [
            ("result", "The final result", TypeSchema.Str)
        ],
        filterable: false
    )

    private static func chatWithOperation(state: ExecutionState,
                                          operationPrompt: String,
                                          stop!: Option<Array<String>>): ChatMessage {
        let agent = state.task.agent
        let dialog = state.execInfo.dialog
        // Prepare input messages
        LogUtils.debug(agent.name, operationPrompt)
        dialog.addMessage(ChatMessage.system(operationPrompt))
        // Call the LLM
        try {
            return ModelUtils.makeChat(agent.model, dialog, stop: stop).getOrThrow({ =>
                AgentExecutionException("Fail to get chat model response")
            })
        } finally {
            dialog.removeLast()
        }
    }

    public static func plan(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        let msg = chatWithOperation(state, PLAN_PROMPT, stop: [])
        // Parse the response and add the message to the state
        LogUtils.info(state.task.agent.name, "Plan: ${msg.content}")
        state.execInfo.dialog.addMessage(ChatMessage.assistant(msg.content.withTag(Tag.THOUGHT))) // Add plan as a thought
        if (state.task.request.verbose) {
            state.execInfo.verboseChannel.put(msg.content.withTag(Tag.PLAN))
        }
        return state
    }

    public static func think(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        let msg = chatWithOperation(state, THINK_PROMPT, stop: [Tag.ACTION, Tag.THOUGHT.getCloseTag()])
        // Parse the response and add the message to the state
        LogUtils.info(state.task.agent.name, "Thought: ${msg.content}")
        state.execInfo.dialog.addMessage(ChatMessage.assistant(msg.content.withTag(Tag.THOUGHT)))
        if (state.task.request.verbose) {
            state.execInfo.verboseChannel.put(msg.content, Tag.THOUGHT)
        }
        return state
    }

    private static func doInvokeTool(state: ExecutionState, message: ChatMessage): ExecutionState {
        LogUtils.info(state.task.agent.name, "Action: ${message.content}")
        // Send verbose information if necessary
        if (state.task.request.verbose) {
            state.execInfo.verboseChannel.put(message.content, Tag.ACTION)
        }
        // If the content does not contain ```json ... ```, treat the content as a json value
        let jsonStr = OutputParserUtils.extractFirstCode(message.content, "json") ?? message.content.trimAscii()
        let json = JsonValue.fromStr(jsonStr).asObject()
        // Parse the content
        let toolRequest = OutputParserUtils.parseToolRequest(jsonStr)
        // The special answer tool means the completion of execution
        if (toolRequest.name == ANSWER_TOOL.name) {
            state.answer = toolRequest.args["result"].asString().getValue()
            return state
        }
        // Execute the tool
        let observation = state.task.invokeTool(toolRequest)
        LogUtils.info(state.task.agent.name, "Observation: ${observation}")
        if (state.task.request.verbose) {
            state.execInfo.verboseChannel.put(observation, Tag.OBSERVATION)
        }
        // Add action and observation to the dialog
        state.execInfo.dialog.addMessage(ChatMessage.assistant("```json\n${jsonStr}\n```".withTag(Tag.ACTION)))
        state.execInfo.dialog.addMessage(ChatMessage.assistant(observation.withTag(Tag.OBSERVATION)))
        return state
    }

    public static func action(state: ExecutionState): ExecutionState {
        if (state.done) {
            return state
        }
        // Inject a special tool
        state.task.agent.toolManager.addTool(ANSWER_TOOL)
        let prompt = ACTION_PROMPT.format([
            ("tools", ReactPromptUtils.buildAgentToolsPrompt(state.task))
        ])
        try {
            let msg = chatWithOperation(state, prompt, stop: [Tag.OBSERVATION])
            // Parse the response
            if (let Some(_reason) <- msg.reason) {
                LogUtils.info(state.task.agent.name, "Reason: ${_reason}")
            }
            return doInvokeTool(state, msg)
        } finally {
            state.task.agent.toolManager.delTool(ANSWER_TOOL)
        }
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
        let msg = chatWithOperation(state, ANSWER_PROMPT, stop: [])
        // Parse the response
        LogUtils.info(state.task.agent.name, "ANSWER: ${msg.content}")
        state.task.execInfo.dialog.addMessage(ChatMessage.assistant(msg.content.withTag(Tag.ANSWER)))
        if (state.task.request.verbose) {
            if (let Some(subtask) <- state.subtask) {
                let answer = "Solve the subtask ${subtask.description}\nAnswer: ${msg.content.withoutTag(Tag.ANSWER)}"
                state.execInfo.verboseChannel.put(answer, Tag.OBSERVATION)
            } else {
                state.execInfo.verboseChannel.put(msg.content, Tag.ANSWER)
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
                let prompt = TOOL_PROMPT.format(
                    ("tool", tool),
                    ("tool_name", tool.name),
                )
                let msg = chatWithOperation(currState, prompt, stop: [])
                currState = doInvokeTool(currState, msg)
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
        let jsonStr = OutputParserUtils.extractFirstCode(msg.content, "json") ?? msg.content.trimAscii()
        let json = JsonValue.fromStr(jsonStr).asObject()
        // Parse the content
        let subtasks = Array<Subtask>.fromJsonValue(json.get("subtasks").getOrThrow())

        return subtasks |> map { subtask: Subtask =>
            if (state.task.request.verbose) {
                let info = "Generate subtask:\n${subtask.toJsonValue().toJsonString()}"
                state.execInfo.verboseChannel.put(info, Tag.THOUGHT)
            }

            // Build the system prompt to solve the subtask
            let prompts = ArrayList<String>()
            prompts.append(state.task.agent.systemPrompt)
            prompts.append("# Guideline")
            prompts.appendAll(subtask.guidelines)
            prompts.append("# Background")
            prompts.append(subtask.background)
            let sysPrompt = String.join(prompts.toArray(), delimiter: "\n")

            let subtaskState = ExecutionState(
                AgentTask(
                    state.task.agent,
                    AgentRequest(subtask.description, verbose: state.task.request.verbose)
                )
            )
            // Set the verbose channel
            subtaskState.task.execInfo._verboseChannel = state.task.execInfo._verboseChannel
            // Save the current state as its parent state
            subtaskState.parent = state
            // Bound with the subtask
            subtaskState.subtask = subtask
            // Add prompts
            subtaskState.execInfo.dialog.addMessage([
                ChatMessage.system(sysPrompt),
                ChatMessage.user(subtask.description)
            ])
            LogUtils.info(state.task.agent.name, subtaskState.execInfo.dialog)
            return subtaskState
        } |> collectArray
    }

    public static func each(op: ExecutionOp): (Array<ExecutionState>) -> Array<ExecutionState> {
        return { states: Array<ExecutionState> =>
            return states |> map { state: ExecutionState =>
                if (let Some(subtask) <- state.subtask) {
                    if (state.task.request.verbose) {
                        let info = "To solve the subtask: ${subtask.description}"
                        state.execInfo.verboseChannel.put(info, Tag.THOUGHT)
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
        state.execInfo.dialog.addMessage(
            ChatMessage.assistant("Multiple subtasks are generated and executed:\n${subtaskDesc}".withTag(Tag.THOUGHT))
        )

        let prompt = SUMMARY_PROMPT.format(
            ("subtasks", subtaskDesc)
        )
        let msg = chatWithOperation(state, prompt, stop: [])
        LogUtils.info(state.task.agent.name, "Subtask Summary: ${msg.content}")
        if (state.task.request.verbose) {
            state.execInfo.verboseChannel.put(msg.content, Tag.OBSERVATION)
        }
        state.execInfo.dialog.addMessage(ChatMessage.assistant(msg.content.withTag(Tag.OBSERVATION)))

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