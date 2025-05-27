/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.naive

import magic.core.agent.*
import magic.utils.*
import magic.agent_executor.common.AgentTask
import magic.agent_executor.react.ReactPromptUtils
import magic.log.LogUtils
import magic.core.message.{ChatMessage, Dialog}
import magic.core.model.ChatRequest
import magic.model.ModelUtils
import magic.prompt.Template
import magic.agent_executor.common.*
import std.collection.collectArray

public class NaiveExecutor <: AgentExecutor {

    override public prop name: String {
        get() {"naive"}
    }

    private func getFullDialog(task: AgentTask): Array<ChatMessage> {
        // The system prompt of a naive agent may be empty
        let sysPrompt = if (task.agent.systemPrompt != "") {
            task.agent.systemPrompt
        } else {
            "Answer user question"
        }
        PromptBuilder(task.agent.model.contextLength)
            .system(sysPrompt)
            .retrieval(ReactPromptUtils.buildAgentRetrievalPrompt(task))
            .memory(ReactPromptUtils.buildAgentMemoryPrompt(task))
            .dialog(task.request.dialog ?? Dialog())
            .user(task.request.question)
            .build()
    }

    public override func run(agent: Agent, request: AgentRequest): AgentResponse {
        let task = AgentTask(agent, request)
        let dialog = task.execInfo.dialog
        LogUtils.info("${agent.name} runs")
        dialog.addMessage(getFullDialog(task))
        LogUtils.info(agent.name, dialog)
        let assistantMsg = ModelUtils.makeChat(agent.model, dialog).getOrThrow()
        dialog.addMessage(assistantMsg)
        LogUtils.info(agent.name, assistantMsg)
        return AgentResponse(assistantMsg.content, execInfo: task.execInfo)
    }

    public override func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let task = AgentTask(agent, request)
        let dialog = task.execInfo.dialog
        LogUtils.info("${agent.name} async runs")
        dialog.addMessage(getFullDialog(task))
        LogUtils.info(agent.name, dialog)
        let asyncChatResp = agent.model.asyncCreate(ChatRequest(dialog, temperature: agent.temperature))
        if (request.verbose) {
            task.execInfo.verboseChannel.close()
        }
        return AsyncAgentResponse(asyncChatResp.iter(), execInfo: task.execInfo)
    }
}
