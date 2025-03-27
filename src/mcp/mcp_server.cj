/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.agent.Agent
import magic.core.tool.Tool
import magic.jsonable.*
import magic.log.LogUtils

import std.console.{Console, ConsoleReader, ConsoleWriter}
import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject}
import magic.tool.AgentAsTool

/**
 * MCP server via the stdio transport
 */
public class MCPServer {
    let reader: ConsoleReader
    let writer: ConsoleWriter

    private let tools: Array<Tool>

    public init(tools: Array<Tool>) {
        this.reader = Console.stdIn
        this.writer = Console.stdOut
        this.tools = tools
    }

    /**
     * Start the server
     */
    public func start(): Unit {
        this.initialize()
        this.loop()
    }

    private func initialize(): Unit {
        var hasInit = false
        while (!hasInit) {
            try {
                let initRequest = this.recvRequest<InitialRequest>()
                let initResponse = InitialResponse(
                    id: initRequest.id,
                    result: InitialResult(
                        capabilities: ServerCapabilities(
                            prompts: PromptsCapability(),
                            resources: ResourcesCapability(),
                            tools: ToolsCapability()
                        ),
                        serverInfo: Implementation(
                            name: "Cangjie Magic Agent Server",
                            version: "0.1"
                        )
                    )
                )
                this.send(initResponse)
                let _initNotification = this.recvRequest<InitializedNotification>()
            } catch (_: Exception) {
                // If exceptions are thrown during receiving requests, the server received invalid messages
                hasInit = false
            }
            hasInit = true
        }
    }

    /**
     * Currently, only tool list and call requests are supported.
     */
    private func loop(): Unit {
        while (let Some(msg) <- this.recv()) {
            let req = MCPRequest.fromJsonValue(JsonValue.fromStr(msg))
            let response: ToJsonValue = match (req.method) {
                case "tools/list" =>
                    let mcpTools = this.tools |>
                        map { tool: Tool =>
                            MCPTool.fromJsonValue(JsonValue.fromStr(tool.toString()).asObject())
                        } |>
                        collectArray
                    ListToolsResponse(
                        id: req.id,
                        result: ListToolsResult(
                            tools: mcpTools
                        )
                    )
                case "tools/call" =>
                    this.handleCallTool(
                        CallToolRequest.fromJsonValue(JsonValue.fromStr(msg))
                    )
                case _ => MCPError(
                    id: req.id,
                    error: ErrorContent(
                        code: INVALID_REQUEST,
                        message: "Server does not support ${req.method}"
                    )
                )
            }
            this.send(response)
        }
    }

    private func handleCallTool(callToolRequest: CallToolRequest): ToJsonValue {
        let name = callToolRequest.params.name
        if (let Some(tool) <- this.findTool(name)) {
            let args = if (let Some(arguments) <- callToolRequest.params.arguments) {
                // Type conversion of the value: JsonValue to ToJsonValue
                let args = HashMap<String, ToJsonValue>()
                for ((k, v) in arguments.getFields()) {
                    args.put(k, v)
                }
                args
            } else {
                HashMap<String, ToJsonValue>() // No arguments
            }
            let result = tool.invoke(args).content
            return CallToolResponse(
                id: callToolRequest.id,
                result: CallToolResult(
                    content: [
                        ToolCallContent.Text(
                            TextContent(
                                text: result
                            )
                        )
                    ],
                    isError: false
                )
            )
        } else {
            return MCPError(
                id: callToolRequest.id,
                error: ErrorContent(
                    code: METHOD_NOT_FOUND,
                    message: "Server does not has tool ${name}"
                )
            )
        }
    }

    private func findTool(name: String): Option<Tool> {
        for (tool in this.tools) {
            if (tool.name == name) {
                return tool
            }
        }
        return None
    }

    private func send<T>(response: T): Unit where T <: ToJsonValue {
        this.send(response.toJsonValue().toString())
    }

    private func send(msg: String): Unit {
        LogUtils.info("Send: ${msg}")
        writer.writeln(msg)
        writer.flush()
    }

    private func recv(): Option<String> {
        let msg = reader.readln()
        LogUtils.info("Recv: ${msg ?? ''}")
        return msg
    }

    private func recvRequest<T>(): T where T <: Jsonable<T> {
        let msg = this.recv().getOrThrow({ => MCPException("Fail to get MCP response") })
        return T.fromJsonValue(JsonValue.fromStr(msg))
    }

    //-----------------------------------------------------------------------------------
    /**
     * Merge all tools of each agent, and start a MCP server for these tools
     */
    static public func startWith(agents: Array<Agent>): Unit {
        let allTools = ArrayList<Tool>()
        for (agent in agents) {
            allTools.appendAll(agent.toolManager.getTools())
            // The agent itself is also a tool
            allTools.append(AgentAsTool(agent))
        }
        let server = MCPServer(allTools.toArray())
        server.start()
    }

    /**
     * Start a MCP server for tools
     */
    static public func startWith(tools: Array<Tool>): Unit {
        let server = MCPServer(tools)
        server.start()
    }
}

