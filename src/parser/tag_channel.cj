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
    }

    protected func putThought(msg: String): Unit {
        this.queue.enqueue(msg.withTag(Tag.THOUGHT))
        // Put an empty item to avoid the parser being blocked
        this.queue.enqueue("")
    }

    protected func putAction(msg: String): Unit {
        this.queue.enqueue(msg.withTag(Tag.ACTION))
        // Put an empty item to avoid the parser being blocked
        this.queue.enqueue("")
    }

    protected func putObservation(msg: String): Unit {
        let runes = msg.toRuneArray()
        let content = if (runes.size < 100) {
            msg.withTag(Tag.OBSERVATION)
        } else {
            "${String(runes[..100])}...".withTag(Tag.OBSERVATION)
        }
        this.queue.enqueue(content)
        // Put an empty item to avoid the parser being blocked
        this.queue.enqueue("")
    }

    protected func close(): Unit {
        this.queue.enqueue(EOF)
    }
}

