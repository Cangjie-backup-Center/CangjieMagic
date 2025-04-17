/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.Tool
import magic.utils.newProcess
import magic.jsonable.*
import magic.log.LogUtils
import magic.utils.http.{HttpUtils, SSEvent}

import std.io.{StringReader, StringWriter, OutputStream, InputStream}
import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.{JsonValue, JsonObject}
import magic.utils.http.SSEventStream

/**
 * MCP client via the stdio transport
 */
public class SseMCPClient <: AbsMCPClient {
    private let url: String
    private let sseStream: SSEventStream
    private let endpoint: String

    public init(url: String) {
        let items = url.split("/sse") // Split the URl to get the domain base URL
        this.url = items[0]
        this.sseStream = HttpUtils.sseConnect("${url}")
        if (let Some(event) <- this.sseStream.next()) {
            if (event.event != "endpoint") {
                throw MCPException("Invalid endpoint event: ${event}")
            }
            this.endpoint = event.data
            LogUtils.info("Found endpoint: ${this.endpoint}")
        } else {
            throw MCPException("Fail to make SSE connection: ${url}")
        }
        // Now, initialize
        this.initialize()
    }

    override protected func doSend(req: JsonObject): Bool {
        let header = HashMap<String, String>()
        let resp = HttpUtils.post("${this.url}${this.endpoint}", header, req, verify: false)
        return !resp.isNone()
    }

    override protected func doRecv(): Option<String> {
        if (let Some(event) <- this.sseStream.next()) {
            LogUtils.info("Recv: ${event}")
            if (event.event != "message") {
                throw MCPException("Invalid message event: ${event}")
            }
            return event.data
        } else {
            throw MCPException("Fail to receive sse event")
        }
    }
}
