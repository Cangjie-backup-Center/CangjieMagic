/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool.common

import magic.dsl.tool
import magic.tool.NativeFuncTool
import magic.jsonable.*

import encoding.json.JsonValue
@When[cjc_version < "0.56.4"]
import std.time.Duration
import std.time.{DateTime, TimeZone}
import std.collection.{ArrayList, HashMap}

let AISA_SH_TZ = TimeZone("Asia/Shanghai", Duration.hour * 8)

@tool[ description = "获取当前时间" ]
public func getCurrentTime(): String {
    let now = DateTime.now(timeZone: AISA_SH_TZ)
    return "Now is ${now.hour}:${now.minute}, ${now.month} ${now.dayOfMonth}, ${now.year}"
}