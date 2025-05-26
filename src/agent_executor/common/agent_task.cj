/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.agent.*
import magic.core.tool.{Tool, ToolSearchConfig}
import magic.core.message.{ChatMessage, Dialog}
import magic.log.LogUtils

public open class AgentTask {
    public let agent: Agent
    public let request: AgentRequest
    // Information during the execution
    public var step = 0
    public let execInfo: AgentExecutionInfo

    protected init(agent: Agent, request: AgentRequest, initPrompt!: Bool = false, dialog!: ?Dialog = None) {
        this.agent = agent
        this.request = request
        this.execInfo = request.execInfo ?? AgentExecutionInfo(agent.executor, dialog:dialog)
        if (initPrompt) {
            this.execInfo.dialog.addMessage([
                ChatMessage.system(agent.systemPrompt),
                ChatMessage.user(request.question)
            ])
            LogUtils.info(agent.name, this.execInfo.dialog)
        }
    }

    /**
     * Get available and related tools for the current request
     */
    var _availableTools: Option<Array<Tool>> = None
    protected prop availableTools: Array<Tool> {
        get() {
            if (let Some(tools) <- this._availableTools) {
                return tools
            }
            let tools = agent.toolManager.filterTool(
                request.question,
                ToolSearchConfig(chatModel: agent.model, number: request.maxTool)
            )
            this._availableTools = tools
            return tools
        }
    }
}
