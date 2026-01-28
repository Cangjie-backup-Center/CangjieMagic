/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model.anthropic

import magic.core.model.*
import magic.utils.http.*
import magic.core.message.*
import magic.core.tool.{Tool, ToolRequest}
import magic.dsl.jsonable
import magic.jsonable.*
import magic.config.Config
import magic.log.LogUtils

import std.collection.{ArrayList, map, collectArray, collectArrayList}
import std.collection.HashMap
import std.time.DateTime
import stdx.encoding.json.*

@jsonable
private class AnthropicChatResponse {
    let model: String
    let id: String
    let `type`: String
    let role: String
    let content: Array<JsonObject>
    let stop_reason: String
    let stop_sequence: Option<String>
    let usage: AnthropicChatUsage
}

@jsonable
private class AnthropicChatContent {
    let `type`: String
    let text: String
}

@jsonable
private class AnthropicToolUseContent {
    let `type`: String
    let name: String
    let input: JsonObject
}

@jsonable
private class AnthropicChatUsage {
    let input_tokens: Int64
    let cache_creation_input_tokens: Int64
    let cache_read_input_tokens: Int64
    let cache_creation: AnthropicChatCacheCreation
    let output_tokens: Int64
}

@jsonable
private class AnthropicChatCacheCreation {
    let ephemeral_5m_input_tokens: Int64
    let ephemeral_1h_input_tokens: Int64
}

//----------------------------------------------
// Response for streaming
//----------------------------------------------
@jsonable
private class AnthropicMessageStart {
    let `type`: String
    let message: AnthropicChatResponse
}

@jsonable
private class AnthropicContentBlockStart {
    let `type`: String
    let index: Int64
    let content_block: AnthropicChatContent
}

@jsonable
private class AnthropicContentBlockDelta {
    let `type`: String
    let index: Int64
    let delta: AnthropicChatContent
}

@jsonable
private class AnthropicContentBlockStop {
    let `type`: String
    let index: Int64
}

@jsonable
private class AnthropicMessageDelta {
    let `type`: String
    let delta: JsonObject
    let usage: AnthropicChatUsage
}

@jsonable
private class AnthropicMessageStop {
    let `type`: String
}

private class AnthropicAsyncChatChunkStream <: Iterator<AsyncChatChunk> {
    private let sseStream: SSEventStream
    private let start = DateTime.now()
    private var role: MessageRole = MessageRole.Assistant
    private var inputTokens: Int64 = 0
    private var outputTokens: Int64 = 0
    private var finished = false

    init(httpStream: HttpStream) {
        this.sseStream = SSEventStream(httpStream)
    }

    override public func next(): Option<AsyncChatChunk> {
        if (finished) {
            return None
        }
        while (true) {
            let sseEvent = try {
                this.sseStream.next()
            } catch (ex: HttpException) {
                throw ModelException("Fail to get chat model async chat response: ${ex.error}")
            }

            if (let Some(sseEvent) <- sseEvent) {
                if (let Some(chunk) <- this.parseEvent(sseEvent)) {
                    return chunk
                }
            } else {
                // Mark the stream as finished
                this.finished = true
            }

            if (this.finished) {
                return AsyncChatChunk(
                    message: Message(this.role, ""),
                    done: true,
                    usage: ChatUsage(
                        promptTokens: this.inputTokens,
                        completionTokens: this.outputTokens,
                        timeCost: DateTime.now() - start
                    )
                )
            }
        }
        throw UnsupportedException("Unreachable")
    }

    private func parseEvent(event: SSEvent): Option<AsyncChatChunk> {
        if (event.data.isEmpty()) {
            return None
        }
        match (event.event) {
            case "message_start" =>
                let messageStart = parseValue<AnthropicMessageStart>(event.data)
                this.role = MessageRole.fromStr(messageStart.message.role)
                this.inputTokens = messageStart.message.usage.input_tokens
            case "message_delta" =>
                let messageDelta = parseValue<AnthropicMessageDelta>(event.data)
                this.outputTokens = messageDelta.usage.output_tokens
            case "content_block_delta" =>
                let contentBlockDelta = parseValue<AnthropicContentBlockDelta>(event.data)
                return AsyncChatChunk(
                    message: Message(this.role, contentBlockDelta.delta.text),
                    done: false
                )
            case "message_stop" => this.finished = true
            case _ => ()
        }
        return None
    }

