/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

import magic.core.message.Dialog

public struct ChatResponse <: ToString {
    public let model: String
    public let dialog: Dialog
    public let usage: Option<ChatUsage>

    public init(dialog: Dialog, model: String, usage!: Option<ChatUsage> = None) {
        this.dialog = dialog
        this.model = model
        this.usage = usage
    }

    public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("ChatResponse: model[${model}] usage[${usage.toString()}]")
        for (msg in dialog) {
            strBuilder.append("  ")
            strBuilder.append(msg.toString())
            strBuilder.append("\n")
        }
        strBuilder.toString()
    }
}
