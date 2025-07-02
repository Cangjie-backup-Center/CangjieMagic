/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

import std.collection.ArrayList
import stdx.encoding.json.{JsonValue, JsonException}

protected struct SSEvent <: ToString {
    SSEvent(protected let event: String,
            protected let data: String) { }

    override public func toString(): String {
        return "event: ${event}\ndata: ${data}"
    }
}

protected class SSEventStream <: Iterator<SSEvent> {
    SSEventStream(private let httpStream: HttpStream) { }

    private func readEvent(): Option<String> {
        while (true) {
            // Receive the pair of event and data
            if (let Some(line) <- this.httpStream.next()) {
                if (line.trimAscii().isEmpty() || line.startsWith(": ping")) {
                    continue
                }
                if (!line.startsWith("event:")) {
                    throw HttpException("Invalid sse event: `${line}`")
                }
                return line.removePrefix("event:").trimAscii()
            } else {
                LogUtils.debug("SSE stream finished")
                return None
            }
        }
        throw UnsupportedException("Unreachable")
    }

    private func readData(): Option<String> {
        while (true) {
            if (let Some(line) <- this.httpStream.next()) {
                if (line.trimAscii().isEmpty() || line.startsWith(": ping")) {
                    continue
                }
                if (!line.startsWith("data:")) {
                    throw HttpException("Invalid sse data: `${line}`")
                }
                return line.removePrefix("data:").trimAscii()
            } else {
                LogUtils.debug("SSE stream finished")
                return None
            }
        }
        throw UnsupportedException("Unreachable")
    }

    override public func next(): Option<SSEvent> {
        while (true) {
            // Receive the pair of event and data
            let event = if (let Some(_event) <- this.readEvent()) {
                _event
            } else {
                return None
            }
            LogUtils.debug("SSE stream read event: ${event}")
            let data = if (let Some(_data) <- this.readData()) {
                _data
            } else {
                return None
            }
            LogUtils.debug("SSE stream read data: ${data}")
            return SSEvent(event, data)
        }
        throw UnsupportedException("Unreachable")
    }

    public func close(): Unit {
        this.httpStream.close()
    }
}