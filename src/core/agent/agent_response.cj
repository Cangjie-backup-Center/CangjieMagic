/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Dialog

/**
 The execution response from an agent executor
 */
public struct AgentResponse {
    /**
     * The execution result
     */
    public let content: String

    /**
     * Internal information during the execution
     */
    public let execInfo: Option<AgentExecutionInfo>

    public init(content: String) {
        this.content = content
        this.execInfo = None
    }

    public init(content: String, execInfo!: AgentExecutionInfo) {
        this.content = content
        this.execInfo = execInfo
    }
}