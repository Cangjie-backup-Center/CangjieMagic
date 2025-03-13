/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.dsl.jsonable
import magic.jsonable.*

import std.collection.{HashMap, ArrayList}
import encoding.json.*

// https://github.com/modelcontextprotocol/specification/blob/main/schema/2024-11-05/schema.ts

const LATEST_PROTOCOL_VERSION = "2024-11-05";
const JSONRPC_VERSION = "2.0";

var globalID = 1
func getRequestID(): Int64 {
    let id = globalID
    globalID += 1
    return id
}

@jsonable
class PingRequest {
    let jsonrpc: String
    let id: Int64
    let method: String

    init() {
        this.jsonrpc = JSONRPC_VERSION
        this.id = getRequestID()
        this.method = "ping"
    }
}

@jsonable
public class Annotation {
    let audience: Option<Array<String>>
    let priority: Option<Int64>
}

@jsonable
public class TextContent {
    let annotations: Option<Annotation>
    let `type`: String
    let text: String
}

@jsonable
public class ImageContent {
    let annotations: Option<Annotation>
    let `type`: String
    let data: String
    let mimeType: String
}

//-----------------------------------------------------------------

@jsonable
class InitialRequest {
    var jsonrpc: String = JSONRPC_VERSION
    var id: Int64 = getRequestID()
    var method: String = "initialize"
    let params: InitialParams
}

@jsonable
class InitialParams {
    var protocolVersion: String = LATEST_PROTOCOL_VERSION
    let capabilities: ClientCapabilities
    let clientInfo: Implementation
}

@jsonable
class ClientCapabilities {

}

@jsonable
class Implementation {
    let name: String
    let version: String
}

@jsonable
class InitialResponse {
    let jsonrpc: String
    let id: Int64
    let result: InitialResult
}

@jsonable
class InitialResult {
    let protocolVersion: String
    let capabilities: ServerCapabilities
    let serverInfo: Implementation
    let instructions: Option<String>
}

@jsonable
class ServerCapabilities {
    // let experimental: Option<HashMap<String, Object>>
    // let logging: Option<Object>
    let prompts: Option<PromptsCapability>
    let resources: Option<ResourcesCapability>
    let tools: Option<ToolsCapability>
}

@jsonable
struct PromptsCapability {
    let listChanged: Bool
}

@jsonable
struct ResourcesCapability {
    let subscribe: Bool
    let listChanged: Bool
}
@jsonable
struct ToolsCapability {
    let listChanged: Bool
}

@jsonable
struct InitializedNotification {
    var jsonrpc: String = JSONRPC_VERSION
    var method: String = "notifications/initialized"
}
//-----------------------------------------------------------------

class ListResourcesRequest {
    var jsonrpc: String = JSONRPC_VERSION
    var id: Int64 = getRequestID()
    var method: String = "resources/list"
    var params: PaginatedParams = PaginatedParams()
}

@jsonable
class PaginatedParams {
    var cursor: Option<String> = None
}

@jsonable
class ListResourcesResponse {
    let jsonrpc: String
    let id: Int64
    let result: ListResourcesResult
}

@jsonable
class ListResourcesResult {
    let resources: Array<Resource>
    let nextCursor: Option<String>
}

@jsonable
class Resource {
    let annotations: Option<Annotation>
    let url: String
    let name: String
    let description: Option<String>
    let mimeType: Option<String>
    let size: Option<Int64>
}

//-----------------------------------------------------------------

@jsonable
class ListToolsRequest {
    var jsonrpc: String = JSONRPC_VERSION
    var id: Int64 = getRequestID()
    var method: String = "tools/list"
    var params: PaginatedParams = PaginatedParams()
}

@jsonable
class ListToolsResponse {
    let jsonrpc: String
    let id: Int64
    let result: ListToolsResult
}

@jsonable
public class ListToolsResult {
    let tools: Array<MCPTool>
    let nextCursor: Option<String>
}

@jsonable
public class MCPTool {
    let name: String
    let description: Option<String>
    let inputSchema: JsonObject
}

//-----------------------------------------------------------------

@jsonable
class CallToolRequest {
    var jsonrpc: String = JSONRPC_VERSION
    var id: Int64 = getRequestID()
    var method: String = "tools/call"
    let params: CallToolParams
}

@jsonable
class CallToolParams {
    let name: String
    let arguments: Option<JsonObject>
}

@jsonable
class CallToolResponse {
    let jsonrpc: String
    let id: Int64
    let result: CallToolResult
}

@jsonable
public class CallToolResult {
    let content: Array<ToolCallContent>
    let isError: Option<Bool>
}

public enum ToolCallContent <: Jsonable<ToolCallContent> {
    | Text(TextContent)
    | Image(ImageContent)

    public static func getTypeSchema(): TypeSchema {
        throw JsonableException("Unsupported method")
    }

    public static func fromJsonValue(json: JsonValue): ToolCallContent {
        match (JsonUtils.getString(json, "type") ?? "") {
            case "text" => return ToolCallContent.Text(TextContent.fromJsonValue(json))
            case "image" => return ToolCallContent.Image(ImageContent.fromJsonValue(json))
            case _ => throw MCPException("Unsupported tool call result `${json.toString()}`")
        }
    }

    public func toJsonValue(): JsonValue {
        match (this) {
            case ToolCallContent.Text(content) => content.toJsonValue()
            case ToolCallContent.Image(content) => content.toJsonValue()
        }
    }

    public func getValue(): String {
        match (this) {
            case ToolCallContent.Text(text) => text.text
            case ToolCallContent.Image(image) => image.data
        }
    }
}
