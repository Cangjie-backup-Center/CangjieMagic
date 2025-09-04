/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.interaction

import magic.core.agent.*

/**
 * The following two functions are used by the @interact/@asyncInteract macro
 */
public func _interact(agent: Agent, request!: AgentRequest,
                                    manager!: EventHandlerManager): AgentResponse {
    request.extra[AgentRequestExtra.EVENT_HANDLER_MANAGER] = manager
    return agent.chat(request)
}

public func _asyncInteract(agent: Agent, request!: AgentRequest,
                                         manager!: EventHandlerManager): AsyncAgentResponse {
    request.extra[AgentRequestExtra.EVENT_HANDLER_MANAGER] = manager
    return agent.asyncChat(request)
}