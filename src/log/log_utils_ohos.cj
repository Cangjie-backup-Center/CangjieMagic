/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.log

import magic.core.message.ChatMessage
import magic.core.message.Dialog
@When[ohos == "true"]
import ohos.base.AppLog

import std.collection.ArrayList

@When[ohos == "true"]
public struct LogUtils {
    /**
     * AppLog.info will truncate a log message, so we split it as multiple messages
     */
    private static func splitMessages(msg: String): Array<String> {
        let result = ArrayList<String>()
        let runes = msg.toRuneArray()
        var start = 0
        let SIZE = 1500
        while (true) {
            if (start + SIZE <= runes.size) {
                result.append(String(runes[start..(start + SIZE)]))
                start += SIZE
            } else {
                result.append(String(runes[start..]))
                break
            }
        }
        return result.toArray()
    }

    public static func debug(msg: String): Unit {
        for (line in splitMessages(msg)) {
            info(line)  // AppLog.debug has no effects?
        }
    }

    public static func debug(name: String, msg: String): Unit {
        debug("${name}: ${msg}")
    }

    public static func debug(ex: Exception): Unit {
        for (ste in ex.getStackTrace()) {
            AppLog.info("${ste.fileName}:${ste.lineNumber} ${ste.methodName}")
        }
    }


    public static func info(msg: String): Unit {
        for (line in splitMessages(msg)) {
            AppLog.info(line)
        }
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
        AppLog.info(msg)
    }

    public static func error(name: String, msg: String): Unit {
        error("${name}: ${msg}")
    }
}
