/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

import encoding.json.JsonValue
import encoding.json.JsonException

protected interface StringExt { }

@When[cjc_version < "0.56.4"]
extend String <: StringExt {
    public func removePrefix(prefix: String): String {
        return this.trimLeft(prefix)
    }

    public func removeSuffix(suffix: String): String {
        return this.trimRight(suffix)
    }

   public func asJsonValue(): JsonValue {
        try {
            let jv = JsonValue.fromStr(this)
            return jv
        } catch (ex: JsonException) {
            JsonException("Fail to parse JSON: ${this}.")
            throw ex
        }
    }
}

@When[cjc_version >= "0.56.4"]
extend String <: StringExt {
   public func asJsonValue(): JsonValue {
        try {
            let jv = JsonValue.fromStr(this)
            return jv
        } catch (ex: JsonException) {
            JsonException("Fail to parse JSON: ${this}.")
            throw ex
        }
    }

    public func trimAsciiLeft(): String {
        return this.trimAsciiStart()
    }

    public func trimAsciiRight(): String {
        return this.trimAsciiEnd()
    }
}