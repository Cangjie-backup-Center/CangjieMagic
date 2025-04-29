/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.{Agent, AgentTask, AgentExecutionException}
import magic.core.tool.{Tool, ToolManager, ToolException}
import magic.model.ModelUtils
import magic.parser.{OutputParserUtils, ParserException}
import magic.core.message.ChatMessage
import magic.core.tool.ToolRequest
import magic.jsonable.{JsonUtils, Jsonable, ToJsonValue}
import magic.instrumentor.Instrumentor
import magic.log.LogUtils

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject, JsonException}

protected enum FailureLevel {
    | Repairable
    | Fatal
}

protected struct ToolCall {
    protected ToolCall(
        protected let thought!: String,      // Thoughts of choosing the tool
        protected let request!: ToolRequest, // Tool call request
        protected let text!: String          // The original tool call representation
    ) { }

    /**
     * Run the tool and return observation messages
     */
    protected func invoke(task: AgentTask): String {
        let toolManager = task.agent.toolManager
        var observation: String = ""
        // Special treatment for the retriever tool
        if (this.request.name == "__retriever__tool___") {
            // See RetrieverTool
            let query = this.request.args["query"].asString().getValue()
            let retrieval = task.agent.retriever.getOrThrow().search(query)
            task.execInfo.addRetrieval(query, retrieval)
            observation = retrieval.toPrompt()
        } else if (let Some(foundTool) <- toolManager.findTool(this.request.name)) {
            try {
                // Arguments are of type JsonValue, we should convert them as ToJsonValue
                let convertedArgs = HashMap<String, ToJsonValue>()
                for ((argName, argValue) in this.request.args) {
                    convertedArgs.put(argName, argValue)
                }
                var toolResponse = if (let Some(resp) <- Instrumentor.doInstrumentBeforeToolCall(task.agent, this.request)) {
                    resp
                } else {
                    foundTool.invoke(convertedArgs)
                }
                toolResponse = Instrumentor.doInstrumentAfterToolCall(task.agent, this.request, toolResponse)
                observation = toolResponse.content
            } catch (ex: ToolException) {
                observation = "Fail to invoke the tool `${this.request.name}`. Reason: ${ex.reason}"
            } catch (_: Exception) {
                observation = "Fail to invoke the tool `${this.request.name}`"
            }
        } else {
            let names = toolManager.getTools() |> map { t: Tool => t.name } |> collectArray
            observation = "Tool `${this.request.name}` not found in ${names}"
        }
        return observation
    }
}

protected struct FinalAnswer {
    protected FinalAnswer(
        protected let thought!: String, // Thoughts of summarizing the answer
        protected let content!: String   // Content of the answer
    ) { }
}

protected struct FailureInfo {
    protected FailureInfo(
        protected let level: FailureLevel,
        protected let message!: String, // The original failure message
        protected let reason!: String,
        protected let suggestion!: String
    ) { }
}

protected enum ReactStep <: Hashable & Equatable<ReactStep> & ToString {
    | Action(ToolCall)
    | Thought(String)
    | Answer(FinalAnswer)
    | Failure(FailureInfo)

    public func hashCode(): Int64 {
        return match (this) {
            case ReactStep.Action(tc) => tc.text.hashCode()
            case ReactStep.Thought(t) => t.hashCode()
            case ReactStep.Answer(a) => a.content.hashCode()
            case ReactStep.Failure(f) => f.reason.hashCode()
        }
    }

    public operator func ==(rhs: ReactStep): Bool {
        match ((this, rhs)) {
            case (ReactStep.Action(tc1), ReactStep.Action(tc2)) =>
                return tc1.text == tc2.text
            case (ReactStep.Thought(t1), ReactStep.Thought(t2)) =>
                return t1 == t2
            case (ReactStep.Answer(a1), ReactStep.Answer(a2)) =>
                return a1.content == a2.content
            case (ReactStep.Failure(f1), ReactStep.Failure(f2)) =>
                return f1.reason == f2.reason
            case _ => return false
        }
    }

    public operator func !=(rhs: ReactStep): Bool {
        return !(this == rhs)
    }

    public func toString(): String {
        return match (this) {
            case ReactStep.Action(tc) => "${Tag.THOUGHT} ${tc.thought} ${Tag.THOUGHT.getCloseTag()}; ${Tag.ACTION} ${tc.text} ${Tag.ACTION.getCloseTag()}"
            case ReactStep.Thought(t) => "${Tag.THOUGHT} ${t} ${Tag.THOUGHT.getCloseTag()}"
            case ReactStep.Answer(a) => "${Tag.THOUGHT} ${a.thought} ${Tag.THOUGHT.getCloseTag()}; ${Tag.ANSWER} ${a.content} ${Tag.ANSWER.getCloseTag()}"
            case ReactStep.Failure(f) => "[Failure] Original message: ${f.message}; \n Reason: ${f.reason} [/Failure]"
        }
    }

    static func fromStr(content: String): ReactStep {
        let thought = Tag.extract(content, Tag.THOUGHT)
        if (let Some(answer) <- Tag.extract(content, Tag.ANSWER)) {
            return ReactStep.Answer(
                FinalAnswer(thought: thought ?? "",
                            content: answer)
            )
        }
        let action = Tag.extract(content, Tag.ACTION)
        match ((thought, action)) {
            case (_, Some(_action)) =>
                try {
                    let json = OutputParserUtils.extractLastCode(_action, "json").getOrThrow({
                        => ParserException("There is no valid JSON content wrapped by ```json and ```")
                    })
                    let request = OutputParserUtils.parseToolRequest(json)
                    return ReactStep.Action(
                        ToolCall(
                            text: _action,
                            thought: thought ?? "",
                            request: request
                        )
                    )
                } catch (_: JsonException) {
                    LogUtils.error("Tool invocation has invalid syntax")
                    return ReactStep.Failure(
                        FailureInfo(FailureLevel.Repairable,
                                    message: content,
                                    reason: "Tool invocation has invalid syntax",
                                    suggestion: "You must follow the required syntax to use a tool.")
                    )
                } catch (ex: ParserException) {
                    LogUtils.error("Parsing action failed: ${ex.reason}")
                    return ReactStep.Failure(
                        FailureInfo(FailureLevel.Repairable,
                                    message: content,
                                    reason: ex.reason,
                                    suggestion: "You should regenerate to fix the error: `${ex.reason}`")
                    )
                }
            case (Some(_thought), None) =>
                return ReactStep.Thought(_thought)
            case (None, None) =>
                return ReactStep.Failure(
                    FailureInfo(
                        FailureLevel.Repairable,
                        message: content,
                        reason: "Output format is invalid.",
                        suggestion: "You should generate ${Tag.ACTION} or ${Tag.ANSWER}"
                    )
                )
        }
    }
}