/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.agent.base.AgentExecutionInfo
import magic.core.agent.*
import magic.core.message.{Message, MessageRole, MessageList, Conversation}
import magic.core.model.{ChatRequest, ChatResponse, ModelException}
import magic.core.tool.*
import magic.core.interaction.*
import magic.core.rag.RetrieverMode
import magic.config.Config
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
     * A cache for tool results for compressing tool invocation results
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
                    .conversation(request.conversation ?? Conversation())
                    .buildFor(agent.executor, keepStepMessage: false)
            )
            this.execution.addRequest(request)
            LogUtils.info(agent.name, this.execution.messages)
        }
        if (request.verbose) {
            installVerboseEventHandlers(this.request, this.execution)
        }
    }

    private static func installVerboseEventHandlers(request: AgentRequest, execution: AgentExecutionInfo): Unit {
        let manager = EventHandlerManager()
        let install = if (let Some(flag) <- request.extra.get(AgentRequestExtra.INSTALL_VERBOSE_EVENT_HANDLER)) {
            (flag as AtomicBool).getOrThrow().load()
        } else {
            true
        }
        if (install) {
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
        if (let Some(object) <- request.extra.get(AgentRequestExtra.EVENT_HANDLER)) {
            manager.merge((object as EventHandlerManager).getOrThrow())
        }
        request.extra[AgentRequestExtra.EVENT_HANDLER] = manager
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
            // If any tool is compressible, we add the result viewer tool
            // to the available tools, so that the tool results can be viewed
            if (tools |> any { tool => (tool.extra.get("compressible") ?? "false") == "true" }) {
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
            match (this.handle(PromptValidateEvent(this.agent, sysPrompt))) {
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
            return ModelUtils.agentMakeChat(this.agent, messages, stop: stop, tools: tools)
                .getOrThrow({ => throw ModelException("Fail to get chat model response") })
        } catch (ex: ModelException) {
            let request = ChatRequest(messages, temperature: agent.temperature, stop: stop)
            return match (this.handle(ChatModelFailureEvent(this.agent, request, ex.error))) {
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
        match (this.handle(ToolCallEvent(this.agent, toolRequest))) {
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
                if ((tool.extra.get("compressible") ?? "false") == "true" &&
                            toolResult.size > Config.resultSummarizeThreshold) {
                    // If the tool is compressible, we can compress its result
                    let summary = this.summarizeToolResult(toolRequest, result: toolResult)
                    // Put the compressed results to the cache
                    toolResult = this.toolResultCache.put(
                        toolRequest: toolRequest,
                        toolResponse: toolResponse,
                        compressedResult: summary
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
    * This agent attempts to summarize the tool execution results into concise and structured summaries.
    **/
    protected func summarizeToolResult(toolRequest: ToolRequest,
                                       result!: String): String {
        LogUtils.info(this.agent.name, "Start to summarize tool result")
        let question = SUMMARIZE_USER_PROMPT.format([
            ("tool_call", toolRequest.toJsonValue().toJsonString()),
            ("tool_result", result)
        ])
        let summary = this.chatLLM(
            MessageList([
                Message.system(SUMMARIZE_SYSTEM_PROMPT),
                Message.user(question)
            ])
        ).message.content
        LogUtils.debug(
            this.agent.name,
            String.join(
                [
                    "#Bytes of tool result: ${result.size} => ${summary.size}",
                    "--------------------------------------",
                    "Summary:", summary
                ],
                delimiter: "\n"
            )
        )
        return summary
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
            this.handle(NotifyEvent(this.agent, tag, content))
        }
    }

    //-----------------------------------------------------------
    private var _manager: Option<Array<EventHandlerManager>> = None
    /*
     * Merge all available event handlers
     */
    private prop eventHandlerManagers: Array<EventHandlerManager> {
        get() {
            match (_manager) {
                case Some(v) => return v
                case None =>
                    let result = ArrayList<EventHandlerManager>()
                    // First, event handlers for the request
                    if (let Some(object) <- this.request.extra.get(AgentRequestExtra.EVENT_HANDLER)) {
                        result.add((object as EventHandlerManager).getOrThrow())
                    }
                    // Then, event handlers of the agent
                    // Last, global event handlers
                    result.add(EventHandlerManager.global)
                    _manager = result.toArray()
                    return _manager.getOrThrow()
            }
        }
    }
    //--------------------------------------------------
    // The following methods are generated by gen.py;
    // never modify them directly
    //--------------------------------------------------
    // The following are event handlers: NEVER DELETE/MODIFY THIS LINE
    protected func handle(evt: ToolCallEvent): EventResponse<ToolResponse> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: PromptValidateEvent): EventResponse<Bool> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: AnswerValidateEvent): EventResponse<Bool> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: ChatModelFailureEvent): EventResponse<ChatResponse> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: TimeoutEvent): EventResponse<Unit> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: UserInputEvent): EventResponse<String> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }

    protected func handle(evt: NotifyEvent): EventResponse<Unit> {
        for (manager in this.eventHandlerManagers) {
            match (manager.handle(evt)) {
                case Continue => ()
                case Continue(v) => return Continue(v)
                case Terminate(v) => return Terminate(v)
            }
        }
        return Continue
    }
    // end of event handlers
}
