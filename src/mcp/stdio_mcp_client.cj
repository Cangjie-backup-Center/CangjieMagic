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
public class StdioMCPClient <: AbsMCPClient {
    private let server: SubProcess
    private let writer: StringWriter<OutputStream>
    private let reader: StringReader<InputStream>

    public init(command: String, args: Array<String>, env!: Array<(String, String)> = []) {
        // Start the MCP server process
        LogUtils.info("Start MCP Server: `${command} ${String.join(args, delimiter: " ")}`")
        server = newProcess(command, args, env: env, redirectErr: false)
        writer = StringWriter(server.stdIn)
        reader = StringReader(server.stdOut)
        this.initialize()
    }

    override protected func doSend(req: JsonObject): Bool {
        let msg = req.toJsonValue().toString()
        LogUtils.debug("Send: ${msg}")
        writer.writeln(msg)
        writer.flush()
        return true
    }

    override protected func doRecv(): Option<String> {
        let msg = reader.readln()
        LogUtils.debug("Recv: ${msg ?? ''}")
        return msg
    }
}
