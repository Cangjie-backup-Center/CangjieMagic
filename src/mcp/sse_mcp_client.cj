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
        this.url = url
        this.sseStream = HttpUtils.sseConnect("${url}/sse")
        if (let Some(event) <- this.sseStream.next()) {
            if (event.event != "endpoint") {
                throw MCPException("Invalid endpoint event: ${event}")
            }
            this.endpoint = event.data
        } else {
            throw MCPException("Fail to make SSE connection: ${url}")
        }
        // Now, initialize
        this.initialize()
    }

    override protected func send(req: JsonObject): Unit {
        let header = HashMap<String, String>()
        HttpUtils.post("${this.url}${this.endpoint}", header, req, verify: false)
    }

    override protected func recv(): Option<String> {
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
