/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.{ChatMessage, Dialog}

public class ChatRequest <: ToString {
    public let dialog: Dialog
    public let stop: Option<Array<String>>
    public let temperature: Option<Float64>

    public init(message: String) {
        this.dialog = Dialog([ChatMessage.user(message)])
        this.stop = None
        this.temperature = None
    }

    public init(
        messages: Array<ChatMessage>,
        temperature!: Option<Float64> = None,
        stop!: Option<Array<String>> = None
    ) {
        this.dialog = Dialog(messages)
        this.stop = stop
        this.temperature = temperature
    }

    public init(
        dialog: Dialog,
        temperature!: Option<Float64> = None,
        stop!: Option<Array<String>> = None
    ) {
        this.dialog = dialog
        this.stop = stop
        this.temperature = temperature
    }

    public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("""
ChatRequest: stop${stop.toString()}
""")
        for (msg in dialog) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}
