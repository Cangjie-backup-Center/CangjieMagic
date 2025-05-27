package magic.agent_executor.common

import magic.core.message.*
import magic.core.tokenizer.*
import magic.config.Config
import magic.tokenizer.TokenizerLoader
import magic.log.LogUtils

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
    private var posOfSystemMessage: Option<Int64> = None

    public init(contextLength!: Option<Int64> = None) {
        this.contextLength = contextLength ?? Config.defaultContextLen
        this.tokenizer = TokenizerLoader.default()
    }

    public override func addMessage(msg: ChatMessage): Unit {
        if (posOfSystemMessage.isNone() && msg.role == ChatMessageRole.System) {
            if (!this.isEmpty()) {
                LogUtils.error("System message should be the first message in the dialog.")
            }
            posOfSystemMessage = Some(this.messages.size)
        }
        this.messages.append(msg)
        let msgLen = this.tokenizer.countToken(msg.content)
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
        let posToRemove = (this.posOfSystemMessage ?? -1) + 1
        while (this.currTotalLength > this.contextLength &&
               messages.size > posToRemove) {
            this.messages.remove(posToRemove)
            this.currTotalLength -= messageLengthMap.remove(posToRemove)
        }
    }

    public override func removeLast(): ChatMessage {
        let msg = super.removeLast()
        this.currTotalLength -= messageLengthMap.remove(messageLengthMap.size - 1)
        msg
    }
}
