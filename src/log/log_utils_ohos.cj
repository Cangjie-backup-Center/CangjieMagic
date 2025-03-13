/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.log

import magic.core.message.ChatMessage
import magic.core.message.Dialog
@When[ohos == "true"]
import ohos.base.AppLog

@When[ohos == "true"]
public struct LogUtils {
    public static func debug(msg: String): Unit {
        AppLog.info(msg) // AppLog.debug has no effects?
    }

    public static func info(msg: String): Unit {
        AppLog.info(msg)
    }

    public static func info(name: String, msg: String): Unit {
        info("${name}: ${msg}")
    }

    public static func info(msg: ChatMessage): Unit {
        info("Chat Message[ ${msg.role} ]: ${msg.content}")
    }

    public static func info(name: String, msg: ChatMessage): Unit {
        info(name, "Chat Message[ ${msg.role} ]: ${msg.content}")
    }

    public static func info(history: Dialog): Unit {
        for (msg in history) {
            info(msg)
        }
    }

    public static func info(name: String, history: Dialog): Unit {
        for (msg in history) {
            info(name, msg)
        }
    }

    public static func info(messages: Array<ChatMessage>): Unit {
        for (msg in messages) {
            info(msg)
        }
    }

    public static func info(name: String, messages: Array<ChatMessage>): Unit {
        for (msg in messages) {
            info(name, msg)
        }
    }

    public static func error(msg: String): Unit {
        AppLog.error(msg)
    }

    public static func error(name: String, msg: String): Unit {
        error("${name}: ${msg}")
    }
}
