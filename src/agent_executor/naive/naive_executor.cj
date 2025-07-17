/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.naive

import magic.core.agent.*
import magic.utils.*
import magic.agent_executor.common.AgentTask
import magic.agent_executor.react.ReactPromptUtils
import magic.log.LogUtils
import magic.core.message.{Message, MessageList, Conversation}
import magic.core.model.ChatRequest
import magic.model.ModelUtils
import magic.prompt.Template
import magic.agent_executor.common.*
import std.collection.collectArray

public class NaiveExecutor <: AgentExecutor {
    override public prop name: String {
        get() { "naive" }
    }

    private func buildNaivePrompt(task: AgentTask): Array<Message> {
        // The system prompt of a naive agent may be empty
        let sysPrompt = if (task.agent.systemPrompt.isEmpty()) {
            "Answer user question"
        } else {
            task.agent.systemPrompt
        }
        PromptBuilder()
            .system(sysPrompt)
            .retrieval(PromptBuilder.buildAgentRetrievalPrompt(task))
            .memory(PromptBuilder.buildAgentMemoryPrompt(task))
            .conversation(task.request.conversation ?? Conversation())
            .buildFor(this)
    }

    public override func run(agent: Agent, request: AgentRequest): AgentResponse {
        let task = AgentTask(agent, request, initPrompt: false)
        try {
            LogUtils.info("${agent.name} runs")
            task.execution.addMessages(this.buildNaivePrompt(task))
            task.execution.addRequest(request)
            LogUtils.info(agent.name, task.execution.messages)
            let msg = task.chatLLM(task.execution.messages).getOrThrow()
            LogUtils.info(agent.name, msg)
            return AgentResponse(msg.content, execution: task.execution)
        } finally {
            if (request.verbose) {
                task.execution.events.close()
            }
        }
    }

    public override func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let task = AgentTask(agent, request, initPrompt: false)
        try {
            LogUtils.info("${agent.name} async runs")
            task.execution.addMessages(this.buildNaivePrompt(task))
            task.execution.addRequest(request)

            LogUtils.info(agent.name, task.execution.messages)
            let asyncChatResp = agent.model.asyncCreate(
                ChatRequest(task.execution.messages, temperature: agent.temperature)
            )
            return AsyncAgentResponse(asyncChatResp.iter(), execution: task.execution)
        } finally {
            if (request.verbose) {
                task.execution.events.close()
            }
        }
    }
}
