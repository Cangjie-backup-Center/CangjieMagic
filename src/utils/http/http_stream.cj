/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

import std.collection.concurrent.BlockingQueue
import std.collection.{HashMap, ArrayList}
import encoding.json.JsonObject
import magic.dsl.prompt

enum Item {
    | Str(String)
    | Bytes(Array<Byte>)
    | EOF
    | Error
}

/**
 * A http stream is an iterator of strings
 * Wrap of a blocking queue to support streaming.
 */
protected abstract class HttpStream <: Iterator<String> {
    let queue = BlockingQueue<Item>()

    // Set when all data is consumed
    var finished = false

    public func put(data: String): Unit {
        // LogUtils.debug("put data: `${data}`")
        queue.enqueue(Item.Str(data))
    }

    public func put(data: Array<Byte>): Unit {
        // LogUtils.debug("put data: `${data}`")
        queue.enqueue(Item.Bytes(data))
    }

    public func markEOF(): Unit {
        queue.enqueue(EOF)
    }

    public func markError(): Unit {
        queue.enqueue(Item.Error)
    }
}

/**
 * The blocking queue stores strings.
 */
protected class HttpStringStream <: HttpStream {
    override public func next(): Option<String> {
        if (finished) {
            LogUtils.error("Http string stream is finished.")
            throw HttpException("Consume a finished http string stream")
        }
        match (queue.dequeue()) {
            case Error =>
                throw HttpException("Http string stream error")
            case EOF =>
                finished = true
                LogUtils.debug("Http string stream finished")
                return None
            case Str(data) =>
                // LogUtils.debug("get data: `${data}`")
                return data
            case Bytes(_) =>
                throw HttpException("Http string stream error")
        }
    }
}

/**
 * The blocking queue stores raw bytes.
 */
protected class HttpByteStream <: HttpStream {
    private let lineBuffer = ArrayList<String>()

    override public func next(): Option<String> {
        if (finished) {
            LogUtils.error("Http byte stream is finished.")
            throw HttpException("Consume a finished http byte stream")
        }
        let receivedBytes = ArrayList<Byte>()
        while (true) {
            // If the line buffer is not empty, just return the first line
            if (!this.lineBuffer.isEmpty()) {
                let line = this.lineBuffer[0]
                this.lineBuffer.remove(0)
                LogUtils.debug("Http byte stream recv: `${line}`")
                return line
            }
            // otherwise, read more bytes
            match (queue.dequeue()) {
                case Error =>
                    throw HttpException("Http byte stream error")
                case EOF =>
                    finished = true
                    LogUtils.debug("Http byte stream finished")
                    if (!this.lineBuffer.isEmpty()) {
                        throw HttpException("Http byte stream finished with non-empty buffer")
                    }
                    return None
                case Str(_) =>
                    throw HttpException("Http byte stream error")
                case Bytes(bytes) =>
                    receivedBytes.appendAll(bytes)
                    try {
                        // Try to decode bytes as a string
                        let content = String.fromUtf8(receivedBytes.toArray())
                        for (line in content.split("\n", removeEmpty: true)) {
                            LogUtils.debug("Http byte stream add: `${line}`")
                            lineBuffer.append(line)
                        }
                    } catch (_: IllegalArgumentException) {
                        // If decoding failed, read more bytes
                        continue
                    }
            }
        }
        throw UnsupportedException("Unreachable")
    }
}

protected struct SSEvent <: ToString {
    SSEvent(protected let event: String,
            protected let data: String) { }

    override public func toString(): String {
        return "event: ${event}\ndata: ${data}"
    }
}

protected class SSEventStream <: Iterator<SSEvent> {
    SSEventStream(private let httpStream: HttpStream) { }

    override public func next(): Option<SSEvent> {
        while (true) {
            var event = ""
            var data = ""
            if (let Some(line) <- httpStream.next()) {
                if (line.trimAscii().isEmpty()) {
                    continue
                } else if (line.startsWith(": ping")) {
                    continue
                }
                event = line.removePrefix("event:").trimAscii()
            } else {
                return None
            }
            if (let Some(line) <- httpStream.next()) {
                data = line.removePrefix("data:").trimAscii()
            } else {
                return None
            }
            return SSEvent(event, data)
        }
        throw UnsupportedException("Unreachable")
    }
}

protected struct HttpUtils {
    static protected func get(url: String,
                              header: HashMap<String, String>,
                              body: Option<JsonObject>,
                              verify!: Bool = false): Option<String> {
        return HttpUtilsImpl.send("GET", url, header, body, verify: verify)
    }

    static protected func post(url: String,
                               header: HashMap<String, String>,
                               body: JsonObject,
                               verify!: Bool = false): Option<String> {
        return HttpUtilsImpl.send("POST", url, header, body, verify: verify)
    }

    static protected func asyncGet(url: String,
                                   header: HashMap<String, String>,
                                   body: Option<JsonObject>,
                                   verify!: Bool = false): HttpStream {
        return HttpUtilsImpl.asyncSend("GET", url, header, body, verify: verify)
    }

    static protected func asyncPost(url: String,
                                    header: HashMap<String, String>,
                                    body: JsonObject,
                                    verify!: Bool = false): HttpStream {
        return HttpUtilsImpl.asyncSend("POST", url, header, body, verify: verify)
    }

    /**
    * HTTP Server-Sent Events
    */
    static protected func sseConnect(url: String, verify!: Bool = false): SSEventStream {
        let header = HashMap<String, String>()
        header.put("Accept", "text/event-stream")
        let httpStream = HttpUtils.asyncGet(url, header, None, verify: verify)
        return SSEventStream(httpStream)
    }
}
