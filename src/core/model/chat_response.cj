/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{Message, MessageList}
import magic.core.tool.ToolRequest
import magic.jsonable.{ToJsonValue, Jsonable}

import stdx.encoding.json.{JsonValue, JsonObject, JsonString}

public struct ChatResponse <: ToString & ToJsonValue {
    public ChatResponse(
        public let model: String,
        public let message: Message,
        public let toolRequests!: Array<ToolRequest> = [],
        public let usage!: Option<ChatUsage> = None
    ) { }

    override public func toJsonValue(): JsonValue {
        let jo = JsonObject()
        jo.put("model", JsonString(model))
        jo.put("message", message.toJsonValue())
        if (!this.toolRequests.isEmpty()) {
            jo.put("toolRequests", this.toolRequests.toJsonValue())
        }
        if (let Some(usage) <- usage) {
            jo.put("usage", usage.toJsonValue())
        }
        return jo
    }

    override public func toString(): String {
        this.toJsonValue().toJsonString()
    }
}
