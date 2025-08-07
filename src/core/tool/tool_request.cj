/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

import magic.jsonable.{ToJsonValue}

import std.collection.{HashMap, map, collectArray}
import stdx.encoding.json.{JsonValue, JsonObject, JsonString}

/**
 * Since it's hard to define its type schema, we do not let it implement Jsonable.
 */
public struct ToolRequest <: ToString & ToJsonValue {
    public let name: String                    // Tool name
    public let args: HashMap<String, JsonValue> // Tool arguments

    public init(name!: String, args!: HashMap<String, JsonValue>) {
        this.name = name
        this.args = args
    }

    public init(name!: String, args!: JsonObject) {
        this.name = name
        this.args = args.getFields()
    }

    override public func toString(): String {
        let args = this.args.iterator() |>
            map { kv: (String, JsonValue) =>
                return "${kv[0]}: ${kv[1].toString()}"
            } |>
            collectArray
        return "${this.name}(${String.join(args, delimiter: ", ")})"
    }

    override public func toJsonValue(): JsonValue {
        let jo = JsonObject()
        jo.put("name", JsonString(this.name))
        let argsJo = JsonObject()
        for (kv in this.args) {
            argsJo.put(kv[0], kv[1])
        }
        jo.put("arguments", argsJo)
        return jo
    }
}