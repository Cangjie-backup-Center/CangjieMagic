/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model.openai

import magic.core.model.*
import magic.utils.http.*
import magic.utils.StringExt
import magic.core.message.*
import magic.dsl.jsonable
import magic.jsonable.*
import magic.config.Config
import magic.log.LogUtils

import std.collection.ArrayList
import std.collection.HashMap
import std.time.DateTime
import stdx.encoding.json.*

@When[cjc_version < "1.0.0"]
import std.time.Duration

@jsonable
private class OpenAIChatResponse {
    let id: String
    let object: String
    let created: Int64
    let model: String
    let choices: Array<Choice>
    let usage: OpenAIChatUsage
}

@jsonable
private class Choice {
    let finish_reason: String
    let index: Int64
    let message: OpenAIChatMessage
}

@jsonable
private class OpenAIChatMessage {
    let content: String
    let role: String
    let reasoning_content: Option<String>
    // let tool_calls: Array<ToolCall>
}

@jsonable
private class OpenAIChatUsage {
    let prompt_tokens: Int64
    let completion_tokens: Int64
    let total_tokens: Int64
}

//----------------------------------------------
// Response for streaming
//----------------------------------------------
@jsonable
private class ChunkResponse {
    let id: String
    let object: String
    let created: Int64
    let model: String
    let choices: Array<ChunkChoice>
    let usage: Option<OpenAIChatUsage>
}

@jsonable
private class ChunkChoice {
    let finish_reason: String
    let index: Int64
    let delta: Delta
}

@jsonable
private class Delta {
    let role: Option<String>
    let content: String
    let reasoning_content: Option<String>
}

private class AsyncChatChunkStream <: Iterator<AsyncChatChunk> {
    private let sseStream: SSEStream
    private let start = DateTime.now()
    private var role: Option<MessageRole> = None
    private var usage: Option<ChatUsage> = None
    private var finished = false

    init(httpStream: HttpStream) {
        this.sseStream = SSEStream(httpStream)
    }

    override public func next(): Option<AsyncChatChunk> {
        if (finished) {
            return None
        }
        while (true) {
            let sseItem = try {
                this.sseStream.next()
            } catch(ex: HttpException) {
                throw ModelException("Fail to get chat model async chat response: ${ex.error}")
            }
            if (let Some(sseItem) <- sseItem) {
                if (let Some(chunk) <- this.parseSSEItem(sseItem)) {
                    return chunk
                } else {
                    continue
                }
            } else {
                // Some model provider may not return "[DONE]" and finish the http stream directly?
                this.finished = true
                return AsyncChatChunk(
                    message: Message(this.role.getOrThrow(), ""),
                    done: true,
                    usage: this.usage
                )
            }
        }
        throw UnsupportedException("Unreachable")
    }

    private func parseSSEItem(sseItem: SSEItem): Option<AsyncChatChunk> {
        if (sseItem.tag != "data") {
            let msg = "Async chat response read invalid sse data: `${sseItem}`"
            LogUtils.debug(msg)
            throw ModelException(msg)
        }
        LogUtils.debug("To parse SSE content: `${sseItem.content}`")
        if (sseItem.content.isEmpty()) {
            return None
        }
        // Try to parse the data
        let (reason, content) = try {
            parseContent(sseItem.content)
        } catch(ex: Exception) {
            LogUtils.debug("Parsing SSE content failure ${ex}")
            throw ex
        }
        LogUtils.debug("  Get reasoning content: ${reason}")
        LogUtils.debug("  Get content: ${content}")
        if (content == "[DONE]") {
            // Consume and close the http sse stream
            while (let Some(_) <- this.sseStream.next()) { }
            this.finished = true
            return AsyncChatChunk(
                message: Message(this.role.getOrThrow(), ""),
                done: true,
                usage: this.usage
            )
        } else {
            return AsyncChatChunk(
                message: Message(
                    this.role.getOrThrow(),
                    content,
                    reason: if (reason.isEmpty()) { None } else { reason }
                ),
                done: false
            )
        }
    }

    /**
     * Parse the content of a SSE data item, return the reasoning content and the content
     * If the content is "[DONE]", return an empty reasoning content and the content itself.
     */
    private func parseContent(content: String): (String, String) {
        if (content == "[DONE]") {
            return ("", content)
        }
        let chunkResp = try {
            ChunkResponse.fromJsonValue(JsonValue.fromStr(content))
        } catch(ex: JsonException | IllegalStateException) { // JsonValue.fromStr may throw an IllegalArgumentException
            let msg = "Fail to parse http chunk data response as a JSON value `${content}`"
            LogUtils.error(msg)
            throw ModelException(msg)
        }
        // A chunk response may have multiple choices? See the OpenAI API document
        // So, merge the reasoning_content and content of choices of the chunk response
        let reasonContentBuilder = StringBuilder()
        let contentBuilder = StringBuilder()
        for (chunkChoice in chunkResp.choices) {
            let delta = chunkChoice.delta
            if (let Some(role) <- delta.role) {
                this.role = MessageRole.fromStr(role) // Do we need to check the role?
            }
            reasonContentBuilder.append(delta.reasoning_content ?? "")
            contentBuilder.append(delta.content)
        }
        // Check whether this chunk contains the usage
        if (let Some(respUsage) <- chunkResp.usage) {
            let duration = DateTime.now() - start
            this.usage = ChatUsage(
                promptTokens: respUsage.prompt_tokens,
                completionTokens: respUsage.completion_tokens,
                totalTokens: respUsage.total_tokens,
                timeCost: duration
            )
        }
        return (reasonContentBuilder.toString(), contentBuilder.toString())
    }
}

