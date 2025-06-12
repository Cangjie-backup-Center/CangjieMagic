/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{Message, MessageList}

public class ChatRequest <: ToString {
    public let messageList: MessageList
    public let stop: Option<Array<String>>
    public let temperature: Option<Float64>

    public init(message: String) {
        this.messageList = MessageList([Message.user(message)])
        this.stop = None
        this.temperature = None
    }

    public init(
        messages: Array<Message>,
        temperature!: Option<Float64> = None,
        stop!: Option<Array<String>> = None
    ) {
        this.messageList = MessageList(messages)
        this.stop = stop
        this.temperature = temperature
    }

    public init(
        messageList: MessageList,
        temperature!: Option<Float64> = None,
        stop!: Option<Array<String>> = None
    ) {
        this.messageList = messageList
        this.stop = stop
        this.temperature = temperature
    }

    public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("""
ChatRequest: stop${stop.toString()}
""")
        for (msg in messageList) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}
