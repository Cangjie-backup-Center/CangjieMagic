/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.agent.base.AgentOp
import magic.core.agent.*
import magic.core.message.*
import magic.core.model.*
import magic.core.tool.*
import magic.core.interaction.*
import magic.core.rag.RetrieverMode
import magic.config.Config
import magic.compactor.SimpleToolCompactor
import magic.jsonable.ToJsonValue
import magic.log.LogUtils
import magic.interaction.*
import magic.model.ModelUtils
import magic.tool.SimpleToolFilter
import magic.prompt.Template

import std.collection.{ArrayList, HashMap, any, map, collectArray}
import std.sync.AtomicBool

/**
 * AgentTask represents a task that is being executed by an agent executor.
 * It contains the agent, the request, and execution information.
 */
public open class AgentTask {
    public let agent: Agent

    public let request: AgentRequest

    /**
     * Information during the execution
     */
    public let execution: AgentExecutionInfo

    /**
     * A cache for tool results for compacting tool invocation results
     */
    private let toolResultCache = ToolResultCache()

    /**
     * Whether the task is stopped by an early-stop tool
     */
    private var _stopInfo: Option<EarlyStopInfo> = None

    protected prop stopInfo: Option<EarlyStopInfo> {
        get() {
            // If the task is already stopped, return the stop info
            if (let Some(info) <- this._stopInfo) {
                return info
            }
            // Check whether the first task is cancelled by the user
            // TODO: only async tasks check the cancellation status
            if (let Some(firstTask) <- AgentTaskStackUtils.first()) {
                if (firstTask.execution.hasPendingCancellation) {
                    // If the first task is cancelled, we stop this task as well
                    throw AgentCancelException()
                }
            }
            this._stopInfo
        }
    }

    /**
     * Stop the task with the given reason and result.
     * The task will be marked as stopped.
     */
    protected func stop(reason: EarlyStopReason, result!: String, log!: String = ""): Unit {
        // Already stopped
        if (this._stopInfo.isSome()) {
            LogUtils.error(agent.name, "Task already stopped, ignore the stop request")
            return
        }
        this._stopInfo = EarlyStopInfo(reason, result: result)
        if (!log.isEmpty()) {
            LogUtils.info(agent.name, log)
        }
        LogUtils.info(agent.name, "Early stopped: ${reason}; with result: ${result}")
    }

    /**
     * The builtin tool to view the detailed results stored in the cache
     */
    private var _resultViewerTool: Option<Tool> = None

    private prop resultViewerTool: Tool {
        get() {
            if (let Some(tool) <- this._resultViewerTool) {
                return tool
            } else {
                let tool = BuiltinToolUtils.buildToolResultViewerTool(this.toolResultCache)
                this._resultViewerTool = tool
                return tool
            }
        }
    }

    /**
     * The builtin tool of dynamic RAG
     */
    private var _retrieverTool: Option<Tool> = None

    private prop retrieverTool: Tool {
        get() {
            if (let Some(tool) <- this._retrieverTool) {
                return tool
            } else {
                let tool = BuiltinToolUtils.buildRetrieverTool(this)
                this._retrieverTool = tool
                return tool
            }
        }
    }

    /**
     * Create a new AgentTask with the given agent and request.
     * If `initPrompt` is true, it will initialize the messageList with system and user messages.
     */
    protected init(agent: Agent, request: AgentRequest, initPrompt!: Bool) {
        this.agent = agent
        this.request = request
        if (let Some(execution) <- request.extra.get("previous-execution")) {
            this.execution = (execution as AgentExecutionInfo).getOrThrow()
        } else {
            this.execution = AgentExecutionInfo(agent)
        }
        if (initPrompt) {
            this.execution.addMessages(
                PromptBuilder()
                    .system(agent.systemPrompt)
                    .conversation(request.conversation)
                    .buildFor(agent.executor, keepStepMessage: true)
            )
            this.execution.addRequest(request)
            LogUtils.info(agent.name, this.execution.messages)
        }
        if (request.verbose) {
            setVerboseEventHandlers(this.request, this.execution)
        }
    }

