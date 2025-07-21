/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.interaction

import magic.core.agent.{Agent, AgentRequest, AgentResponse, AsyncAgentResponse}

public func interaction(agent: Agent, request!: AgentRequest,
                                      manager!: EventHandlerManager): AgentResponse {
    request.extra[EventHandlerManager.CLASS_NAME] = manager
    return agent.chat(request)
}

public func asyncInteraction(agent: Agent, request!: AgentRequest,
                                           manager!: EventHandlerManager): AsyncAgentResponse {
    request.extra[EventHandlerManager.CLASS_NAME] = manager
    return agent.asyncChat(request)
}