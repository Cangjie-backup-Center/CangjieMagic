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

import std.collection.ArrayList
import std.collection.HashMap
import std.time.DateTime
import encoding.json.*

@When[cjc_version < "0.56.4"]
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
    let message: Message
}

@jsonable
private class Message {
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
    private var role: Option<String> = None
    private var usage: Option<ChatUsage> = None

    override public func next(): Option<AsyncChatChunk> {
        while (let Some(data) <- httpStream.next()) {
            if (data.isEmpty()) { continue }
            let (reasoningContent, content) = parseData(data)
            if (content == ": keep-alive") { continue }
            if (content == "[DONE]") {
                return AsyncChatChunk(
                    message: ChatMessage(ChatMessageRole.fromStr(this.role.getOrThrow()), ""),
                    done: true,
                    usage: this.usage
                )
            } else {
                let rc: Option<String> = if (reasoningContent.isEmpty()) {
                    None
                } else {
                    reasoningContent
                }
                return AsyncChatChunk(
                    message: ChatMessage(
                        ChatMessageRole.fromStr(this.role.getOrThrow()),
                        content,
                        reasoningContent: rc)
                )
            }
        }
        return None
    }

    private func parseData(data: String): (String, String) {
        let content = data.removePrefix("data:").trimAscii()
        if (content == "[DONE]" || content == ": keep-alive") {
            return ("", content)
        }
        let chunkResp = try {
            ChunkResponse.fromJsonValue(content.asJsonValue())
        } catch(ex: JsonException) {
            throw ModelException("Fail to parse http chunk data response `${data}`")
        }
        // Merge the reasoning_content and content of chunks
        let reasoningContentBuilder = StringBuilder()
        let contentBuilder = StringBuilder()
        for (chunkChoice in chunkResp.choices) {
            let delta = chunkChoice.delta
            if (let Some(role) <- delta.role) {
                this.role = role
            }
            reasoningContentBuilder.append(delta.reasoning_content ?? "")
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
        return (reasoningContentBuilder.toString(), contentBuilder.toString())
    }
}

public class OpenAIChatModel <: ChatModel {
    private let model: String
    private let baseURL: String
    public let apiKey: String
    private let temperature: Option<Float64>

    public init(
        model: String,
        apiKey!: String,
        baseURL!: String,
        temperature!: Option<Float64> = None
    ) {
        this.model = model
        this.baseURL = baseURL
        this.apiKey = apiKey
        this.temperature = temperature
    }

    override public prop service: String {
        get() { "openai" }
    }

    override public prop name: String {
        get() { model }
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
        requestAddChatHistory(req, chatReq.dialog)
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

    private func requestAddChatHistory(request: JsonObject, dialog: Dialog): Unit {
        let ja = JsonArray()
        for (msg in dialog) {
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
        let dialog = Dialog()
        for (choice in resp.choices) {
            let msg = choice.message
            dialog.addMessage(
                ChatMessage(
                    ChatMessageRole.fromStr(msg.role),
                    msg.content,
                    reasoningContent: msg.reasoning_content
                )
            )
        }
        let usage = ChatUsage(
            promptTokens: resp.usage.prompt_tokens,
            completionTokens: resp.usage.completion_tokens,
            totalTokens: resp.usage.total_tokens,
            timeCost: duration
        )
        return ChatResponse(dialog, resp.model, usage: usage)
    }

    override public func asyncCreate(chatReq: ChatRequest): AsyncChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: true)
        let httpStream = HttpUtils.asyncPost("${this.baseURL}/chat/completions", header, req)
        let chunkStream = AsyncChatChunkStream(httpStream)
        return AsyncChatResponse(model, chunkStream)
    }
}
