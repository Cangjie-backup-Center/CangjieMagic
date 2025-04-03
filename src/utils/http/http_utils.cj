/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

import std.collection.concurrent.BlockingQueue
import std.collection.HashMap
import encoding.json.JsonObject

protected class HttpException <: Exception {
    protected init(msg: String) { super(msg) }
}

func logHttpInfo(method: String, url: String, header: HashMap<String, String>, body: Option<JsonObject>, async!: Bool = false) {
    let action = if (async) {
        "async http ${method}"
    } else {
        "http ${method}"
    }
    LogUtils.debug("${action}: ${url}")
    for ((k,v) in header) {
        LogUtils.debug("header: ${k} - ${v}")
    }
    if (let Some(b) <- body) {
        LogUtils.debug("body: ${b.toString()}")
    }
}

private enum Item {
    | Data(String)
    | EOF
    | Error
}

/**
 * A wrapper of blocking queue to support streaming
 */
public class HttpStream <: Iterator<String> {
    private let queue = BlockingQueue<Item>()
    // Set when all data is consumed
    private var finished = false

    public func put(data: String): Unit {
        // LogUtils.debug("put data: `${data}`")
        queue.enqueue(Item.Data(data))
    }

    public func markEOF(): Unit {
        queue.enqueue(Item.EOF)
    }

    public func markError(): Unit {
        queue.enqueue(Item.Error)
    }

    override public func next(): Option<String> {
        if (finished) {
            LogUtils.error("Async stream is finished.")
            throw HttpException("Consume a finished http stream")
        }
        match (queue.dequeue()) {
            case Item.Error =>
                throw HttpException("Http stream error")
            case Item.EOF =>
                finished = true
                LogUtils.debug("Async http stream finished")
                return None
            case Item.Data(data) =>
                // LogUtils.debug("get data: `${data}`")
                return data
        }
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