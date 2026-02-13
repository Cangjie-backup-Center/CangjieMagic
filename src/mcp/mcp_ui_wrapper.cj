/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.*
import magic.jsonable.*

import std.collection.HashMap
import stdx.encoding.json.{JsonValue, JsonObject, JsonString}

/**
 * Wrap the MCPUI as a tool
 */
protected class MCPUIWrapper <: Tool {
    private let client: MCPClient
    private let mcpUI: MCPUI
    private let _extra = HashMap<String, String>()

    public init(client: MCPClient, mcpUI: MCPUI) {
        this.client = client
        this.mcpUI = mcpUI
    }

    public prop name: String {
        get() { this.mcpUI.name }
    }

    public prop kind: String {
        get() { this.mcpUI.kind }
    }

    public prop lang: String {
        get() {
            println("mcp ui")
            this.mcpUI.lang }
    }

    public prop category: Option<String> {
        get() { this.mcpUI.category }
    }

    public prop description: String {
        get() { this.mcpUI.description ?? "" }
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

    override public func invoke(args: HashMap<String, JsonValue>): ToolResponse {
        /*let toolResponse = this.client.callUI([this.name], [args.toArray()], '', '', '')
        // If the content is error messages, truncate it
        let runes = toolResponse.content.toRuneArray()
        return toolResponse*/
        return ToolResponse('Not implemented', isError: true)
    }

    override public func toJsonValue(): JsonValue {
        // The difference between MCP tool schema and the magic.core.AbsTool is the parameters field
        let toolJo = this.mcpUI.toJsonValue().asObject()
        let jo = JsonObject()
        jo.put("name", toolJo["name"])
        jo.put("kind", toolJo["kind"])
        jo.put("lang", toolJo["lang"])
        jo.put("description", toolJo["description"])
        jo.put("parameters", toolJo["inputSchema"])
        return jo
    }
}