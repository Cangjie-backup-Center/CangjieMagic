/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

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
