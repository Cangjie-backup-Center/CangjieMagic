/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

protected struct SSEvent <: ToString {
    SSEvent(protected let event: String,
            protected let data: String) { }

    override public func toString(): String {
        return "event: ${event}\ndata: ${data}"
    }
}

protected class SSEventStream <: Iterator<SSEvent> {
    SSEventStream(private let httpStream: HttpStream) { }

    override public func next(): Option<SSEvent> {
        while (true) {
            // Receive the pair of event and data
            var event = ""
            var data = ""
            if (let Some(line) <- httpStream.next()) {
                if (line.trimAscii().isEmpty()) {
                    continue
                } else if (line.startsWith(": ping")) {
                    continue
                }
                event = line.removePrefix("event:").trimAscii()
            } else {
                LogUtils.debug("SSE stream finished")
                return None
            }
            if (let Some(line) <- httpStream.next()) {
                data = line.removePrefix("data:").trimAscii()
            } else {
                LogUtils.debug("SSE stream finished")
                return None
            }
            return SSEvent(event, data)
        }
        throw UnsupportedException("Unreachable")
    }

    public func close(): Unit {
        this.httpStream.close()
    }
}