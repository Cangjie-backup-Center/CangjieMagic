/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.message.{ChatMessage, ChatMessageRole, Dialog}
import magic.core.model.{ChatModel, ChatRequest}
import magic.model.ModelUtils
import magic.log.LogUtils
import std.collection.ArrayList

func summarize(model: ChatModel, content: String): String {
    let question = "Summarize the following content in brief: ${content}"
    let dialog = Dialog([
        ChatMessage.user(question)
    ])
    let input = ChatRequest(dialog)
    if (let Some(msg) <- ModelUtils.makeChat(model, dialog)) {
        return msg.content
    } else {
        LogUtils.debug("Summarize failed")
        return "None"
    }
}