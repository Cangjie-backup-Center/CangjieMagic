/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.agent.base.AgentExecutionInfo
import magic.core.agent.*
import magic.core.message.{Message, MessageRole, MessageList}
import magic.core.model.{ChatRequest, ChatResponse}
import magic.core.tool.*
import magic.core.interaction.*
import magic.jsonable.ToJsonValue
import magic.log.LogUtils
import magic.interaction.*
import magic.model.ModelUtils

import std.collection.{ArrayList, HashMap, map, collectArray}
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
    // Information during the execution
    public var step = 0
    public let execution: AgentExecutionInfo
    // Whether the task is stopped
    protected var stopInfo: Option<EarlyStopInfo> = None

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
            this.execution.addMessage(Message.system(agent.systemPrompt))
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
            let tools = agent.toolManager.filterTool(
                request.question,
                ToolSearchConfig(chatModel: agent.model, number: request.maxTool)
            )
            this._availableTools = tools
            return tools
        }
    }

    /**
     * Note that: ALWAYS call this method to use the LLM
     */
    protected func chatLLM(messages: MessageList, stop!: Option<Array<String>> = None): Option<Message> {
        if (!messages.isEmpty() && messages[0].role == MessageRole.System) {
            let sysPrompt = messages[0].content
            match (this.handle(PromptValidateEvent(this.agent, sysPrompt))) {
                case EventResponse.Continue => ()
                case EventResponse.Continue(status) =>
                    // Whether the system prompt is valid
                    if (!status) {
                        let info = "Terminated because of invalid system prompt: ${sysPrompt}"
                        this.stop(info, result: info)
                        return None
                    }
                case EventResponse.Terminate(_) =>
                    let info = "Terminated because of invalid system prompt: ${sysPrompt}"
                    this.stop(info, result: info)
                    return None
            }
        }

        if (let Some(msg) <- ModelUtils.agentMakeChat(this.agent, messages, stop: stop)) {
            return msg
        } else {
            let request = ChatRequest(messages, temperature: agent.temperature, stop: stop)
            return match (this.handle(ChatModelFailureEvent(this.agent, request))) {
                case EventResponse.Continue => None
                case EventResponse.Continue(resp) => resp.messageList[0]
                case EventResponse.Terminate(resp) =>
                    this.stop("Terminated by tool call event handler", result: resp.toString())
                    resp.messageList[0]
            }
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
            this.execution.addRetrieval(query, retrieval)
            observation = retrieval.toPrompt()
        } else if (let Some(tool) <- this.agent.toolManager.findTool(toolRequest.name)) {
            try {
                match (this.handle(ToolCallEvent(this.agent, toolRequest))) {
                    case EventResponse.Continue =>
                        let resp = tool.invoke(toolRequest.args)
                        observation = resp.content
                        // Check whether the tool terminates the task
                        if ((tool.extra.get("terminal") ?? "false") == "true") {
                            this.stop("Tool `${tool.name}` terminates the task", result: observation)
                        }
                    case EventResponse.Continue(resp) =>
                        observation = resp.content
                    case EventResponse.Terminate(resp) =>
                        observation = resp.content
                        this.stop("Terminated by tool call event handler", result: observation)
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
