/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils

import std.collection.concurrent.BlockingQueue
import std.collection.HashMap
import encoding.json.JsonValue

protected class HttpException <: Exception {
    protected init(msg: String) { super(msg) }
}

@When[ohos == "true"]
public func httpPost(url: String,
                     header: HashMap<String, String>,
                     body: JsonValue,
                     verify!: Bool = false): ?String {
    for((k,v) in header){
        LogUtils.debug("httpPost: ${k} - ${v}")
    }
    LogUtils.debug("httpPost: ${body.toJsonString()}")
    return httpPostOhos(url, header, body, verify: verify)
}

@When[ohos != "true" && http == "curl"]
public func httpPost(url: String,
                     header: HashMap<String, String>,
                     body: JsonValue,
                     verify!: Bool = false): ?String {
    for((k,v) in header){
        LogUtils.debug("httpPost: ${k} - ${v}")
    }
    LogUtils.debug("httpPost: ${body.toString()}")
    return httpPostCurl(url, header, body, verify: verify)
}

@When[ohos != "true" && http != "curl"]
public func httpPost(url: String,
                     header: HashMap<String, String>,
                     body: JsonValue,
                     verify!: Bool = false): ?String {
    for((k,v) in header){
        LogUtils.debug("httpPost: ${k} - ${v}")
    }
    LogUtils.debug("httpPost: ${body.toString()}")
    return httpPostCJ(url, header, body, verify: verify)
}

//================================================================================

/**
 * A wrapper of blocking queue to support streaming
 */
public class HttpStream <: Iterator<String> {
    private static let EOF_MARK = "[EOF_stream]"
    private static let ERROR_MARK = "[ERROR_stream]"

    private let queue = BlockingQueue<String>()
    // Set when all data is consumed
    private var finished = false

    public func put(data: String): Unit {
        queue.enqueue(data)
    }

    public func markEOF(): Unit {
        queue.enqueue(HttpStream.EOF_MARK)
    }

    public func markError(): Unit {
        queue.enqueue(HttpStream.ERROR_MARK)
    }

    override public func next(): Option<String> {
        if (finished) {
            LogUtils.error("Async stream is finished.")
            throw HttpException("Consume a finished http stream")
        }
        let data = queue.dequeue()
        if (data == HttpStream.ERROR_MARK) {
            throw HttpException("Http stream error")
        } else if (data == HttpStream.EOF_MARK) {
            finished = true
            LogUtils.debug("Async http stream finished")
            return None
        } else {
            return data
        }
    }
}

@When[ohos == "true"]
public func asyncHttpPost(url: String,
                          header: HashMap<String, String>,
                          body: JsonValue,
                          verify!: Bool = false): HttpStream {
    for((k,v) in header){
        LogUtils.debug("async httpPost: ${k} - ${v}")
    }
    LogUtils.debug("async httpPost: ${body.toString()}")
    return asyncHttpPostOhos(url, header, body, verify: verify)
}

@When[ohos != "true" && http == "curl"]
public func asyncHttpPost(url: String,
                          header: HashMap<String, String>,
                          body: JsonValue,
                          verify!: Bool = false): HttpStream {
    for((k,v) in header){
        LogUtils.debug("async httpPost: ${k} - ${v}")
    }
    LogUtils.debug("async httpPost: ${body.toString()}")
    return asyncHttpPostCurl(url, header, body, verify: verify)
}

@When[ohos != "true" && http != "curl"]
public func asyncHttpPost(url: String,
                          header: HashMap<String, String>,
                          body: JsonValue,
                          verify!: Bool = false): HttpStream {
    for((k,v) in header){
        LogUtils.debug("async httpPost: ${k} - ${v}")
    }
    LogUtils.debug("async httpPost: ${body.toString()}")
    return asyncHttpPostCJ(url, header, body, verify: verify)
}