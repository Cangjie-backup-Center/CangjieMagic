/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.*
import magic.jsonable.*

import std.collection.HashMap

/**
 * Wrap the MCP client as a tool
 */
protected class MCPToolWrapper <: Tool {
    private let client: MCPClient
    private let mcpTool: MCPTool
    private let _extra = HashMap<String, String>()

    public init(client: MCPClient, mcpTool: MCPTool) {
        this.client = client
        this.mcpTool = mcpTool
    }

    public prop name: String {
        get() { this.mcpTool.name }
    }

    public prop description: String {
        get() { this.mcpTool.description ?? "" }
    }

    public prop parameters: Array<ToolParameter> {
        get() { throw UnsupportedException() }
    }

    public prop retType: TypeSchema {
        get() { throw UnsupportedException() }
    }

    public prop examples: Array<String> {
        get() { throw UnsupportedException() }
    }

    public prop extra: HashMap<String, String> {
        get() { _extra }
    }

    override public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        let toolResponse = this.client.callTool(this.name, args.toArray())
        // If the content is error messages, truncate it
        return toolResponse
        // throw ToolException("Fail to invoke the mcp function.")
    }

    override public func toString(): String {
        return this.mcpTool.toJsonValue().toJsonString()
    }
}