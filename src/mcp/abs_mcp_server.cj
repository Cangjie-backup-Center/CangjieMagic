/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.agent.Agent
import magic.core.tool.Tool
import magic.jsonable.*
import magic.log.LogUtils

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject}

/**
 * MCP server via the stdio transport
 */
public abstract class AbsMCPServer {
    protected func send(msg: String): Unit

    protected func recv(): Option<String>

    private let tools: Array<Tool>

    protected init(tools: Array<Tool>) {
        this.tools = tools
    }

    protected func initialize(): Unit {
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

    public func loop(): Unit {
        while (let Some(msg) <- this.recv()) {
            let resp = this.handleRequestMessage(msg)
            this.send(resp)
        }
    }

    /**
     * Currently, only tool list and call requests are supported.
     */
    protected func handleRequestMessage(msg: String): ToJsonValue {
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
        return response
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

    private func recvRequest<T>(): T where T <: Jsonable<T> {
        let msg = this.recv().getOrThrow({ => MCPException("Fail to get MCP response") })
        return T.fromJsonValue(JsonValue.fromStr(msg))
    }
}

