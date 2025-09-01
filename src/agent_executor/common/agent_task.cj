/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.agent.base.{AgentExecutionInfo, AgentOp}
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

    /**
     * Information during the execution
     */
    public let execution: AgentExecutionInfo

    /**
     * A cache for tool results for compacting tool invocation results
     */
    private let toolResultCache = ToolResultCache()

    /**
     * Whether the task is stopped
     */
    protected var stopInfo: Option<EarlyStopInfo> = None

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
        let need2set = if (let Some(flag) <- request.extra.get(AgentRequestExtra.SET_VERBOSE_EVENT_HANDLER)) {
            (flag as AtomicBool).getOrThrow().load()
        } else {
            true
        }
        if (need2set) {
            manager.addHandler { evt: ToolCallEvent =>
                execution.events.put(evt)
                Continue
            }
            manager.addHandler { evt: NotifyEvent =>
                execution.events.put(evt)
                Continue
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

    /**
     * Note that: ALWAYS call this method to use the LLM
     */
    protected func chatLLM(messages: MessageList,
                           stop!: Option<Array<String>> = None,
                           tools!: Array<Tool> = []): ChatResponse {
        // Validate the system prompt if necessary
        if (!messages.isEmpty() && messages[0].role == MessageRole.System) {
            let sysPrompt = messages[0].content
            let eventResponse = AgentOp.handle(
                this.agent,
                event: PromptValidateEvent(this.agent, sysPrompt),
                forRequest: this.request
            )
            match (eventResponse) {
                case EventResponse.Continue => ()
                case EventResponse.Continue(status) =>
                    // Whether the system prompt is valid
                    if (!status) {
                        let info = "Terminated because of invalid system prompt: ${sysPrompt}"
                        this.stop(info, result: info)
                        return ChatResponse("prompt validator", Message.assistant(info))
                    }
                case EventResponse.Terminate(_) =>
                    let info = "Terminated because of invalid system prompt: ${sysPrompt}"
                    this.stop(info, result: info)
                    return ChatResponse("prompt validator", Message.assistant(info))
            }
        }
        try {
            return AgentOp.chatLLM(this.agent, messages, stop: stop, tools: tools, validate: false)
                .getOrThrow({ => throw ModelException("Fail to get chat model response") })
        } catch (ex: ModelException) {
            let request = ChatRequest(messages, temperature: agent.temperature, stop: stop)
            let eventResponse = AgentOp.handle(this.agent, event: ChatModelFailureEvent(this.agent, request, ex.error), forRequest: this.request)
            return match (eventResponse) {
                case EventResponse.Continue => throw ex
                case EventResponse.Continue(resp) => resp
                case EventResponse.Terminate(resp) =>
                    this.stop("Terminated by chat model failure event handler", result: resp.toString())
                    resp
            }
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
        // Find the tool
        let toolOpt = this.findTool(toolRequest.name)
        if (toolOpt.isNone()) {
            // LLM generate invalid tool calling?
            let names = this.agent.toolManager.tools |> map { t => t.name } |> collectArray
            return "Tool `${toolRequest.name}` not found in ${names}"
        }
        var toolResult: String = ""
        let tool = toolOpt.getOrThrow()
        match (AgentOp.handle(this.agent, event: ToolCallEvent(this.agent, toolRequest), forRequest: this.request)) {
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
                    this.stop("Tool `${tool.name}` terminates the task", result: toolResult)
                }
            case EventResponse.Continue(resp) =>
                toolResult = resp.content
            case EventResponse.Terminate(resp) =>
                toolResult = resp.content
                this.stop("Terminated by tool call event handler", result: toolResult)
        }
        return toolResult
    }

    /**
     * Stop the task with the given reason and result.
     * The task will be marked as stopped.
     */
    protected func stop(reason: String, result!: String): Unit {
        this.stopInfo = EarlyStopInfo(reason, result: result)
        LogUtils.info(agent.name, "Early stopped: ${reason}; with result: ${result}")
    }

    protected func notify(tag: String, content: String): Unit {
        if (this.request.verbose) {
            AgentOp.handle(agent, event: NotifyEvent(this.agent, tag, content), forRequest: this.request)
        }
    }
}
