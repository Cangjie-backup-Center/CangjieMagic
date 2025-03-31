/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.Tool
import magic.utils.newProcess
import magic.jsonable.*
import magic.log.LogUtils
import magic.core.ToolResponse

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject}

/**
 * MCP client via the stdio transport
 */
public abstract class AbsMCPClient <: MCPClient {
    protected func send(req: JsonObject): Unit

    protected func recv(): Option<String>

    protected func initialize(): Unit {
        let initRequest = InitialRequest(
            params: InitialParams(
                capabilities: ClientCapabilities(),
                clientInfo: Implementation(
                    name: "Cangjie Magic Agent Client",
                    version: "0.1"
                )
            )
        )
        this.send(initRequest)
        let resp = this.recvResponse<InitialResponse>()
        if (resp.result.protocolVersion != initRequest.params.protocolVersion) {
            throw MCPException("ProtocolVersion of the client and server mismatches")
        }
        this.send(InitializedNotification())
    }

    private func listTools(): ListToolsResult {
        this.send(ListToolsRequest())
        let resp = this.recvResponse<ListToolsResponse>()
        return resp.result
    }

    override public func getTools(): Array<Tool> {
        let result = ArrayList<Tool>()
        for (t in this.listTools().tools) {
            result.append(MCPToolWrapper(this, t))
        }
        return result.toArray()
    }

    override public func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse {
        // Prepare the request
        let arguments = HashMap<String, JsonValue>()
        for (arg in args) {
            arguments.put(arg[0], arg[1].toJsonValue())
        }
        let req = CallToolRequest(
            params: CallToolParams(
                name: name,
                arguments: if (args.isEmpty()) { None } else { JsonObject(arguments) }
            )
        )
        // Send the request and receive its response
        this.send(req)
        let resp = this.recvResponse<CallToolResponse>()
        if (req.id != resp.id) {
            LogUtils.error("Received invalid response with mismatched id: ${resp.toJsonValue().toJsonString()}")
        }
        // Merge all result content
        let result = resp.result
        let strBuilder = StringBuilder()
        for (content in result.content) {
            strBuilder.append(content.getValue())
            strBuilder.append("\n")
        }
        if ((result.isError ?? false)) {
            return ToolResponse(strBuilder.toString(), isError: true)
        } else {
            return ToolResponse(strBuilder.toString(), isError: false)
        }
    }

    private func send<T>(request: T): Unit where T <: Jsonable<T> {
        this.send(request.toJsonValue().asObject())
    }

    private func recvResponse<T>(): T where T <: Jsonable<T> {
        let msg = this.recv().getOrThrow({ => MCPException("Fail to get MCP response") })
        return T.fromJsonValue(JsonValue.fromStr(msg))
    }
}
