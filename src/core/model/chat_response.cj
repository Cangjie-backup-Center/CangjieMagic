/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{Message, MessageList}
import magic.core.tool.ToolRequest
import magic.jsonable.ToJsonValue

import stdx.encoding.json.{JsonValue, JsonObject, JsonString}

public struct ChatResponse <: ToString & ToJsonValue {
    public ChatResponse(
        public let model: String,
        public let message: Message,
        public let toolRequest!: Option<ToolRequest> = None,
        public let usage!: Option<ChatUsage> = None
    ) { }

    override public func toJsonValue(): JsonValue {
        let jo = JsonObject()
        jo.put("model", JsonString(model))
        jo.put("message", message.toJsonValue())
        if (let Some(toolReq) <- toolRequest) {
            jo.put("toolRequest", toolReq.toJsonValue())
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
