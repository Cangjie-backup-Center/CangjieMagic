/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

/**
 * Result of the tool invocation
 */
public struct ToolResponse {
    public let content: String

    public init(content: String) {
        this.content = content
    }
}
