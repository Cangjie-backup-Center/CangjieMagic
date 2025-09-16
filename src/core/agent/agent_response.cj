/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.MessageList

import std.deriving.Derive

/**
 * The status of the agent response
 */
@Derive[ToString, Equatable]
public enum AgentResponseStatus {
    | Success // The execution is successful
    | Cancelled  // The execution is canceled by user
}

/**
 The execution response from an agent executor
 */
public struct AgentResponse {
    /**
     * The status of the agent response
     */
    public let status: AgentResponseStatus

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

    public init(status: AgentResponseStatus, content: String) {
        this.status = status
        this.content = content
    }

    public init(status: AgentResponseStatus, content: String, execution!: AgentExecution) {
        this.status = status
        this.content = content
        this._execution = execution
        execution.setAnswer(content)
    }
}