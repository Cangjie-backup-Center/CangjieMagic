/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Message
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
    private var _execution: Option<AgentExecution> = None

    public prop execution: AgentExecution {
        get() { this._execution.getOrThrow() }
    }

    public init(chunks: Iterator<String>) {
        this.chunks = chunks
    }

    public init(chunks: Iterator<String>, execution!: AgentExecution) {
        this.chunks = chunks
        this._execution = execution
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
            if (let Some(execution) <- this._execution) {
                execution.setAnswer(buffer.toString())
            }
            return None
        }
    }
}
