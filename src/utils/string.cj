/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

import std.collection.ArrayList

import stdx.encoding.json.JsonValue
import stdx.encoding.json.JsonException

protected interface StringExt { }

extend String <: StringExt {
    public func trimAsciiLeft(): String {
        return this.trimAsciiStart()
    }

    public func trimAsciiRight(): String {
        return this.trimAsciiEnd()
    }
}