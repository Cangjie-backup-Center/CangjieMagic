package magic.agent_executor.common

import magic.core.tokenizer.*
import magic.core.message.*
import magic.log.LogUtils
import magic.utils.getEnv
import magic.tokenizer.{TokenizerLoader, TokenizerType}
import std.collection.{ArrayList, forEach, map, filter, collectArray}

public class PromptBuilder {
    var _system: ?ChatMessage = None
    var _tokenizer: ?Tokenizer = None
    let _contextLen: Int64
    let _userMsgs: ArrayList<ChatMessage> = ArrayList()
    let _historyMsgs: ArrayList<ChatMessage> = ArrayList()

    public init(contextLen: Int64, tokenizer!: ?Tokenizer = None) {
        this._contextLen = contextLen
        this._tokenizer = match (tokenizer) {
            case Some(tk) => tokenizer
            case None => TokenizerLoader.default()
        }
    }

    public func system(system: String): PromptBuilder {
        spliceSystemPrompt(system)
        this
    }

    public func retrieval(retrieval: String): PromptBuilder {
        spliceSystemPrompt(retrieval)
        this
    }

    public func tool(tool: String): PromptBuilder {
        spliceSystemPrompt(tool)
        this
    }

    public func memory(memory: String): PromptBuilder {
        spliceSystemPrompt(memory)
        this
    }

    private func spliceSystemPrompt(prompt: String): Unit {
        if (prompt.trimAscii().isEmpty()) {
            return
        }
        if (let Some(sys) <- this._system) {
            let sc = sys.content
            this._system = ChatMessage(System, String.join([sc, prompt], delimiter: "\n\n"))
        } else {
            this._system = ChatMessage(System, prompt)
        }
    }

    public func user(msgs: Array<String>): PromptBuilder {
        this._userMsgs.appendAll(msgs |> map({msg => ChatMessage(User, msg)}) |> collectArray)
        this
    }

    public func user(msgs: Array<ChatMessage>): PromptBuilder {
        this._userMsgs.appendAll(msgs.clone())
        this
    }

    public func history(msgs: Array<ChatMessage>): PromptBuilder {
        this._historyMsgs.appendAll(msgs.clone())
        this
    }

    public func history(dialog: ?Dialog): PromptBuilder {
        if (let Some(dia) <- dialog) {
            this._historyMsgs.appendAll(dia.clone() |> collectArray)
        }
        this
    }

    private func calLen(message: ?ChatMessage): Int64 {
        if (let Some(msg) <- message) {
            calLen(msg.content)
        } else {
            0
        }
    }

    private func calLen(message: String): Int64 {
        this._tokenizer.getOrThrow().tokenCount(message)
    }

    public func build(): Array<ChatMessage> {
        var curLen = calLen(this._system)
        var maxLen = this._contextLen
        for (userMsg in this._userMsgs) {
            curLen += calLen(userMsg)
        }
        let res = ArrayList<ChatMessage>()
        if (let Some(sys) <- this._system) {
            res.append(sys)
        } else {
            res.append(ChatMessage(System, ""))
        }
        let hisMsgInUse = ArrayList<ChatMessage>()
        let historyMsgs = this._historyMsgs.toArray()
        historyMsgs.reverse()
        for (msg in historyMsgs) {
            if (msg.role == System) {
                continue
            }
            let msgLen = calLen(msg)
            curLen += msgLen
            if (curLen > maxLen) {
                break
            }
            hisMsgInUse.append(msg)
        }
        let hmArray = hisMsgInUse.toArray()
        hmArray.reverse()
        res.appendAll(hmArray)
        this._userMsgs |> filter {msg => !msg.content.trimAscii().isEmpty()} |> forEach {userMsg => res.append(userMsg)}
        res.toArray()
    }
}
