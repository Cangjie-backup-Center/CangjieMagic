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
import stdx.encoding.json.{JsonValue, JsonObject}

/**
 * MCP client via the stdio transport
 */
public abstract class AbsMCPClient <: MCPClient {
    protected func doSend(req: JsonObject): Bool

    protected func doRecv(): Option<String>

    open protected func doBeforeRequest(): Unit { }

    protected func send(req: JsonObject): Unit {
        if (!doSend(req)) {
            throw MCPException("Fail to send request")
        }
    }

    protected func recv(): String {
        return doRecv().getOrThrow({ => MCPException("Fail to get MCP response") })
    }

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

    private func listInputUI(): ListUIResult {
        this.send(ListInputUIRequest())
        let resp = this.recvResponse<ListInputUIResponse>()
        return resp.result
    }

    private func listDisplayUI(): ListUIResult {
        this.send(ListDisplayUIRequest())
        let resp = this.recvResponse<ListDisplayUIResponse>()
        return resp.result
    }

    override public prop tools: Array<Tool> {
        get() {
            this.doBeforeRequest()
            let result = ArrayList<Tool>()
            for (t in this.listTools().tools) {
                result.add(MCPToolWrapper(this, t))
            }
            return result.toArray()
        }
    }

    public prop displayUI: Array<Tool> {
        get() {
            this.doBeforeRequest()
            let result = ArrayList<Tool>()
            for (u in this.listDisplayUI().ui) {
                result.add(MCPUIWrapper(this, u))
            }
            return result.toArray()
        }
    }

    public prop inputUI: Array<Tool> {
        get() {
            this.doBeforeRequest()
            let result = ArrayList<Tool>()
            for (u in this.listInputUI().ui) {
                result.add(MCPUIWrapper(this, u))
            }
            return result.toArray()
        }
    }

    override public func callUI(names: Array<String>, args: Array<Array<(String, ToJsonValue)>>, title: String): ToolResponse {
        let argsArr = ArrayList<Array<(String, JsonValue)>>()
        // var index = 0
        for (argArr in args) {
            let arguments = ArrayList<(String, JsonValue)>()
            for (arg in argArr) {
                arguments.add((arg[0], arg[1].toJsonValue()))
            }
            argsArr.add(arguments.toArray())
            // index++
        }
        return this.callUI(names, argsArr.toArray(), title)
    }

    open override public func callUI(names: Array<String>, args: Array<Array<(String, JsonValue)>>, title: String): ToolResponse {
        this.doBeforeRequest()
        // Prepare the request
        let argsArr = ArrayList<JsonObject>()
        for (arg in args) {
            let arguments = HashMap<String, JsonValue>(arg)
            argsArr.add(JsonObject(arguments))
        }
        let req = CallArkUIRequest(
            params: CallUIParams(
                names: names,
                title: title,
                combMode: 'Column',
                arguments: if (args.isEmpty()) { None } else { argsArr.toArray() }
            )
        )
        // Send the request and receive its response
        this.send(req)
        let resp = this.recvResponse<CallUIResponse>()
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

    override public func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse {
        let arguments = ArrayList<(String, JsonValue)>()
        for (arg in args) {
            arguments.add((arg[0], arg[1].toJsonValue()))
        }
        return this.callTool(name, arguments.toArray())
    }

    override public func callTool(name: String, args: Array<(String, JsonValue)>): ToolResponse {
        this.doBeforeRequest()
        // Prepare the request
        let arguments = HashMap<String, JsonValue>(args)
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

    protected func send<T>(request: T): Unit where T <: Jsonable<T> {
        this.send(request.toJsonValue().asObject())
    }

    protected func recvResponse<T>(): T where T <: Jsonable<T> {
        let msg = this.recv()
        return T.fromJsonValue(JsonValue.fromStr(msg))
    }
}
