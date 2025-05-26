/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.agent_executor.common.AgentTask
import magic.core.message.*
import magic.agent_executor.common.PromptBuilder
import magic.log.LogUtils
import magic.prompt.Template
internal import magic.parser.{Tag, WithTag}
import std.collection.{map, collectArray}

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
    static func buildReactPrompt(task: AgentTask): Array<ChatMessage> {
        PromptBuilder(task.agent.model.contextLen)
            .system(REACT_SYSTEM_PROMPT.trimAscii())
            .tool(ReactPromptUtils.buildAgentToolsPrompt(task))
            .system(task.agent.systemPrompt)
            .retrieval(ReactPromptUtils.buildAgentRetrievalPrompt(task))
            .memory(ReactPromptUtils.buildAgentMemoryPrompt(task))
            .history(task.request.dialog)
            .user(task.request.question)
            .build()
    }

    static func buildReactSummarizePrompt(task: AgentTask): Array<ChatMessage> {
        let strBuilder = StringBuilder()
        for (msg in task.execInfo.dialog) {
            // Only add messages with tags, like [Action]
            if (msg.content.startsWith("[")) {
                strBuilder.append("${msg.content}\n")
            }
        }
        let sys = REACT_SUMMARIZE_SYSTEM_PROMPT.format(
            ("question", task.request.question),
            ("procedure", strBuilder.toString()),
            ("retrieval", ReactPromptUtils.buildAgentRetrievalPrompt(task)),
            ("systemPrompt", task.agent.systemPrompt),
            ("memory", ReactPromptUtils.buildAgentMemoryPrompt(task))
        ).trimAscii()
        PromptBuilder(task.agent.model.contextLen)
            .system(sys)
            .history(task.request.dialog)
            .user(REACT_SUMMARIZE_USER_PROMPT.trimAscii())
            .build()
    }

    protected static func buildAgentToolsPrompt(task: AgentTask): String {
        let tools = task.availableTools
        if (tools.size == 0) {
            return "# Available Tools\nNo tools"
        }
        let toolStringArr = tools |> map { t: Tool => t.toString() } |> collectArray
        let str = String.join(toolStringArr, delimiter: ",\n")
        return "# Available Tools\n[\n ${str} \n]\n---end of tools---"
    }

    protected static func buildAgentRetrievalPrompt(task: AgentTask): String {
        if (let Some(rt) <- task.agent.retriever) {
            if (rt.mode == RetrieverMode.Dynamic) {
                return ""
            }
            let query = task.request.question
            let retrieval = rt.search(query)
            task.execInfo.addRetrieval(query, retrieval)
            return "# Retrieved Content\n${retrieval.toPrompt()}\n---end of Retrieved Content---"
        } else {
            return ""
        }
    }

    protected static func buildAgentMemoryPrompt(task: AgentTask): String {
        let agent = task.agent
        let query = task.request.question
        if (let Some(memory) <- agent.memory) {
            let docs = memory.search(query)
            if (docs.size == 0) {
                LogUtils.info(agent.name, "Memory not found")
                return ""
            }
            let strBuilder = StringBuilder()
            strBuilder.append("# Memory\n")
            strBuilder.append("The following is the QA history that contains the user question, the solution steps (including thoughts and actions), and the final answer.\n")
            strBuilder.append("When solving new problems, you can refer to past execution history.\n")
            for (idx in 0..docs.size) {
                strBuilder.append("## Memory ${idx+1}: \n")
                strBuilder.append(docs[idx])
                strBuilder.append("\n---\n")
            }
            strBuilder.append("---end of memory---\n")
            return strBuilder.toString()
        } else {
            return ""
        }
    }

    protected static func buildAgentDialogPrompt(task: AgentTask): String {
        if (let Some(dialog) <- task.request.dialog) {
            let strBuilder = StringBuilder()
            strBuilder.append("# Previous Dialog (with the user)\n")
            for (msg in dialog) {
                strBuilder.append("${msg}\n")
            }
            return strBuilder.toString()
        } else {
            return ""
        }
    }
}
