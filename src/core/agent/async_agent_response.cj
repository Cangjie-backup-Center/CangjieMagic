/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.ChatMessage
import magic.parser.{Tag, WithTag}
/**
 * The asynchronous execution response from an agent executor
 */
public class AsyncAgentResponse <: Iterator<String> {
    private let chunks: Iterator<String>

    /**
     * Merge all chunk content
     */
    private let buffer = StringBuilder()

    /**
     * Internal information during the execution
     */
    public let execInfo: Option<AgentExecutionInfo>

    public init(chunks: Iterator<String>) {
        this.chunks = chunks
        this.execInfo = None
    }

    public init(chunks: Iterator<String>, execInfo!: Option<AgentExecutionInfo>) {
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
            buffer.toString()
        }
    }

    override public func next(): Option<String> {
        if (let Some(chunk) <- this.chunks.next()) {
            buffer.append(chunk)
            return chunk
        } else {
            if (let Some(info) <- this.execInfo) {
                if(info.executor.name == "react" || info.executor.name == "plan-react") {
                    info.dialog.addMessage(ChatMessage.assistant("${Tag.ANSWER}${buffer.toString()}${Tag.ANSWER.getCloseTag()}"))
                } else {
                    info.dialog.addMessage(ChatMessage.assistant(buffer.toString()))
                }
                
            }
            return None
        }
    }
}
