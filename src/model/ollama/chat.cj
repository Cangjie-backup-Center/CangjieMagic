/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model.ollama

import magic.utils.http.*
import magic.core.model.*
import magic.core.message.*
import magic.dsl.jsonable
import magic.jsonable.*
import magic.config.Config
import magic.utils.StringExt
import encoding.json.*
import std.time.DateTime
import std.collection.ArrayList
import std.collection.HashMap

@jsonable
private class OllamaChatResponse {
    let model: String
    let created_at: String
    let message: Message
    let done: Bool

    let total_duration: Option<Int64>
    // let load_duration: Option<Int64>
    let prompt_eval_count: Option<Int64>
    // let prompt_eval_duration: Option<Int64>
    let eval_count: Option<Int64>
}

@jsonable
private class Message {
    let role: String
    let content: String
}

private class AsyncChatChunkStream <: Iterator<AsyncChatChunk> {
    AsyncChatChunkStream(let httpStream: HttpStream) { }
    let start = DateTime.now()

    override public func next(): Option<AsyncChatChunk> {
        while (let Some(data) <- httpStream.next()) {
            if (data.isEmpty()) {
                continue
            }
            let resp = OllamaChatResponse.fromJsonValue(JsonValue.fromStr(data))
            if (resp.done) {
                return AsyncChatChunk(
                    message: ChatMessage(ChatMessageRole.fromStr(resp.message.role), resp.message.content),
                    done: true,
                    usage: ChatUsage(
                        promptTokens: resp.prompt_eval_count ?? 0,
                        completionTokens: resp.eval_count ?? 0,
                        totalTokens: (resp.prompt_eval_count ?? 0) + (resp.eval_count ?? 0),
                        timeCost: DateTime.now() - start
                    )
                )
            } else {
                return AsyncChatChunk(
                    message: ChatMessage(ChatMessageRole.fromStr(resp.message.role), resp.message.content),
                )
            }
        }
        return None
    }
}

public class OllamaChatModel <: ChatModel {
    private let model: String
    private let baseURL: String
    private let temperature: Option<Float64>
    private var _contextLength: Int64

    public init(
        model: String,
        baseURL!: String,
        temperature!: Option<Float64> = None,
        contextLength!: Int64 = Config.defaultContextLen) {
        this.model = model
        this.baseURL = baseURL
        this.temperature = temperature
        this._contextLength = contextLength
    }

    override public prop service: String {
        get() { "ollama" }
    }

    override public prop contextLength: Int64 {
        get() { _contextLength }
    }

    override public prop name: String {
        get() { model }
    }

    private func prepareHeaderAndRequest(chatReq: ChatRequest, stream!: Bool): (HashMap<String, String>, JsonObject) {
        let header = HashMap<String, String>([
            ("Content-Type", "application/json")
        ])

        let req = JsonObject()
        req.put("model", JsonString(model))
        req.put("stream", JsonBool(stream))
        let ja = JsonArray()
        for (m in chatReq.dialog) {
            let jo = JsonObject()
            jo.put("role", JsonString(m.role.toString()))
            jo.put("content", JsonString(m.content))
            if (let Some(image) <- m.image) {
                if (image.startsWith("data:image/")) {
                    let base64 = ";base64,"
                    if (let Some(pos) <- image.indexOf(base64)) {
                        let start = pos + base64.size
                        jo.put("images", JsonArray([JsonString(image[start..])]))
                    }
                } else {
                    jo.put("images", JsonArray([JsonString(image)]))
                }
            }
            ja.add(jo)
        }
        req.put("messages", ja)
        // Prepare option
        if (chatReq.stop.isSome() || chatReq.temperature.isSome() || this.temperature.isSome()) {
            let options = JsonObject()
            // Prepare "temperature"
            if (let Some(temp) <- chatReq.temperature) {
                options.put("temperature", JsonFloat(temp))
            } else if (let Some(temp) <- this.temperature) {
                options.put("temperature", JsonFloat(temp))
            }
            // Prepare "stop"
            if (let Some(items) <- chatReq.stop) {
                if (!items.isEmpty()) {
                    let ja = JsonArray(
                        Array<JsonValue>(items.size, { i: Int64 =>
                            JsonString(items[i])
                        })
                    )
                    options.put("stop", ja)
                }
            }
            req.put("options", options)
        }
        return (header, req)
    }

    override public func create(chatReq: ChatRequest): ChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: false)
        match (HttpUtils.post("${this.baseURL}/api/chat", header, req)) {
            case Some(body) =>
                let resp = OllamaChatResponse.fromJsonValue(JsonValue.fromStr(body))
                let msg = resp.message
                return ChatResponse(
                    Dialog([ChatMessage(ChatMessageRole.fromStr(msg.role), msg.content)]),
                    model
                )
            case None => throw ModelException("Fail to get http respnose")
        }
    }

    override public func asyncCreate(chatReq: ChatRequest): AsyncChatResponse {
        let (header, req) = prepareHeaderAndRequest(chatReq, stream: true)
        let httpStream = HttpUtils.asyncPost("${this.baseURL}/api/chat", header, req)
        let chunkStream = AsyncChatChunkStream(httpStream)
        return AsyncChatResponse(model, chunkStream)
    }
}
