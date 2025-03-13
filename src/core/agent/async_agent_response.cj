/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.ChatMessage

/**
 * The asynchronous execution response from an agent executor
 */
public class AsyncAgentResponse <: Iterator<String> {
    private let chunks: Iterator<String>

    private let _content = StringBuilder()

    /**
     * Internal information during the execution
     */
    public let execInfo: Option<AgentExecutionInfo>

    public init(chunks: Iterator<String>) {
        this.chunks = chunks
        this.execInfo = None
    }

    public init(chunks: Iterator<String>, execInfo!: AgentExecutionInfo) {
        this.chunks = chunks
        this.execInfo = execInfo
    }

    /**
     * The execution result
     * This is a synchronous method, which will wait until the executor completes
     */
    public prop content: String {
        get() {
            // Consume all chunks
            for (_ in this) { }
            _content.toString()
        }
    }

    override public func next(): Option<String> {
        if (let Some(chunk) <- this.chunks.next()) {
            _content.append(chunk)
            return chunk
        } else {
            if (let Some(info) <- this.execInfo) {
                info.dialog.addMessage(ChatMessage.assistant(_content.toString()))
            }
            return None
        }
    }
}
