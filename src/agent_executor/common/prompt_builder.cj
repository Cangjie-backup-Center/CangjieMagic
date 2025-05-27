package magic.agent_executor.common

import magic.core.agent.{AgentExecutionException}
import magic.core.tokenizer.{Tokenizer}
import magic.core.message.{ChatMessage, ChatMessageRole, Dialog}
import magic.tokenizer.{TokenizerLoader, TokenizerType}
import magic.log.LogUtils

import std.collection.{ArrayList, forEach, map, filter, collectArray}

/**
 * A builder for constructing prompts.
 * This class is used to build the initial prompts for the agent executor.
 * It usually builds
 *   - the system prompt (comprising system, retrieval, tool, and memory prompts),
 *   - the dialogs (conversation history between the agent and user), 
 *   - and the user prompts (user's questions).
 */
protected class PromptBuilder {
    private let systemMessages = ArrayList<ChatMessage>()
    private let dialogMessages = ArrayList<ChatMessage>()
    private let userMessages = ArrayList<ChatMessage>()

    public func system(prompt: String): PromptBuilder {
        if (!prompt.trimAscii().isEmpty()) {
            this.systemMessages.append(ChatMessage.system(prompt))
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

    public func user(prompts: Array<String>): PromptBuilder {
        for (prompt in prompts) {
            if (!prompt.trimAscii().isEmpty()) {
                this.userMessages.append(ChatMessage.user(prompt))
            }
        }
        this
    }

    public func user(promptMessages: Array<ChatMessage>): PromptBuilder {
        for (msg in promptMessages) {
            if (!msg.content.trimAscii().isEmpty()) {
                this.userMessages.append(msg)
            }
        }
        this
    }

    public func dialog(msgs: Array<ChatMessage>): PromptBuilder {
        // Filter out system messages from dialog
        this.dialogMessages.appendAll(
            msgs |> filter { msg => msg.role != ChatMessageRole.System } |> collectArray
        )
        this
    }

    public func dialog(dialog: Dialog): PromptBuilder {
        this.dialog(dialog.toArray())
    }

    private func mergeSystemPrompt(): String {
        return String.join(
            this.systemMessages |> map { msg => msg.content } |> collectArray,
            delimiter: "\n\n"
        )
    }

    public func build(): Array<ChatMessage> {
        let systemPrompt = this.mergeSystemPrompt()
        // Merge system prompt dialog message, and user messages
        let res = ArrayList<ChatMessage>()
        if (!systemPrompt.trimAscii().isEmpty()) {
            res.append(ChatMessage.system(systemPrompt))
        }
        // Add dialog messages in reverse order
        for (i in (this.dialogMessages.size - 1)..=0:-1) {
            let msg = this.dialogMessages[i]
            res.append(msg)
        }
        // Add user messages
        res.appendAll(this.userMessages)
        return res.toArray()
    }
}
