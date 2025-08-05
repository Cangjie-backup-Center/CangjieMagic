/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils

import std.collection.HashMap
import stdx.encoding.json.JsonObject

protected class HttpException <: Exception {
    protected HttpException(
        protected let error: String
    ) { super(error) }
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
        header.add("Accept", "text/event-stream")
        let httpStream = HttpUtils.asyncGet(url, header, None, verify: verify)
        return SSEventStream(httpStream)
    }
}
