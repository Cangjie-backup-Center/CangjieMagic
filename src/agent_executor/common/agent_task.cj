/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.agent.*
import magic.core.message.{ChatMessage, Dialog}
import magic.core.tool.{Tool, ToolRequest, ToolSearchConfig, ToolException}
import magic.jsonable.ToJsonValue
import magic.instrumentor.Instrumentor
import magic.log.LogUtils

import std.collection.{HashMap, map, collectArray}

/**
 * Early stop information for the agent task.
 * It contains the reason for stopping and the result of the task.
 */
protected struct EarlyStopInfo {
    EarlyStopInfo(
        protected let reason: String,
        protected let result!: String) { }
}

/**
 * AgentTask represents a task that is being executed by an agent executor.
 * It contains the agent, the request, and execution information.
 */
public open class AgentTask {
    public let agent: Agent
    public let request: AgentRequest
    // Information during the execution
    public var step = 0
    public let execInfo: AgentExecutionInfo
    // Whether the task is stopped
    protected var stopInfo: Option<EarlyStopInfo> = None

    /**
     * Create a new AgentTask with the given agent and request.
     * If `initPrompt` is true, it will initialize the dialog with system and user messages.
     */
    protected init(agent: Agent, request: AgentRequest, initPrompt!: Bool = false) {
        this.agent = agent
        this.request = request
        this.execInfo = request.execInfo ?? AgentExecutionInfo(agent.executor, dialog: BoundedDialog(contextLength: agent.model.contextLength))
        if (initPrompt) {
            this.execInfo.dialog.addMessages([
                ChatMessage.system(agent.systemPrompt),
                ChatMessage.user(request.question)
            ])
            LogUtils.info(agent.name, this.execInfo.dialog)
        }
    }

    /**
     * Get available and related tools for the current request
     */
    var _availableTools: Option<Array<Tool>> = None
    protected prop availableTools: Array<Tool> {
        get() {
            if (let Some(tools) <- this._availableTools) {
                return tools
            }
            let tools = agent.toolManager.filterTool(
                request.question,
                ToolSearchConfig(chatModel: agent.model, number: request.maxTool)
            )
            this._availableTools = tools
            return tools
        }
    }

    /**
     * Run the tool and return observation messages
     */
    protected func invokeTool(toolRequest: ToolRequest): String {
        var observation: String = ""
        // Special treatment for the retriever tool
        if (toolRequest.name == "__retriever__tool___") {
            // See RetrieverTool
            let query = toolRequest.args["query"].asString().getValue()
            let retrieval = this.agent.retriever.getOrThrow().search(query)
            this.execInfo.addRetrieval(query, retrieval)
            observation = retrieval.toPrompt()
        } else if (let Some(tool) <- this.agent.toolManager.findTool(toolRequest.name)) {
            try {
                // Arguments are of type JsonValue, we should convert them as ToJsonValue
                let convertedArgs = HashMap<String, ToJsonValue>()
                for ((argName, argValue) in toolRequest.args) {
                    convertedArgs.put(argName, argValue)
                }
                var toolResponse = if (let Some(resp) <- Instrumentor.doInstrumentBeforeToolCall(this.agent, toolRequest)) {
                    resp
                } else {
                    tool.invoke(convertedArgs)
                }
                toolResponse = Instrumentor.doInstrumentAfterToolCall(this.agent, toolRequest, toolResponse)
                observation = toolResponse.content
                // Check whether the tool terminates the task
                if ((tool.extra.get("terminal") ?? "false") == "true") {
                    this.stop("Tool `${tool.name}` terminates the task", result: observation)
                }
            } catch (ex: ToolException) {
                observation = "Fail to invoke the tool `${toolRequest.name}`. Reason: ${ex.reason}"
            } catch (_: Exception) {
                observation = "Fail to invoke the tool `${toolRequest.name}`"
            }
        } else {
            let names = this.agent.toolManager.getTools() |>
                map { t: Tool => t.name } |>
                collectArray
            observation = "Tool `${toolRequest.name}` not found in ${names}"
        }
        return observation
    }

    /**
     * Stop the task with the given reason and result.
     * The task will be marked as stopped.
     */
    protected func stop(reason: String, result!: String): Unit {
        this.stopInfo = EarlyStopInfo(reason, result: result)
    }
}
