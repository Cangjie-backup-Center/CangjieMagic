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
    AsyncChatChunkStream(let httpStream: HttpStream) { }

    let start = DateTime.now()
    private var role: Option<MessageRole> = None
    private var usage: Option<ChatUsage> = None
    private var finished = false

    override public func next(): Option<AsyncChatChunk> {
        if (finished) {
            return None
        }
        // A long response may be split as multiple parts, use a buffer to collect all of them.
        let buffer = StringBuilder()
        while (let Some(data) <- httpStream.next()) {
            buffer.append(data)
            let contentToParse = buffer.toString().trimAscii()
            LogUtils.debug("To parse line: `${contentToParse}`")
            if (contentToParse.isEmpty()) { continue }
            // Try to parse the data
            let (reason, content) = try {
                let (rc, c) = parseData(contentToParse)
                buffer.reset()
                (rc, c)
            } catch (_: ModelException) {
                // If parsing fails, the content is incomplete, read more parts
                LogUtils.debug("Parsing data failure: the content incomplete")
                continue
            } catch (_: IllegalArgumentException) {
                // JsonValue.fromStr may throw an IllegalArgumentException
                // This also means the content is incomplete, read more parts
                LogUtils.debug("Parsing JSON failure: the content incomplete")
                continue
            } catch(e: Exception) {
                LogUtils.debug("Parsing data failure ${e}")
                for (ste in e.getStackTrace()) {
                    LogUtils.debug("${ste.methodName} ${ste.fileName}:${ste.lineNumber}")
                }
                throw e
            }
            LogUtils.debug("Parsed reasoning content: ${reason}")
            LogUtils.debug("Parsed content: ${content}")
            // Some special content
            if (content == ": keep-alive") {
                continue
            } else if (content == "[DONE]") {
                // Consume and close the http stream
                while (let Some(_) <- httpStream.next()) { }
                finished = true
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
                        reason: if (reason.isEmpty()) { None } else { reason}),
                    done: false
                )
            }
        }
        // Some model services may not return "[DONE]" and finish the http stream directly?
        finished = true
        return AsyncChatChunk(
            message: Message(this.role.getOrThrow(), ""),
            done: true,
            usage: this.usage
        )
    }

    private func parseData(data: String): (String, String) {
        let content = data.removePrefix("data:").trimAscii()
        if (content == "[DONE]" || content == ": keep-alive") {
            return ("", content)
        }
        let chunkResp = try {
            ChunkResponse.fromJsonValue(JsonValue.fromStr(content))
        } catch(ex: JsonException) {
            LogUtils.error("Fail to parse http chunk data response `${data}`")
            throw ModelException("Fail to parse http chunk data response `${data}`")
        }
        // Merge the reasoning_content and content of chunks
        let reasonContentBuilder = StringBuilder()
        let contentBuilder = StringBuilder()
        for (chunkChoice in chunkResp.choices) {
            let delta = chunkChoice.delta
            if (let Some(role) <- delta.role) {
                this.role = MessageRole.fromStr(role)
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

        match (HttpUtils.post("${this.baseURL}/chat/completions", header, req)) {
            case Some(body) =>
                if (body == "") {
                    throw ModelException("Http response body is empty")
                } else {
                    let duration = DateTime.now() - start
                    return parseChatResponse(body, duration)
                }
            case None => throw ModelException("Fail to get chat http response")
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

    // cjlint-ignore -start !G.FUNC.01 !G.ERR.03
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
        return ChatResponse(messageList, resp.model, usage: usage)
    }

    override public func asyncCreate(chatReq: ChatRequest): AsyncChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: true)
        let httpStream = HttpUtils.asyncPost("${this.baseURL}/chat/completions", header, req)
        let chunkStream = AsyncChatChunkStream(httpStream)
        return AsyncChatResponse(model, chunkStream)
    }
}
