package magic.agent_executor.common

import magic.core.agent.AgentExecutor
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
            this.systemMessages.append(Message.system(prompt))
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
            res.append(Message.system(systemPrompt))
        }
        // Add conversation messages in reverse order
        if (let Some(con) <- this._conversation) {
            for (i in (con.size - 1)..=0:-1) {
                let chatRound = con[i]
                res.append(Message.user(chatRound.question))
                for (msg in chatRound.steps) {
                    res.append(msg)
                }
                if(executor.name == "react" || executor.name == "plan-react") {
                    res.append(Message.assistant(chatRound.answer.withTag(Tag.ANSWER)))
                } else {
                    res.append(Message.assistant(chatRound.answer))
                }
            }
        }
        return res.toArray()
    }
}