    private static func parseValue<T>(data: String): T where T <: FromJsonValue<T> {
        try {
            return T.fromJsonValue(JsonValue.fromStr(data))
        } catch (ex: JsonException | IllegalStateException) {
            let msg = "Fail to parse http chunk data response as a JSON value `${data}`"
            LogUtils.error(msg)
            throw ModelException(msg)
        }
    }
}

public class AnthropicChatModel <: ChatModel {
    private let _provider: String
    private let model: String
    private let baseURL: String
    private let apiKey: String
    private var _contextLength: Int64
    private var _maxTokens: Option<Int64> = None

    public init(
        _provider: String,
        model: String,
        apiKey!: String,
        baseURL!: String,
        temperature!: Option<Float64> = None,
        contextLength!: Int64 = Config.defaultContextLen) {
        this._provider = _provider
        this.model = model
        this.baseURL = baseURL
        this.apiKey = apiKey
        this._contextLength = contextLength
    }

    override public prop provider: String {
        get() { _provider }
    }

    override public prop name: String {
        get() { model }
    }

    override public prop contextLength: Int64 {
        get() { _contextLength }
    }

    override public mut prop maxTokens: Option<Int64> {
        get() { _maxTokens }
        set(v) { _maxTokens = v }
    }

    override public func create(chatReq: ChatRequest): ChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: false)

        var url = this.baseURL.trimEnd('/')
        url = if (url.endsWith('/v1')) {
            "${url}/messages"
        } else {
            "${url}/v1/messages"
        }

        let start = DateTime.now()
        try {
            match (HttpUtils.post(url, header, req)) {
                case Some(body) =>
                    if (body.isEmpty()) {
                        throw ModelException("Http response body is empty")
                    } else {
                        return this.parseResponse(body, DateTime.now() - start)
                    }
                case None => throw ModelException("Http response body is None")
            }
        } catch (ex: HttpException) {
            throw ModelException(ex.error)
        }
    }

    private func prepareHeaderAndRequest(chatReq: ChatRequest, stream!: Bool): (HashMap<String, String>, JsonObject) {
        let header = HashMap<String, String>([
            ("anthropic-version", "2023-06-01"),
            ("Content-Type", "application/json"),
            ("User-Agent", "Claude-Code/0.1.0"),
            ("X-Api-Key", this.apiKey)
        ])
        let req = this.request2Json(chatReq, stream: stream)
        return (header, req)
    }

    private func request2Json(chatReq: ChatRequest, stream!: Bool): JsonObject {
        let jo = JsonObject()
        jo.put("model", JsonString(model))

        // Anthropic API requires the the system message as a separate parameter
        // The first message may be a system message
        if (!chatReq.messageList.isEmpty() && chatReq.messageList[0].role == MessageRole.System) {
            jo.put("system", JsonString(chatReq.messageList[0].content))
        }
        // Put the rest messages
        jo.put("messages", this.messageList2Json(chatReq.messageList))

        jo.put("stream", JsonBool(stream))
        if (let Some(items) <- chatReq.stop) {
            if (!items.isEmpty()) {
                let ja = JsonArray(
                    Array<JsonValue>(items.size, { i: Int64 =>
                        JsonString(items[i])
                    })
                )
                jo.put("stop_sequences", ja)
            }
        }

        if (let Some(temp) <- chatReq.temperature) {
            jo.put("temperature", JsonFloat(temp))
        }

        if (!chatReq.tools.isEmpty()) {
            jo.put("tools", this.tools2Json(chatReq.tools))
        }

        if (let Some(value) <- chatReq.maxTokens) {
            jo.put("max_tokens", JsonInt(value))
        } else if (let Some(value) <- this.maxTokens) {
            jo.put("max_tokens", JsonInt(value))
        }

        return jo
    }

    private func messageList2Json(messageList: MessageList): JsonArray {
        let ja = JsonArray()
        for (msg in messageList) {
            // Skip the first system message
            if (msg.role == MessageRole.System) {
                continue
            }
            ja.add(
                // Schema: { role: string, content: string }
                JsonUtils.buildJsonObject(
                    ("role", msg.role.toString()),
                    ("content", msg.content)
                )
            )
        }
        return ja
    }

    private func tools2Json(tools: Array<Tool>): JsonArray {
        tools |>
            map { tool => this.buildToolSchema(tool) } |>
            collectArray |>
            JsonUtils.buildJsonArray
    }

    private func buildToolSchema(tool: Tool): JsonObject {
        let properties = JsonObject()
        let required = ArrayList<String>()
        // Add parameters to the schema
        for (param in tool.parameters) {
            let paramTypeSchema = param.typeSchema.toJsonValue().asObject()
            // description should be added to the type schema
            if (!param.description.isEmpty()) {
                paramTypeSchema.put("description", JsonString(param.description))
            }
            properties.put(param.name, paramTypeSchema)
            required.add(param.name)
        }
        // Build the tool schema
        let toolSchema = JsonUtils.buildJsonObject([
            ("name", JsonString(tool.name)),
            ("description", JsonString(tool.description)),
            ("input_schema", JsonUtils.buildJsonObject([
                ("type", JsonString("object")),
                ("properties", properties),
                ("required", JsonUtils.buildJsonArray(required.toArray()))]))
        ])
        return toolSchema
    }

    private func parseResponse(body: String, duration: Duration): ChatResponse {
        let resp = AnthropicChatResponse.fromJsonValue(JsonValue.fromStr(body))

        // Results to parse
        let messageList = MessageList()
        let toolRequests = ArrayList<ToolRequest>()

        if (resp.content.isEmpty()) {
            let msg = "Model replied an invalid message:\n ${body}"
            LogUtils.error(msg)
            throw ModelException(msg)
        }
        // If the output is too long, output may be truncated,
        // which result in incomplete Json string of the tool call
        // Throw an exception to notify the callers
        if (resp.stop_reason == "model_context_window_exceeded") {
            LogUtils.error("The chat model replied a message truncated by length")
            throw ModelException("length")
        }

        for (content in resp.content) {
            let contentType = JsonUtils.getString(content, "type")
            if (contentType == "text") {
                let chatContent = AnthropicChatContent.fromJsonValue(content)
                messageList.add(
                    Message(
                        MessageRole.fromStr(resp.role),
                        chatContent.text,
                    )
                )
            } else if (contentType == "tool_use") {
                let toolUseContent = AnthropicToolUseContent.fromJsonValue(content)
                toolRequests.add(
                    ToolRequest(
                        name: toolUseContent.name,
                        args: toolUseContent.input
                    )
                )
            } else {
                throw UnsupportedException("Unsupported content type: ${contentType}")
            }
        }
        // Validate the response
        if (messageList.size > 1) {
            throw ModelException("Only one message is allowed in the response")
        }
        if (messageList.isEmpty() && toolRequests.isEmpty()) {
            throw ModelException("No message is found in the response")
        }

        let usage = ChatUsage(
            promptTokens: resp.usage.input_tokens,
            completionTokens: resp.usage.output_tokens,
            // totalTokens: resp.usage.total_tokens,
            timeCost: duration
        )
        return ChatResponse(
            resp.model,
            if (!messageList.isEmpty()) { messageList[0] } else { Message.assistant("") },
            toolRequests: toolRequests.toArray(),
            usage: usage
        )
    }

    override public func asyncCreate(chatReq: ChatRequest): AsyncChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: true)
        let httpStream = HttpUtils.asyncPost("${this.baseURL}/messages", header, req)
        let chunkStream = AnthropicAsyncChatChunkStream(httpStream)
        return AsyncChatResponse(model, chunkStream)
    }
}