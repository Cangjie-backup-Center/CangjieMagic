/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.agent.*
import magic.core.tool.*
import magic.jsonable.TypeSchema
import magic.model.ModelUtils
import magic.core.message.{Message, MessageRole, MessageList}
import magic.core.model.{ChatModel, ChatRequest}
import magic.log.LogUtils
import magic.prompt.Template

import std.collection.ArrayList
import std.collection.HashMap
import stdx.encoding.json.JsonValue

private let AGENT_SUMMARY_PROMPT = """
# Task
Given instructions for an agent, summarize a description of the agent's functionality.
If the instructions include information about inputs and outputs, this should also be described in the functional description.
The output should be complete but also brief.

# Agent Instruction
{instruction}

Now, make the summary:
"""

protected class AgentAsTool <: AbsTool {
    protected let agent: Agent

    public init(agent: Agent) {
        this.agent = agent
    }

    public prop name: String {
        get() { this.agent.name }
    }

    public prop description: String {
        get() {
            return if (this.agent.description == "") {
                this.summarize()
            } else {
                this.agent.description
            }
        }
    }

    public prop parameters: Array<ToolParameter> {
        get() { [ToolParameter("question", "The input question", TypeSchema.Str)] }
    }

    public prop retType: TypeSchema {
        get() { TypeSchema.Str }
    }

    public prop examples: Array<String> {
        get() { [] }
    }

    override public func invoke(args: HashMap<String, JsonValue>): ToolResponse {
        if (args.size == 1) {
            // The agent tool must receive a string
            let question = args["question"].asString().getValue()
            let resp = this.agent.chat(AgentRequest(question))
            return ToolResponse(resp.content)
        } else {
            throw ToolException("Agent as tool with invalid arguments")
        }
    }

    private func summarize(): String {
        let messages = MessageList([
            Message.system(AGENT_SUMMARY_PROMPT.format(
                ("instruction", this.agent.systemPrompt)
            ))
        ])
        if (let Some(chatResp) <- ModelUtils.agentMakeChat(this.agent, messages)) {
            return chatResp.message.content
        } else {
            LogUtils.debug("Summarize failed")
            return "None"
        }
    }
}