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
private let REACT_SYSTEM_PROMPT = """
# Guidelines
Use the following format to accomplish user's request:
[Thought] think about what to do next to solve the question [/Thought]
[Action] use a tool, the action must be a json object wrapped by ```json and ```
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
[/Action]
[Observation] the result of the action [/Observation]
... (Thought/Action/Observation may repeat N times to accomplish user's request)
[Final Answer] the final answer to the original input question [/Final Answer]

NEVER generate [Observation] yourself. This is an important requirement.

You must generate either a pair of [Thought] and [Action] or a pair of [Thought] and [Final Answer]
Examples:
Output: [Thought] I need to search the web to get related knowledge [/Thought] [Action] ... [/Action]
Output: [Thought] I know the final answer now [/Thought] [Final Answer] ... [/Final Answer]

- If there are no available tools, generate final answer directly.

{tools}

{systemPrompt}

{retrieval}

{memory}

{dialog}
"""

protected struct ReactPromptUtils {
    static func buildReactFullSystemPrompt(task: AgentTask): String {
        let agent = task.agent
        let request = task.request
        let retrieval = if (let Some(RetrieverMode.Static) <- task.agent.retriever?.mode) {
            ReactPromptUtils.buildAgentRetrievalPrompt(task)
        } else {
            ""
        }
        return REACT_SYSTEM_PROMPT.format(
            ("tools", ReactPromptUtils.buildAgentToolsPrompt(agent, request.question, enableToolSearch: agent.toolManager.enableToolSearch)),
            ("retrieval", retrieval),
            ("systemPrompt", agent.systemPrompt),
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
        let agent = task.agent
        if (let Some(rt) <- agent.retriever) {
            let query = task.request.question
            LogUtils.info(agent.name, "=============    RAG     ===================\n")
            let docs = rt.search(query)
            task.execInfo.addRetrieval(query, docs)
            LogUtils.info(agent.name, "==============    END RAG ===================\n")
            let content = String.join(
                docs |> map { doc: Document => doc.content } |> collectArray,
                delimiter: "\n"
            )
            return "# Retrieved Content\n${content}\n---end of Retrieved Content---"
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
