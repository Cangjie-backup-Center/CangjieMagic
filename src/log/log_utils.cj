/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.log

import magic.core.message.Message
import magic.core.message.MessageList
import magic.config.Config
import magic.utils.exists

import std.fs.{File, OpenMode, Directory, Path}
import std.console.Console
import std.collection.HashMap
import std.io.OutputStream

import stdx.log.LogLevel

@When[cjc_version < "1.0.0"]
import std.log.SimpleLogger

@When[cjc_version >= "1.0.0"]
import stdx.logger.SimpleLogger

@When[cjc_version < "1.0.0"]
private func buildSimpleLogger(output: OutputStream): SimpleLogger {
    let logger = SimpleLogger("logger", EnumLogLevel.INFO, output)
    logger.level = convertLogLevel(Config.logLevel)
    return logger
}
@When[cjc_version < "1.0.0"]
private func convertLogLevel(logLevel: LogLevel): EnumLogLevel {
    if (logLevel == LogLevel.OFF) {
        return EnumLogLevel.OFF
    } else if (logLevel == LogLevel.FATAL || logLevel == LogLevel.ERROR) {
        return EnumLogLevel.ERROR
    } else if (logLevel == LogLevel.WARN) {
        return EnumLogLevel.WARN
    } else if (logLevel == LogLevel.INFO) {
        return EnumLogLevel.INFO
    } else if (logLevel == LogLevel.DEBUG) {
        return EnumLogLevel.DEBUG
    } else if (logLevel == LogLevel.TRACE) {
        return EnumLogLevel.TRACE
    } else if (logLevel == LogLevel.ALL) {
        return EnumLogLevel.ALL
    }
    throw UnsupportedException()
}

@When[cjc_version >= "1.0.0"]
private func buildSimpleLogger(output: OutputStream): SimpleLogger {
    let logger = SimpleLogger(output)
    logger.level = Config.logLevel
    return logger
}

@When[ohos != "true"]
public struct LogUtils {
    private static var _LOGGER: Option<SimpleLogger> = None

    private static prop LOGGER: SimpleLogger {
        get() {
            match (_LOGGER) {
                case Some(logger) =>
                    return logger
                case None =>
                    let logger = if (Config.logFile == "stdout") {
                        buildSimpleLogger(Console.stdOut)
                    } else if (Config.logFile == "stderr") {
                        buildSimpleLogger(Console.stdErr)
                    } else {
                        let file = File(Config.logFile, OpenMode.Write)
                        buildSimpleLogger(file)
                    }
                    _LOGGER = logger
                    return logger
            }
        }
    }

    private static let NAMED_LOGGERS = HashMap<String, SimpleLogger>()

    private static func getNamedLogger(name: String): SimpleLogger {
        if (NAMED_LOGGERS.contains(name)) {
            return NAMED_LOGGERS[name]
        }
        if (!exists(Config.agentLogDir)) {
            Directory.create(Config.agentLogDir, recursive: true)
        }
        let path = Path(Config.agentLogDir).join("${name}.log")
        let file = File(path, OpenMode.Write)
        let logger = buildSimpleLogger(file)
        NAMED_LOGGERS[name] = logger
        return logger
    }

    public static func debug(msg: String): Unit {
        LOGGER.debug(msg)
    }

    public static func debug(name: String, msg: String): Unit {
        debug("${name}: ${msg}")
    }

    public static func info(msg: String): Unit {
        LOGGER.info(msg)
    }

    public static func info(name: String, msg: String): Unit {
        info("${name}: ${msg}")
        if (Config.enableAgentLog) {
            let logger = getNamedLogger(name)
            logger.info("${name}: ${msg}")
        }
    }

    public static func info(msg: Message): Unit {
        info("Chat Message[ ${msg.role} ]: ${msg.content}")
    }

    public static func info(name: String, msg: Message): Unit {
        info(name, "Chat Message[ ${msg.role} ]: ${msg.content}")
    }

    public static func info(history: MessageList): Unit {
        for (msg in history) {
            info(msg)
        }
    }

    public static func info(name: String, history: MessageList): Unit {
        for (msg in history) {
            info(name, msg)
        }
    }

    public static func info(messages: Array<Message>): Unit {
        for (msg in messages) {
            info(msg)
        }
    }

    public static func info(name: String, messages: Array<Message>): Unit {
        for (msg in messages) {
            info(name, msg)
        }
    }

    public static func error(msg: String): Unit {
        LOGGER.error(msg)
    }

    public static func error(name: String, msg: String): Unit {
        error("${name}: ${msg}")
        if (Config.enableAgentLog) {
            let logger = getNamedLogger(name)
            logger.error("${name}: ${msg}")
        }
    }
}
