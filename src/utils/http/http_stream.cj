/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.StringExt

import std.collection.concurrent.BlockingQueue
import std.collection.{HashMap, ArrayList}
import stdx.encoding.json.JsonObject
import std.io.{InputStream, StringReader}
import magic.dsl.prompt

enum Item {
    | Bytes(Array<Byte>)
    | EOF
    | Error
}

/**
 * A http stream is an iterator of strings
 * Wrap of a blocking queue to support streaming.
 */
protected class HttpStream <: Iterator<String> & InputStream {
    let queue = BlockingQueue<Item>()
    let byteBuffer = ArrayList<Byte>()

    // Set when all data is consumed
    var finished = false

    private let closeFn: Option<() -> Unit>

    init(closeFn!: Option<() -> Unit> = None) {
        this.closeFn = closeFn
    }

    private func readBytes(): Bool {
        if (finished) {
            return false
        }
        match (queue.dequeue()) {
            case Error =>
                throw HttpException("Http byte stream error")
            case EOF =>
                finished = true
                LogUtils.debug("Http byte stream finished")
                return false
            case Bytes(bytes) =>
                this.byteBuffer.add(all: bytes)
                return true
        } 
    }

    override public func read(buffer: Array<Byte>): Int64 {
        if (this.byteBuffer.isEmpty() && !this.readBytes()) {
            return 0
        }
        let len = if (this.byteBuffer.size <= buffer.size) {
            this.byteBuffer.size
        } else {
            buffer.size
        }

        unsafe {
            let bytes = this.byteBuffer.getRawArray()
            bytes.copyTo(buffer, 0, 0, len)
        }

        if (this.byteBuffer.size == len) {
            this.byteBuffer.clear()
        } else {
            this.byteBuffer.remove(0..len)
        }
        return len
    }

    var _reader: Option<StringReader<HttpStream>> = None
    private prop reader: StringReader<HttpStream> {
        get() {
            if (let Some(r) <- this._reader) {
                return r
            } else {
                let r = StringReader(this)
                this._reader = r
                return r
            }
        }
    }

    override public func next(): Option<String> {
        let line = this.reader.readln()
        LogUtils.debug("Http byte stream read line: `${line}`")
        return line
    }

    public func put(data: Array<Byte>): Unit {
        // LogUtils.debug("put data: `${data}`")
        queue.enqueue(Item.Bytes(data))
    }

    public func markEOF(): Unit {
        queue.enqueue(Item.EOF)
    }

    public func markError(): Unit {
        queue.enqueue(Item.Error)
    }

    public func close(): Unit {
        this.markEOF()
        if (let Some(fn) <- this.closeFn) {
            fn()
        }
    }
}
