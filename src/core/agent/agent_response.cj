/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.MessageList

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
    private var _execution: Option<AgentExecution> = None

    public prop execution: AgentExecution {
        get() { this._execution.getOrThrow() }
    }

    public init(content: String) {
        this.content = content
    }

    public init(content: String, execution!: AgentExecution) {
        this.content = content
        this._execution = execution
        execution.setAnswer(content)
    }
}