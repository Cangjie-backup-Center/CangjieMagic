/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.*
import magic.model.ModelManager
import magic.log.LogUtils
import magic.tool.AgentAsTool

/**
 * This agent is used to dispatch user question to other agents.
 * It's a special case of ToolSelectAgent, whose tools are agents.
 * Normally, this agent plays the role of the leader of LeaderGroup.
 **/
public class DispatchAgent <: BaseAgent {
    public init(model!: String) {
        super(name: "Dispatch Agent", model: ModelManager.createChatModel(model))
    }

    override public func chat(request: AgentRequest): AgentResponse {
        // Tools are updated when building the leader group, so we build the prompt every time
        let selectAgent = ToolSelectAgent(this.model, this.toolManager.getTools())
        if (let Some(toolRequest) <- selectAgent.select(request.question)) {
            if (let Some(tool) <- this.toolManager.findTool(toolRequest.name)) {
                LogUtils.info(this.name, "Dispatch to ${toolRequest.name}")
                // All tools are agents
                // Pass LLM generated arguments or the original request?
                // tool.invoke(toolRequest.args)
                let agent = (tool as AgentAsTool).getOrThrow().agent
                return agent.chat(request)
            } else {
                throw AgentExecutionException("Fail to find the tool `${name}`")
            }
        } else {
            return AgentResponse("Unknown Question")
        }
    }
}
