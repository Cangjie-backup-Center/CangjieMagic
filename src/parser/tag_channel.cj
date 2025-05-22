/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import std.collection.concurrent.BlockingQueue

/**
 * A simple channel to transfer tagged content between threads
 */
protected class TagChannel <: Iterator<String> {
    private static const EOF = "__TAG_CHANNEL_EOF__"
    private var finished = false

    private let queue = BlockingQueue<String>()

    public func next(): Option<String> {
        if (finished) {
            return None
        }
        let msg = this.queue.dequeue()
        if (msg == EOF) {
            finished = true
            return None
        } else {
            return msg
        }
    }

    protected func put(msg: String): Unit {
        this.queue.enqueue(msg)
        // Put an empty item to avoid the parser being blocked
        this.queue.enqueue("")
    }

    protected func put(msg: String, tag: String): Unit {
        this.put(msg.withTag(tag))
    }

    private func truncateMessage(msg: String): String {
        let runes = msg.toRuneArray()
        return if (runes.size < 100) {
            msg
        } else {
            "${String(runes[..100])}..."
        }
    }

    protected func close(): Unit {
        this.queue.enqueue(EOF)
    }
}

