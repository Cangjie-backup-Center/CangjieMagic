/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */
package magic.agent_executor.plan_react

import magic.core.agent.*
import magic.core.message.{Message, MessageList}
import magic.core.model.ChatRequest
import magic.prompt.Template
import magic.log.LogUtils
import magic.model.ModelUtils

private let RESULT_SUMMARIZE_USER_PROMPT = """
# Instruction
A question is decomposed as multiple tasks.
Given these tasks and their results, you should summarize an answer for questions.
Directly generate the answer, do not generate irrelevant content.

# Question
The question you should answer.
{question}
-----

# Subtasks
The question is decomposed as multiple tasks. Here are their results.
{progress}
-----

Now, summarize the answer:
"""

func resultSummarize(planTask: PlanTask): String {
    let userPrompt = RESULT_SUMMARIZE_USER_PROMPT.format(
        ("question", planTask.request.question),
        ("progress", planTask.progress),
    )
    let messages = [
        Message.user(userPrompt)
    ]
    return ModelUtils.agentMakeChat(planTask.agent, messages).getOrThrow({ =>
        AgentExecutionException("Fail to get chat model response")
    }).content
}

func asyncResultSummarize(planTask: PlanTask): Iterator<String> {
    let userPrompt = RESULT_SUMMARIZE_USER_PROMPT.format(
        ("question", planTask.request.question),
        ("progress", planTask.progress),
    )
    let messages = [
        Message.user(userPrompt)
    ]
    LogUtils.info(planTask.agent.name, messages)
    return planTask.agent.model.asyncCreate(ChatRequest(messages)).iter()
}