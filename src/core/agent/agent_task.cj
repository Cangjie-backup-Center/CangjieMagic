/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

public open class AgentTask {
    public let agent: Agent
    public let request: AgentRequest
    // Information during the execution
    public var step = 0
    public let execInfo = AgentExecutionInfo()

    protected init(agent: Agent, request: AgentRequest) {
        this.agent = agent
        this.request = request
    }
}