/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.message.{ChatMessage, ChatMessageRole, Dialog}
import magic.core.model.{ChatModel, ChatRequest}
import magic.model.ModelUtils
import magic.log.LogUtils
import magic.prompt.Template

import std.collection.ArrayList

private let AGENT_SUMMARY_PROMPT = """
# Task
Given instructions for an agent, summarize a description of the agent's functionality.
If the instructions include information about inputs and outputs, this should also be described in the functional description.
The output should be complete but also brief.

# Agent Instruction
{instruction}

Now, make the summary:
"""

func summarize(model: ChatModel, content: String): String {
    let messages = [
        ChatMessage.system(AGENT_SUMMARY_PROMPT.format(
            ("instruction", content)
        ))
    ]
    if (let Some(msg) <- ModelUtils.makeChat(model, messages)) {
        return msg.content
    } else {
        LogUtils.debug("Summarize failed")
        return "None"
    }
}