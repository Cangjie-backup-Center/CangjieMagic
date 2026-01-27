// package magic.mcp

// import magic.core.tool.Tool
// import magic.jsonable.*
// import magic.log.LogUtils
// import magic.core.ToolResponse

// import std.collection.{ArrayList, HashMap, map, collectArray}
// import stdx.encoding.json.{JsonValue, JsonObject, JsonString}


// public class HTMLUIMCPClient <: AbsMCPClient {
//     override protected func doSend(req: JsonObject): Bool {
//         return false
//     }

//     override protected func doRecv(): Option<String> {
//         return "mock HTMLUIMCPClient"
//     }

//     override public prop initParams: JsonObject {
//         get() {
//             let jo = JsonObject()
//             return jo
//         }
//     }

//     public func callUI(names: Array<String>, args: Array<Array<(String, JsonValue)>>, layout: String, tools: Array<Tool>): ToolResponse {
//         this.doBeforeRequest()
//         // Prepare the request
//         let argsArr = ArrayList<JsonObject>()
//         for (arg in args) {
//             let arguments = HashMap<String, JsonValue>(arg)
//             argsArr.add(JsonObject(arguments))
//         }
//         let req = CallHTMLUIRequest(
//             params: CallUIParams(
//                 names: names,
//                 title: 'title',
//                 layout: layout,
//                 arguments: if (args.isEmpty()) { None } else { argsArr.toArray() }
//             )
//         )
//         let params = req.params.toJsonValue()
//         let reqMsg = '{"jsonrpc":"2.0","id":1,"method":"htmlui/call","params":${params}}'
//         let msg = HTMLUIMCPServer(tools).handleRequestMessage(reqMsg)
//         let resp = CallUIResponse.fromJsonValue(msg.getOrThrow().toJsonValue())
//         // Merge all result content
//         let result = resp.result
//         let strBuilder = StringBuilder()
//         for (content in result.content) {
//             strBuilder.append(content.getValue())
//             strBuilder.append("\n")
//         }
//         if ((result.isError ?? false)) {
//             return ToolResponse(strBuilder.toString(), isError: true)
//         } else {
//             return ToolResponse(strBuilder.toString(), isError: false)
//         }
//     }
// }

/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.dsl.jsonable
import magic.core.tool.Tool
import magic.core.ToolResponse
import magic.jsonable.*
import magic.log.LogUtils
import magic.config.Config
import magic.utils.http.{HttpUtils, SSEvent}
import magic.utils.http.SSEventStream
import magic.utils.newProcess

import std.io.{StringReader, StringWriter, OutputStream, InputStream}
import std.collection.{ArrayList, HashMap, map, collectArray}
import std.time.DateTime
import stdx.encoding.url.URL
import stdx.encoding.json.*

/**
 * MCP client via the stdio transport
 */
public class HTMLUIMCPClient <: AbsMCPClient {
    private let userURL: String // The input URL specified by the user
    private var baseURL: String

    private var _sseStream: Option<SSEventStream> = None
    private var endpoint: String = ""
    private var lastInitTime: DateTime

    public init(url: String) {
        this.userURL = url
        let items = url.split("/sse") // Split the URl to get the domain base URL
        this.baseURL = items[0]
        this.lastInitTime = DateTime.now()
        this.doInit()
    }

    override public prop initParams: JsonObject {
        get() {
            let jo = JsonObject()
            jo.put("url", JsonString(this.userURL))
            return jo
        }
    }

    private prop sseStream: SSEventStream {
        get() { this._sseStream.getOrThrow() }
    }

    private func doInit(): Unit {
        this.lastInitTime = DateTime.now()
        this._sseStream = HttpUtils.sseConnect("${this.userURL}")
        if (let Some(event) <- this.sseStream.next()) {
            if (event.event != "endpoint") {
                throw MCPException("Invalid endpoint event: ${event}")
            }
            this.endpoint = event.data
            LogUtils.info("Found endpoint: ${this.endpoint}")
        } else {
            throw MCPException("Fail to make SSE connection: ${this.userURL}")
        }
        // Now, initialize
        this.initialize()
    }

    override protected func doBeforeRequest(): Unit {
        // Before sending the request, initialize the MCP
        let dur = DateTime.now() - this.lastInitTime
        if (dur.toMilliseconds() > (Config.httpReadWriteTimeout - 10000)) {
            LogUtils.info("Reinitialize the sse session. Close ${this.endpoint}")
            this.sseStream.close()
            this.doInit()
        }
    }

    override protected func doSend(req: JsonObject): Bool {
        let header = HashMap<String, String>([
            ("Content-Type", "application/json")
        ])
        let url = URL.parse(this.baseURL).resolveURL(URL.parse(this.endpoint))
        let resp = HttpUtils.post("${url}", header, req, verify: false)
        return !resp.isNone()
    }

    override protected func doRecv(): Option<String> {
        if (let Some(event) <- this.sseStream.next()) {
            LogUtils.debug("Recv: ${event}")
            if (event.event != "message") {
                throw MCPException("Invalid message event: ${event}")
            }
            return event.data
        } else {
            throw MCPException("Fail to receive sse event")
        }
    }

    override public func callUI(names: Array<String>, args: Array<Array<(String, ToJsonValue)>>, layout: String, title: String, kind: String): ToolResponse {
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
        return this.callUI(names, argsArr.toArray(), layout, title, kind)
    }

    override public func callUI(names: Array<String>, args: Array<Array<(String, JsonValue)>>, layout: String, title: String, kind: String): ToolResponse {
        this.doBeforeRequest()
        // Prepare the request
        let argsArr = ArrayList<JsonObject>()
        for (arg in args) {
            let arguments = HashMap<String, JsonValue>(arg)
            argsArr.add(JsonObject(arguments))
        }
        let req = CallHTMLUIRequest(
            params: CallUIParams(
                names: names,
                title: title,
                layout: layout,
                kind: kind,
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

}
