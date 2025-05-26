package magic.agent_executor.common

import magic.core.message.*
import magic.core.tokenizer.*
import magic.config.Config
import magic.tokenizer.TokenizerLoader
import std.collection.*
/**
 * A collection of chat messages
 */
protected class BoundedDialog <: Dialog {
    private let tokenizer: Tokenizer
    private let contextLen: Int64
    private var curLen: Int64 = 0
    private let lenOfPosition = ArrayList<Int64>()
    private var systemOffset: Int64 = -1

    public init(messages!: Array<ChatMessage> = [], contextLen!: ?Int64 = None, tokenizer!: ?Tokenizer = None) {
        super(messages)
        this.contextLen = if (let Some(cl) <- contextLen) {
            cl
        } else {
            Config.defaultContextLen
        }
        this.tokenizer = if (let Some(tk) <- tokenizer) {
            tk
        } else {
            TokenizerLoader.default()
        }
        let mws = ArrayList<ChatMessage>()
        for (i in 0..messages.size) {
            let msg = messages[i]
            let len = this.tokenizer.tokenCount(msg.content)
            curLen += len
            lenOfPosition.append(len)
        }
        if (messages.size > 0 && messages[0].role == System) {
            systemOffset = 0
        }
    }

    public func clone(): Dialog {
        return BoundedDialog(messages: this.messages.toArray().clone(), contextLen: contextLen, tokenizer: tokenizer)
    }

    public override func addMessage(msg: ChatMessage): Unit {
        let msgLen = this.tokenizer.tokenCount(msg.content)
        messages.append(msg)
        if (systemOffset == -1 && msg.role == System) {
            systemOffset = 0
        }
        curLen += msgLen
        lenOfPosition.append(msgLen)
        while (curLen > contextLen && messages.size > systemOffset + 1) {
            messages.remove(systemOffset + 1)
            curLen -= lenOfPosition.remove(systemOffset + 1)
        }
    }

    public override func addMessage(messages: Array<ChatMessage>): Unit {
        messages |> forEach {msg => addMessage(msg)}
    }

    public override func removeLast(): ChatMessage {
        let msg = super.removeLast()
        curLen -= lenOfPosition.remove(lenOfPosition.size - 1)
        msg
    }
}