    private static func setVerboseEventHandlers(request: AgentRequest, execution: AgentExecutionInfo): Unit {
        let manager = EventHandlerManager()
        // Check whether to set the verbose event handlers,
        // react workers of the plan-react executor will not set verbose event handlers
        let needSet = if (let Some(flag) <- request.extra.get(AgentRequestExtra.SET_VERBOSE_EVENT_HANDLER)) {
            (flag as AtomicBool).getOrThrow().load()
        } else {
            true
        }
        if (needSet) {
            manager.addHandler { evt: ToolCallStartEvent =>
                execution.events.put(evt)
                Continue
            }
            manager.addHandler { evt: NotifyEvent =>
                execution.events.put(evt)
            }
        }
        // If event handlers exist, add new handlers, and update the request
        // Note new handlers will be added before existed handlers
        if (let Some(object) <- request.extra.get(AgentRequestExtra.EVENT_HANDLER_MANAGER)) {
            manager.merge((object as EventHandlerManager).getOrThrow())
        }
        request.extra[AgentRequestExtra.EVENT_HANDLER_MANAGER] = manager
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
            // Filter tools based on the request
            let tools = ArrayList<Tool>(
                agent.toolManager.filterTool(
                    request.question,
                    SimpleToolFilter(agent.model, number: request.maxTool)
                )
            )
            // If any tool is compactable, we add the result viewer tool
            // to the available tools, so that the tool results can be viewed
            if (tools |> any { tool => (tool.extra.get("compactable") ?? "false") == "true" }) {
                // Add the result viewer tool to the tools
                tools.add(this.resultViewerTool)
            }
            if (let Some(rt) <- this.agent.retriever) {
                if (rt.mode == RetrieverMode.Dynamic) {
                    tools.add(this.retrieverTool)
                }
            }
            this._availableTools = tools.toArray()
            return this._availableTools.getOrThrow()
        }
    }

    //-------------------------------------------------------------------------------------
    // Two important methods must be called before and after the task execution
    protected func begin(): Unit {
        LogUtils.info("${this.agent.name} runs")
        AgentOp.handle(event: AgentStartEvent(this.agent, this.request))
        AgentTaskStackUtils.push(this)
    }

    protected func end(): Unit {
        if (this.request.verbose) {
            this.execution.events.close()
        }
        AgentOp.handle(event: AgentEndEvent(this.agent, this.request))
        AgentTaskStackUtils.pop()
    }

    //-------------------------------------------------------------------------------------

    /**
     * Note that: Agents ALWAYS call this method to use the LLM
     */
    protected func chatLLM(messages: MessageList,
                           stop!: Option<Array<String>> = None,
                           tools!: Array<Tool> = []): ChatResponse {
        if (this.stopInfo.isSome()) {
            throw AgentCancelException()
        }
        match (AgentOp.chatLLM(this.agent, messages, stop: stop, tools: tools, forRequest: this.request)) {
            case Some(resp) => resp
            case None =>
                let info = "Terminated because of invalid chat model response."
                this.stop(EarlyStopReason.EventHandlerTerminated, result: info)
                return ChatResponse("Event Handler", Message.assistant(info))
        }
    }

    private func findTool(name: String): Option<Tool> {
        if (name == RetrieverTool.NAME) {
            return this.retrieverTool
        } else if (name == ToolResultViewerTool.NAME) {
            return this.resultViewerTool
        } else {
            return this.agent.toolManager.findTool(name)
        }
    }

    /**
     * Run the tool and return observation messages
     */
    protected func invokeTool(toolRequest: ToolRequest): String {
        if (this.stopInfo.isSome()) {
            throw AgentCancelException()
        }
        // Find the tool
        let toolOpt = this.findTool(toolRequest.name)
        if (toolOpt.isNone()) {
            // LLM generate invalid tool calling?
            let names = this.agent.toolManager.tools |> map { t => t.name } |> collectArray
            return "Tool `${toolRequest.name}` not found in ${names}"
        }
        var toolResult: String = ""
        let tool = toolOpt.getOrThrow()
        match (AgentOp.handle(event: ToolCallStartEvent(this.agent, toolRequest), forRequest: this.request)) {
            case EventResponse.Continue =>
                // Invoke the tool
                let toolResponse = try {
                    tool.invoke(toolRequest.args)
                } catch (ex: ToolException) {
                    return "Fail to invoke the tool `${toolRequest.name}`. Reason: ${ex.reason}"
                } catch (_: Exception) {
                    return "Fail to invoke the tool `${toolRequest.name}`"
                }
                // Save the tool result
                toolResult = toolResponse.content
                // Check whether the tool has special attributes
                if ((tool.extra.get("compactable") ?? "false") == "true" &&
                    toolResult.size > Config.toolResultCompactThreshold) {
                    // If the tool is compactable, we can compact its result
                    let compactor = SimpleToolCompactor(ChatModelWrapper(this))
                    let summary = compactor.compact(toolRequest, toolResponse)
                    // Put the compacted results to the cache
                    toolResult = this.toolResultCache.put(
                        toolRequest: toolRequest,
                        toolResponse: toolResponse,
                        compactedResult: summary
                    )
                }
                if ((tool.extra.get("terminal") ?? "false") == "true") {
                    // If the tool is terminal, we stop the execution
                    this.stop(
                        EarlyStopReason.ToolTerminated,
                        result: toolResult,
                        log: "Tool `${tool.name}` terminates the task"
                    )
                }
            case EventResponse.Continue(resp) =>
                toolResult = resp.content
            case EventResponse.Terminate(resp) =>
                toolResult = resp.content
                this.stop(
                    EarlyStopReason.EventHandlerTerminated,
                    result: toolResult,
                    log: "Terminated by tool call event handler"
                )
        }
        AgentOp.handle(event: ToolCallEndEvent(this.agent, toolRequest, ToolResponse(toolResult)), forRequest: this.request)
        return toolResult
    }

    protected func notify(tag: String, content: String): Unit {
        if (this.request.verbose) {
            AgentOp.handle(event: NotifyEvent(this.agent, tag, content), forRequest: this.request)
        }
    }
}
