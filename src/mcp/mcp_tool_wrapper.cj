/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.*
import magic.jsonable.*

import std.collection.HashMap

protected class MCPToolWrapper <: Tool {
    private let client: MCPClient
    private let mcpTool: MCPTool

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

    override public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        let callToolResult = this.client.callTool(this.name, args.toArray())
        // Merge all result content
        let strBuilder = StringBuilder()
        for (content in callToolResult.content) {
            strBuilder.append(content.getValue())
            strBuilder.append("\n")
        }
        // If the content is error messages, truncate it
        if ((callToolResult.isError ?? false) && strBuilder.size > 100) {
            return ToolResponse(strBuilder.toString()[..100])
        } else {
            return ToolResponse(strBuilder.toString())
        }
        // throw ToolException("Fail to invoke the mcp function.")
    }

    override public func toString(): String {
        return this.mcpTool.toJsonValue().toJsonString()
    }
}