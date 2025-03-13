/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_group

import magic.core.agent.Agent
import magic.agent.AbsAgent

/**
 * This interface is used to extend agent-collaboration for agents
 */
public interface AgentCollaboration { }

extend AbsAgent <: AgentCollaboration {
    /**
     * Operator override for creating LeaderGroup. a <= [b, c]
     */
    public operator func <=(members: Array<Agent>): LeaderGroup {
        return LeaderGroup(this, members)
    }

    /**
     * Operator override for creating LinearGroup. a |> b |> c
     */
    public operator func ()(prev: Agent): LinearGroup {
        return LinearGroup(prev, this)
    }

    public operator func ()(prev: LinearGroup): LinearGroup {
        return prev.addNext(this)
    }

    /**
     * Operator override for creating FreeGroup. a | b | c
     */
    public operator func |(member: Agent): FreeGroup {
        return FreeGroup(this, member)
    }
}

public func subGroup(group: AgentGroup, description!: String): Agent {
    return GroupAsAgent(group, description)
}