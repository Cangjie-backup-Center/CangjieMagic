/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.agent.AgentTask
import magic.core.message.*
import magic.log.LogUtils
import magic.prompt.Template

import std.collection.{map, collectArray}

// Modified from https://smith.langchain.com/hub/hwchase17/react
protected let REACT_SYSTEM_PROMPT = """
# Guidelines
Use the following format to accomplish user's request:
${ReactTag.THOUGHT} think about what to do next to solve the question ${ReactTag.THOUGHT.getCloseTag()}
${ReactTag.ACTION} use a tool, the action must be a json object wrapped by ```json and ```
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
${ReactTag.ACTION.getCloseTag()}
${ReactTag.OBSERVATION} the result of the action ${ReactTag.OBSERVATION.getCloseTag()}
... (Thought/Action/Observation may repeat N times to accomplish user's request)
${ReactTag.ANSWER} the final answer to the original input question ${ReactTag.ANSWER.getCloseTag()}

NEVER generate ${ReactTag.OBSERVATION} yourself. This is an important requirement.

You must generate either a pair of ${ReactTag.THOUGHT} and ${ReactTag.ACTION} or a pair of ${ReactTag.THOUGHT} and ${ReactTag.ANSWER}
Examples:
Output: ${ReactTag.THOUGHT} I need to search the web to get related knowledge ${ReactTag.THOUGHT.getCloseTag()} ${ReactTag.ACTION} ... ${ReactTag.ACTION.getCloseTag()}
Output: ${ReactTag.THOUGHT} I know the final answer now ${ReactTag.THOUGHT.getCloseTag()} ${ReactTag.ANSWER} ... ${ReactTag.ANSWER.getCloseTag()}

- If there are no available tools, generate final answer directly.

{tools}

{systemPrompt}

{retrieval}

{memory}

{dialog}
"""

private let REACT_SUMMARIZE_SYSTEM_PROMPT = """
# Instruction
Given a question and a solving procedure for it, you should summarize an answer from them.
The solving procedure consists of:
  - ${ReactTag.THOUGHT} think about what to do next to solve the task ${ReactTag.THOUGHT.getCloseTag()}
  - ${ReactTag.ACTION} use a tool, which is a function call ${ReactTag.ACTION.getCloseTag()}
  - ${ReactTag.OBSERVATION} the result of the action ${ReactTag.OBSERVATION.getCloseTag()}
  - ... (Thought/Action/Observation may repeat N times)

The answer should be wrapped by ${ReactTag.ANSWER} and ${ReactTag.ANSWER.getCloseTag()} like
${ReactTag.ANSWER}
Cat is the answer, and ...
${ReactTag.ANSWER.getCloseTag()}

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

{dialog}

Now, summarize the answer. Remember you should wrap the output by ${ReactTag.ANSWER} and ${ReactTag.ANSWER.getCloseTag()}
"""

protected struct ReactPromptUtils {
    static func buildReactFullSystemPrompt(task: AgentTask): String {
        return REACT_SYSTEM_PROMPT.format(
            ("tools", ReactPromptUtils.buildAgentToolsPrompt(task.agent, task.request.question, enableToolSearch: task.agent.toolManager.enableToolSearch)),
            ("retrieval", ReactPromptUtils.buildAgentRetrievalPrompt(task)),
            ("systemPrompt", task.agent.systemPrompt),
            ("memory", ReactPromptUtils.buildAgentMemoryPrompt(task)),
            ("dialog", ReactPromptUtils.buildAgentDialogPrompt(task))
        ).trimAscii()
    }

    static func buildReactSummarizePrompt(task: AgentTask): String {
        let strBuilder = StringBuilder()
        for (msg in task.execInfo.dialog) {
            // Only add messages with tags, like [Action]
            if (msg.content.startsWith("[")) {
                strBuilder.append("${msg.content}\n")
            }
        }
        return REACT_SUMMARIZE_SYSTEM_PROMPT.format(
            ("question", task.request.question),
            ("procedure", strBuilder.toString()),
            ("retrieval", ReactPromptUtils.buildAgentRetrievalPrompt(task)),
            ("systemPrompt", task.agent.systemPrompt),
            ("memory", ReactPromptUtils.buildAgentMemoryPrompt(task)),
            ("dialog", ReactPromptUtils.buildAgentDialogPrompt(task))
        ).trimAscii()
    }

    protected static func buildAgentToolsPrompt(agent: Agent, question: String, enableToolSearch!: Bool): String {
        let allTools = if (enableToolSearch) {
            agent.toolManager.searchTool(question, number: 5)
        } else {
            agent.toolManager.getTools()
        }
        if (allTools.size == 0) {
            return "# Available Tools\nNo tools"
        }
        let toolStringArr = allTools |> map { t: Tool => t.toString() } |> collectArray
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
