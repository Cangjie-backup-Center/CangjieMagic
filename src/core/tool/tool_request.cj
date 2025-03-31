/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

import std.collection.HashMap
import encoding.json.JsonValue

public struct ToolRequest {
    public ToolRequest(
        public let name!: String,                    // Tool name
        public let args!: HashMap<String, JsonValue> // Tool arguments
    ) { }
}