public class OpenAIChatModel <: ChatModel {
    private let model: String
    private let baseURL: String
    public let apiKey: String
    private let temperature: Option<Float64>
    private var _contextLength: Int64

    public init(
        model: String,
        apiKey!: String,
        baseURL!: String,
        temperature!: Option<Float64> = None,
        contextLength!: Int64 = Config.defaultContextLen) {
        this.model = model
        this.baseURL = baseURL
        this.apiKey = apiKey
        this.temperature = temperature
        this._contextLength = contextLength
    }

    override public prop provider: String {
        get() { "openai" }
    }

    override public prop name: String {
        get() { model }
    }

    override public prop contextLength: Int64 {
        get() { _contextLength }
    }

    override public func create(chatReq: ChatRequest): ChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: false)
        let start = DateTime.now()

        try {
            match (HttpUtils.post("${this.baseURL}/chat/completions", header, req)) {
                case Some(body) =>
                    if (body.isEmpty()) {
                        throw ModelException("Http response body is empty")
                    } else {
                        return parseChatResponse(body, DateTime.now() - start)
                    }
                case None => throw ModelException("Fail to get chat http response")
            }
        } catch (ex: HttpException) {
            throw ModelException("Fail to get chat http response.\n${ex.error}")
        }
    }

    private func prepareHeaderAndRequest(chatReq: ChatRequest, stream!: Bool): (HashMap<String, String>, JsonObject) {
        let header = HashMap<String, String>([
            ("Content-Type", "application/json"),
            ("Authorization", "Bearer ${this.apiKey}")
        ])

        let req = JsonObject()
        requestAddChatHistory(req, chatReq.messageList)
        req.put("model", JsonString(model))
        req.put("stream", JsonBool(stream))
        if (let Some(items) <- chatReq.stop) {
            if (!items.isEmpty()) {
                let ja = JsonArray(
                    Array<JsonValue>(items.size, { i: Int64 =>
                        JsonString(items[i])
                    })
                )
                req.put("stop", ja)
            }
        }
        if (let Some(temp) <- chatReq.temperature) {
            req.put("temperature", JsonFloat(temp))
        } else if (let Some(temp) <- this.temperature) {
            req.put("temperature", JsonFloat(temp))
        }

        return (header, req)
    }

    private func requestAddChatHistory(request: JsonObject, messageList: MessageList): Unit {
        let ja = JsonArray()
        for (msg in messageList) {
            let msgJson = if (let Some(image) <- msg.image) {
                // Schema: { role: string,
                //           content: [ {type: string, text: string},
                //                      {type: string, image_url: {url: string} }] }
                JsonUtils.buildJsonObject(
                    ("role", JsonString(msg.role.toString())),
                    ("content", JsonArray([
                        JsonUtils.buildJsonObject([("type", "text"), ("text", msg.content)]),
                        JsonUtils.buildJsonObject(
                            ("type", JsonString("image_url")),
                            ("image_url", JsonUtils.buildJsonObject("url", image))
                        )
                    ])
                ))
            } else {
                // Schema: { role: string, content: string }
                JsonUtils.buildJsonObject(
                    ("role", msg.role.toString()),
                    ("content", msg.content)
                )
            }
            ja.add(msgJson)
        }
        request.put("messages", ja)
    }

    private func parseChatResponse(body: String, duration: Duration): ChatResponse {
        let resp = OpenAIChatResponse.fromJsonValue(JsonValue.fromStr(body))
        let messageList = MessageList()
        for (choice in resp.choices) {
            let msg = choice.message
            messageList.addMessage(
                Message(
                    MessageRole.fromStr(msg.role),
                    msg.content,
                    reason: msg.reasoning_content
                )
            )
        }
        let usage = ChatUsage(
            promptTokens: resp.usage.prompt_tokens,
            completionTokens: resp.usage.completion_tokens,
            totalTokens: resp.usage.total_tokens,
            timeCost: duration
        )
        return ChatResponse(resp.model, messageList, usage: usage)
    }

    override public func asyncCreate(chatReq: ChatRequest): AsyncChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: true)
        let httpStream = HttpUtils.asyncPost("${this.baseURL}/chat/completions", header, req)
        let chunkStream = AsyncChatChunkStream(httpStream)
        return AsyncChatResponse(model, chunkStream)
    }
}
