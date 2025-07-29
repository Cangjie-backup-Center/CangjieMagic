/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{Message, MessageList}
public struct ChatResponse <: ToString {
    public let model: String
    public let messageList: MessageList
    public let usage: Option<ChatUsage>

    public init(model: String, messageList: MessageList, usage!: Option<ChatUsage> = None) {
        this.messageList = messageList
        this.model = model
        this.usage = usage
    }

    public init(model: String, message: Message, usage!: Option<ChatUsage> = None) {
        this.messageList = MessageList([message])
        this.model = model
        this.usage = usage
    }

    public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("ChatResponse:\n  model[${model}]\n  usage[${usage.toString()}]\n")
        for (msg in messageList) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}
