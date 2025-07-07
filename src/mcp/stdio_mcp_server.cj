/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.agent.Agent
import magic.core.tool.Tool
import magic.jsonable.*
import magic.log.LogUtils

import std.console.{Console, ConsoleReader, ConsoleWriter}
import std.collection.{ArrayList}
import magic.tool.AgentAsTool

/**
 * MCP server via the stdio transport
 */
public class StdioMCPServer <: AbsMCPServer {
    let reader: ConsoleReader
    let writer: ConsoleWriter

    public init(tools: Array<Tool>) {
        super(tools)
        this.reader = Console.stdIn
        this.writer = Console.stdOut
    }

    /**
     * Start the server
     */
    public func start(): Unit {
        this.initialize()
        this.loop()
    }

    public func loop(): Unit {
        while (let Some(msg) <- this.recv()) {
            if (let Some(resp) <- this.handleRequestMessage(msg)) {
                this.send(resp)
            }
        }
    }

    override protected func send(msg: String): Unit {
        LogUtils.debug("Send: ${msg}")
        writer.writeln(msg)
        writer.flush()
    }

    override protected func recv(): Option<String> {
        let msg = reader.readln()
        LogUtils.debug("Recv: ${msg ?? ''}")
        return msg
    }

    //-----------------------------------------------------------------------------------
    /**
     * Merge all tools of each agent, and start a MCP server for these tools
     */
    public static func startWith(agents: Array<Agent>): Unit {
        let allTools = ArrayList<Tool>()
        for (agent in agents) {
            allTools.add(all: agent.toolManager.getTools())
            // The agent itself is also a tool
            allTools.add(AgentAsTool(agent))
        }
        let server = StdioMCPServer(allTools.toArray())
        server.start()
    }

    /**
     * Start a MCP server for tools
     */
    public static func startWith(tools: Array<Tool>): Unit {
        let server = StdioMCPServer(tools)
        server.start()
    }
}

