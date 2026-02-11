/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.dsl.jsonable
import magic.core.tool.Tool
import magic.core.ToolResponse
import magic.jsonable.*
import magic.log.LogUtils
import magic.utils.newProcess

import std.regex.Regex
import std.process.SubProcess
import std.io.{StringReader, StringWriter, OutputStream, InputStream}
import std.collection.{ArrayList, HashMap, map, collectArray}
import stdx.encoding.json.*

/**
 * Split the command line
 */
private func splitCommandLine(commandLine: String): (String, Array<String>) {
    // The regex matches: letters | "..." | '...'
    let regex = Regex(##"(?:[^\s"\']|"(?:\\.|[^"])*"|\'(?:\\.|[^\'])*\')+"##)
    let cmdArgs = regex.findAll(commandLine, group: true) |>
        map { md =>
            let s = md.matchString()
            // Remove the quote marks if necessary
            if (s.startsWith('"') && s.endsWith('"') ||
                s.startsWith("'") && s.endsWith("'")) {
                return s[1..(s.size-1)]
            } else {
                return s
            }
        } |>
        collectArray
    if (cmdArgs.size == 0) {
        throw Exception("Invalid command line: ${commandLine}")
    } else if (cmdArgs.size == 1) {
        return (cmdArgs[0], [])
    } else {
        return (cmdArgs[0], cmdArgs[1..])
    }
}

@jsonable
public class StdioMCPInitParams {
    public let command: String
    public let args: Array<String>
    public let env: HashMap<String, String>
}

/**
 * MCP client via the stdio transport
 */
public class StdioMCPClient <: AbsMCPClient {
    private let server: SubProcess
    private let writer: StringWriter<OutputStream>
    private let reader: StringReader<InputStream>
    private let _initParams: StdioMCPInitParams

    public init(commandLine: String, env!: Array<(String, String)> = []) {
        // Parse the command line
        let (command, args) = splitCommandLine(commandLine)
        // Start the MCP server process
        LogUtils.info("Start MCP Server: `${command} ${String.join(args, delimiter: " ")}`")
        this.server = newProcess(command, args, env: env, redirectErr: false)
        this.writer = StringWriter(server.stdInPipe)
        this.reader = StringReader(server.stdOutPipe)
        this._initParams = StdioMCPInitParams(
            command: command,
            args: args,
            env: HashMap<String, String>(env)
        )
        this.initialize()
    }

    public init(command: String, args: Array<String>, env!: Array<(String, String)> = []) {
        // Start the MCP server process
        LogUtils.info("Start MCP Server: `${command} ${String.join(args, delimiter: " ")}`")
        server = newProcess(command, args, env: env, redirectErr: false)
        writer = StringWriter(server.stdInPipe)
        reader = StringReader(server.stdOutPipe)
        this._initParams = StdioMCPInitParams(
            command: command,
            args: args,
            env: HashMap<String, String>(env)
        )
        this.initialize()
    }

    override public prop initParams: JsonObject {
        get() {
            this._initParams.toJsonValue().asObject()
        }
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

    override public func callUI(names: Array<String>, args: Array<Array<(String, ToJsonValue)>>, layout: String, title: String, lang: String): ToolResponse {
        return ToolResponse('Not implemented', isError: true)
    }

    override public func callUI(components: Array<CallUIItem>, layout: String, title: String, lang: String): ToolResponse {
        return ToolResponse('Not implemented', isError: true)
    }
}
