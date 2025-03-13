/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.{Agent, AgentTask, AgentExecutionException}
import magic.core.tool.{Tool, ToolManager, ToolException}
import magic.model.ModelUtils
import magic.parser.OutputParserUtils
import magic.core.message.ChatMessage
import magic.jsonable.{JsonUtils, Jsonable, ToJsonValue}

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.JsonValue
import encoding.json.JsonObject

protected enum FailureLevel {
    | Repairable
    | Fatal
}

protected struct ToolUsage {
    protected ToolUsage(
        protected let thought!: String, // Thoughts of choosing the tool
        protected let tool!: String,    // Tool name
        protected let args!: HashMap<String, JsonValue>, // Tool arguments
        protected let invocation!: String // The original tool invocation representation
    ) { }

    /**
     * Run the tool and return observation messages
     */
    func invoke(task: AgentTask): Array<ChatMessage> {
        let toolManager = task.agent.toolManager
        let messages = ArrayList<ChatMessage>()
        if (this.thought != "") {
            messages.append(ChatMessage.assistant(this.thought.withTag(THOUGHT_TAG)))
        }
        messages.append(ChatMessage.assistant(this.invocation.withTag(ACTION_TAG)))

        var observation: String = ""
        // Special treatment for the retriever tool
        if (this.tool == "__retriever__tool___") {
            // See RetrieverTool
            let query = this.args["query"].asString().getValue()
            let docs = task.agent.retriever.getOrThrow().search(query)
            task.execInfo.addRetrieval(query, docs)
            observation = String.join(
                docs |> map { doc => doc.content } |> collectArray,
                delimiter: "\n")
        } else if (let Some(foundTool) <- toolManager.findTool(this.tool)) {
            try {
                let convertedArgs = HashMap<String, ToJsonValue>()
                for ((argName, argValue) in this.args) {
                    convertedArgs.put(argName, argValue)
                }
                observation = foundTool.invoke(convertedArgs).content
            } catch (ex: ToolException) {
                observation = "Fail to invoke the tool `${this.tool}`. Reason: ${ex.reason}"
            } catch (_: Exception) {
                observation = "Fail to invoke the tool `${this.tool}`"
            }
        } else {
            let names = toolManager.getTools() |> map { t: Tool => t.name } |> collectArray
            observation = "Tool `${this.tool}` not found in ${names}"
        }
        messages.append(ChatMessage.assistant(observation.withTag(OBSERVATION_TAG)))
        if (task.request.verbose) {
            let verboseContent = if (observation.size < 100) {
                observation.withTag(OBSERVATION_TAG)
            } else {
                "${observation[..100]}...".withTag(OBSERVATION_TAG)
            }
            task.execInfo.verboseChannel.put(verboseContent)
        }
        return messages.toArray()
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
    | Action(ToolUsage)
    | Thought(String)
    | Answer(FinalAnswer)
    | Failure(FailureInfo)

    public func hashCode(): Int64 {
        return match (this) {
            case ReactStep.Action(tu) => tu.invocation.hashCode()
            case ReactStep.Thought(t) => t.hashCode()
            case ReactStep.Answer(a) => a.content.hashCode()
            case ReactStep.Failure(f) => f.reason.hashCode()
        }
    }

    public operator func ==(rhs: ReactStep): Bool {
        match ((this, rhs)) {
            case (ReactStep.Action(tu1), ReactStep.Action(tu2)) =>
                return tu1.invocation == tu2.invocation
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
            case ReactStep.Action(tu) => "[Thought] ${tu.thought} [/Thought]; [Action] ${tu.invocation} [/Action]"
            case ReactStep.Thought(t) => "[Thought] ${t} [/Thought]"
            case ReactStep.Answer(a) => "[Thought] ${a.thought} [/Thought]; [Final Answer] ${a.content} [/Final Answer]"
            case ReactStep.Failure(f) => "[Failure] Original message: ${f.message}; \n Reason: ${f.reason} [/Failure]"
        }
    }

    static func fromStr(content: String): ReactStep {
        let thoughtSection = OutputParserUtils.extractLastSection(content, THOUGHT_TAG)
        if (let Some(answer) <- OutputParserUtils.extractLastSection(content, ANSWER_TAG)) {
            return ReactStep.Answer(
                FinalAnswer(thought: thoughtSection ?? "",
                            content: answer)
            )
        }
        let actionSection = OutputParserUtils.extractLastSection(content, ACTION_TAG)
        match ((thoughtSection, actionSection)) {
            case (_, Some(action)) =>
                let json = JsonValue.fromStr(
                    OutputParserUtils.extractLastCode(action, "json").getOrThrow({
                        => AgentExecutionException("Failed to parse the action: no json object")
                    })
                )
                let toolName = JsonUtils.getString(json, "name").getOrThrow({
                    => AgentExecutionException("Failed to parse the action: no `name`")
                })
                let args = (JsonUtils.getJsonObject(json, "arguments") ?? JsonObject()).getFields()
                if (toolName == "") { // "" means parsing tool-call failed and args[0] stores the failure message
                    return ReactStep.Failure(
                        FailureInfo(FailureLevel.Repairable,
                                    message: content,
                                    reason: "Tool invocation has invalid syntax",
                                    suggestion: "You must follow the required tool invocation syntax.")
                    )
                } else {
                    return ReactStep.Action(
                        ToolUsage(invocation: action,
                                  thought: thoughtSection ?? "",
                                  tool: toolName,
                                  args: args)
                    )
                }
            case (Some(thought), None) =>
                return ReactStep.Thought(thought)
            case (None, None) =>
                return ReactStep.Failure(
                    FailureInfo(
                        FailureLevel.Repairable,
                        message: content,
                        reason: "Output format is invalid.",
                        suggestion: "You should generate [Action] or [Final Answer]"
                    )
                )
        }
    }
}