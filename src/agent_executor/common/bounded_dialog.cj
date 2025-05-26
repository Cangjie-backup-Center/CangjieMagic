package magic.agent_executor.common

import magic.core.message.*
import magic.core.tokenizer.*
import magic.config.Config
import magic.tokenizer.TokenizerLoader
import std.collection.*

/**
 * A dialog that limits the total length of messages to a specified context length.
 */
protected class BoundedDialog <: Dialog {
    private let tokenizer: Tokenizer
    private let contextLength: Int64
    private var currTotalLength: Int64 = 0
    // Length of each message in the dialog, used to calculate the total size
    private let messageLengthMap = ArrayList<Int64>()
    // Record the position of the system message, if exists
    private var posOfSystemMessage: Int64 = -1

    public init(contextLength!: Option<Int64> = None) {
        this(messages: [], contextLength: contextLength ?? Config.defaultContextLen, tokenizer: TokenizerLoader.default())
    }

    init(messages!: Array<ChatMessage>, contextLength!: Int64, tokenizer!: Tokenizer) {
        super(messages)
        this.contextLength = contextLength
        this.tokenizer = tokenizer
        for (msg in messages) {
            let len = this.tokenizer.countToken(msg.content)
            this.currTotalLength += len
            messageLengthMap.append(len)
        }
        if (!messages.isEmpty() && messages[0].role == ChatMessageRole.System) {
            posOfSystemMessage = 0
        }
    }

    public func clone(): Dialog {
        return BoundedDialog(messages: this.messages.toArray().clone(), contextLength: contextLength, tokenizer: tokenizer)
    }

    public override func addMessage(msg: ChatMessage): Unit {
        let msgLen = this.tokenizer.countToken(msg.content)
        messages.append(msg)
        if (posOfSystemMessage == -1 && msg.role == ChatMessageRole.System) {
            posOfSystemMessage = 0
        }
        this.currTotalLength += msgLen
        this.messageLengthMap.append(msgLen)
        // If the total length exceeds the context length, remove messages
        if (this.currTotalLength > this.contextLength) {
            this.removeExcessMessages()
        }
    }

    /**
     * Remove excess messages from the dialog to keep the total length within the context length.
     * It will remove the oldest message after the system message iteratively, if exists
     * This is a heuristic that dialog messages are after the system message.
     */
    private func removeExcessMessages(): Unit {
        while (this.currTotalLength > this.contextLength &&
               messages.size > posOfSystemMessage + 1) {
            this.messages.remove(posOfSystemMessage + 1)
            this.currTotalLength -= messageLengthMap.remove(posOfSystemMessage + 1)
        }
    }

    public override func addMessage(messages: Array<ChatMessage>): Unit {
        messages |> forEach { msg => this.addMessage(msg) }
    }

    public override func removeLast(): ChatMessage {
        let msg = super.removeLast()
        this.currTotalLength -= messageLengthMap.remove(messageLengthMap.size - 1)
        msg
    }
}
