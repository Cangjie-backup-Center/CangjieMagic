/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.*
import magic.parser.OutputParserUtils
import magic.prompt.Template
import magic.core.message.*
import magic.model.{ModelUtils, ModelManager}
import magic.log.LogUtils
import magic.tool.AgentAsTool

import std.collection.{map, collectArrayList}

private let DISPATCH_PROMPT = """
Given a user question, choose a proper tool to solve it.

## Guidelines

- Never answer the question directly.
- Each tool has a unique name and its description. You should choose one according to their descriptions to help solve the question.
- Only choose one tools from the available tools. If there is no available tool to answer the question, return [Final Answer] NONE [/Final Answer].

# Available Tools
{tools}

# Previous Dialog (with the user)
{dialog}

# Output

Output [Final Answer] tool name you choose [/Final Answer]

If no available tools are chosed, output [Final Answer] NONE [/Final Answer]
"""

/**
 * This agent is used to dispatch user question to other agents.
 * Normally, this agent plays the role of the leader of LeaderGroup.
 **/
public class DispatchAgent <: BaseAgent {
    public init(model!: String) {
        super(name: "Dispatch Agent", model: ModelManager.createChatModel(model))
    }

    private func buildToolsPrompt(): String {
        let strBuilder = StringBuilder()
        for (t in this.toolManager.getTools()) {
            strBuilder.append("${t.name}: ${t.description}\n")
        }
        return strBuilder.toString()
    }

    private func buildDialogPrompt(dialog: Dialog): String {
        if (dialog.isEmpty()) {
            return "None"
        }
        let strBuilder = StringBuilder()
        for (msg in dialog) {
            strBuilder.append("${msg}\n")
        }
        return strBuilder.toString()
    }

    override public func chat(request: AgentRequest): AgentResponse {
        // Tools may be updated, so we build the prompt every time
        let sysPrompt = DISPATCH_PROMPT.format(
            ("tools", buildToolsPrompt()),
            ("dialog", buildDialogPrompt(request.dialog ?? Dialog()))
        )
        let messages: Array<ChatMessage> = [
            ChatMessage.system(sysPrompt),
            ChatMessage.user("Now, choose the tool for the question ${request.question}.")
        ]
        let nameOpt = ModelUtils.agentMakeChatGet(this, messages) {
            msg: ChatMessage => OutputParserUtils.extractLastSection(msg.content, "[Final Answer]")
        }
        let name = nameOpt.getOrThrow({ => AgentExecutionException("Fail to get chat model response.") })
        if (name == "NONE") {
            return AgentResponse("Unknown Question")
        }
        if (let Some(tool) <- this.toolManager.findTool(name)) {
            // All tools are agents
            let agent = (tool as AgentAsTool).getOrThrow().agent
            return agent.chat(request)
        }
        throw AgentExecutionException("Fail to find the tool `${name}`")
    }
}