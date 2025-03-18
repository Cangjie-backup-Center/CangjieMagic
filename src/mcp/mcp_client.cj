/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.Tool
import magic.utils.newProcess
import magic.jsonable.*
import magic.log.LogUtils

@When[cjc_version < "0.56.4"]
import std.os.process.SubProcess
@When[cjc_version >= "0.56.4"]
import std.process.SubProcess
import std.io.{StringReader, StringWriter, OutputStream, InputStream}
import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject}

/**
 * MCP client via the stdio transport
 */
public class MCPClient {
    private let server: SubProcess
    private let writer: StringWriter<OutputStream>
    private let reader: StringReader<InputStream>

    public init(command: String, args: Array<String>) {
        // Start the MCP server process
        server = newProcess(command, args, redirectErr: false)
        writer = StringWriter(server.stdIn)
        reader = StringReader(server.stdOut)
        this.initialize()
    }

    private func initialize(): Unit {
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

    public func getTools(): Array<Tool> {
        let result = ArrayList<Tool>()
        for (t in this.listTools().tools) {
            result.append(MCPToolWrapper(this, t))
        }
        return result.toArray()
    }

    public func callTool(name: String, args: Array<(String, ToJsonValue)>): CallToolResult {
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
        this.send(req)
        let resp = this.recvResponse<CallToolResponse>()
        if (req.id != resp.id) {
            LogUtils.error("Received invalid response with mismatched id: ${resp.toJsonValue().toJsonString()}")
        }
        return resp.result
    }

    private func send<T>(request: T): Unit where T <: Jsonable<T> {
        this.send(request.toJsonValue().toString())
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

    private func recvResponse<T>(): T where T <: Jsonable<T> {
        let msg = this.recv().getOrThrow({ => MCPException("Fail to get MCP response") })
        return T.fromJsonValue(JsonValue.fromStr(msg))
    }
}
