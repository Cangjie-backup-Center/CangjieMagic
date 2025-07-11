/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.agent.AgentExecutor
import magic.core.tool.Tool
import magic.core.rag.RetrieverMode
import magic.core.message.{Message, Conversation}
import magic.tokenizer.{TokenizerLoader, TokenizerType}
import magic.parser.{Tag, WithTag}
import magic.log.LogUtils

import std.collection.{ArrayList, forEach, map, filter, collectArray}

/**
 * A builder for constructing agent system prompts.
 * This class is used to build the initial prompts for the agent executor.
 * It usually builds
 *   - the system prompt (comprising system, retrieval, tool, and memory prompts),
 *   - the conversation (between the agent and user),
 */
protected class PromptBuilder {
    private let systemMessages = ArrayList<Message>()
    private var _conversation: Option<Conversation> = None

    public func system(prompt: String): PromptBuilder {
        if (!prompt.trimAscii().isEmpty()) {
            this.systemMessages.add(Message.system(prompt))
        }
        this
    }

    public func retrieval(prompt: String): PromptBuilder {
        // Treat retrieval prompt as a part of the system message
        this.system(prompt)
    }

    public func tool(prompt: String): PromptBuilder {
        // Treat tool prompt as a part of the system message
        this.system(prompt)
    }

    public func memory(prompt: String): PromptBuilder {
        // Treat memory prompt as a part of the system message
        this.system(prompt)
    }

    public func conversation(con: Conversation): PromptBuilder {
        this._conversation = con
        this
    }

    private func mergeSystemPrompt(): String {
        return String.join(
            this.systemMessages |> map { msg => msg.content } |> collectArray,
            delimiter: "\n\n"
        )
    }

    public func buildFor(executor: AgentExecutor): Array<Message> {
        let systemPrompt = this.mergeSystemPrompt()
        // Merge system prompt messageList message, and user messages
        let res = ArrayList<Message>()
        if (!systemPrompt.trimAscii().isEmpty()) {
            res.add(Message.system(systemPrompt))
        }
        // Add conversation messages in reverse order
        if (let Some(con) <- this._conversation) {
            for (i in (con.size - 1)..=0:-1) {
                let chatRound = con[i]
                res.add(chatRound.question)
                for (msg in chatRound.steps) {
                    res.add(msg)
                }
                if(executor.name == "react" || executor.name == "plan-react") {
                    res.add(Message.assistant(chatRound.answer.content.withTag(Tag.ANSWER)))
                } else {
                    res.add(Message.assistant(chatRound.answer.content))
                }
            }
        }
        return res.toArray()
    }

    //-------------------------------------------------------------------
    // Methods for building prompt parts
    //-------------------------------------------------------------------

    protected static func buildAgentToolsPrompt(task: AgentTask): String {
        let tools = task.availableTools
        if (tools.size == 0) {
            return "# Available Tools\nNo tools"
        }
        let str = String.join(
            tools |> map { t: Tool => t.toJsonValue().toJsonString() } |> collectArray,
            delimiter: ",\n"
        )
        return "# Available Tools\n[\n ${str} \n]\n---end of tools---"
    }

    protected static func buildAgentRetrievalPrompt(task: AgentTask): String {
        if (let Some(rt) <- task.agent.retriever) {
            if (rt.mode == RetrieverMode.Dynamic) {
                return ""
            }
            let query = task.request.question
            let retrieval = rt.search(query)
            task.execution.addRetrieval(query, retrieval)
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
}
