/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.agent_executor.common.AgentTask
import magic.core.message.{Message, Conversation}
import magic.agent_executor.common.PromptBuilder
import magic.log.LogUtils
import magic.prompt.Template
internal import magic.parser.{Tag, WithTag}

// Modified from https://smith.langchain.com/hub/hwchase17/react
protected let REACT_SYSTEM_PROMPT = """
# Guidelines
Use the following format to accomplish user's request:
${Tag.THOUGHT} think about what to do next to solve the question ${Tag.THOUGHT.getCloseTag()}
${Tag.ACTION} use a tool, the action must be a json object wrapped by ```json and ```
    ```json
    {
        "name": string, name of the tool, it must refer to one of available tools
        "arguments": { [key: string]: unknown }, arguments for the tool, each argument must be a valid json value required by the tool; it can be omitted, if the tool does not accept parameters
    }
    ```
    For example,
    ```json
    {
        "name": "foo"
        "arguments": {
            "url": "http://example.com",
            "count": 3,
            "items": ["abc", "xyz"]
        }
    }
    ```
${Tag.ACTION.getCloseTag()}
${Tag.OBSERVATION} the result of the action ${Tag.OBSERVATION.getCloseTag()}
... (Thought/Action/Observation may repeat N times to accomplish user's request)
${Tag.ANSWER} the final answer to the original input question ${Tag.ANSWER.getCloseTag()}

NEVER generate ${Tag.OBSERVATION} yourself. This is an important requirement.

You must generate either a pair of ${Tag.THOUGHT} and ${Tag.ACTION} or a pair of ${Tag.THOUGHT} and ${Tag.ANSWER}
Examples:
Output: ${Tag.THOUGHT} I need to search the web to get related knowledge ${Tag.THOUGHT.getCloseTag()} ${Tag.ACTION} ... ${Tag.ACTION.getCloseTag()}
Output: ${Tag.THOUGHT} I know the final answer now ${Tag.THOUGHT.getCloseTag()} ${Tag.ANSWER} ... ${Tag.ANSWER.getCloseTag()}

- If there are no available tools, generate final answer directly.
"""

private let REACT_SUMMARIZE_SYSTEM_PROMPT = """
# Instruction
Given a question and a solving procedure for it, you should summarize an answer from them.
The solving procedure consists of:
  - ${Tag.THOUGHT} think about what to do next to solve the task ${Tag.THOUGHT.getCloseTag()}
  - ${Tag.ACTION} use a tool, which is a function call ${Tag.ACTION.getCloseTag()}
  - ${Tag.OBSERVATION} the result of the action ${Tag.OBSERVATION.getCloseTag()}
  - ... (Thought/Action/Observation may repeat N times)

The answer should be wrapped by ${Tag.ANSWER} and ${Tag.ANSWER.getCloseTag()} like
${Tag.ANSWER}
Cat is the answer, and ...
${Tag.ANSWER.getCloseTag()}

# Question
{question}
-----

# Solving Procedure
{procedure}
-----

# Some extra context to help answer the question
{systemPrompt}

{retrieval}

{memory}
"""

private let REACT_SUMMARIZE_USER_PROMPT = """
Now, summarize the answer. Remember you should wrap the output by ${Tag.ANSWER} and ${Tag.ANSWER.getCloseTag()}
"""

protected struct ReactPromptUtils {
    static func buildReactPrompt(task: AgentTask): Array<Message> {
        PromptBuilder()
            .system(REACT_SYSTEM_PROMPT.trimAscii())
            .tool(PromptBuilder.buildAgentToolsPrompt(task))
            .system(task.agent.systemPrompt)
            .retrieval(PromptBuilder.buildAgentRetrievalPrompt(task))
            .memory(PromptBuilder.buildAgentMemoryPrompt(task))
            .conversation(task.request.conversation ?? Conversation())
            .buildFor(task.agent.executor)
    }

    static func buildReactSummarizePrompt(task: AgentTask): Array<Message> {
        let strBuilder = StringBuilder()
        for (msg in task.execution.stepMessages) {
            // Only add messages with tags, like [Action]
            if (msg.content.startsWith("[")) {
                strBuilder.append("${msg.content}\n")
            }
        }
        let sys = REACT_SUMMARIZE_SYSTEM_PROMPT.format(
            ("question", task.request.question),
            ("procedure", strBuilder.toString()),
            ("retrieval", PromptBuilder.buildAgentRetrievalPrompt(task)),
            ("systemPrompt", task.agent.systemPrompt),
            ("memory", PromptBuilder.buildAgentMemoryPrompt(task))
        ).trimAscii()
        return [
            Message.system(sys),
            Message.user(REACT_SUMMARIZE_USER_PROMPT.trimAscii())
        ]
    }
}
