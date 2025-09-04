/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Message
import magic.parser.{Tag, WithTag}
import magic.log.LogUtils

/**
 * The asynchronous execution response from an agent executor
 */
public class AsyncAgentResponse <: Iterator<String> {
    /**
     * Data chunks of the final result
     */
    private let chunks: Iterator<String>

    /**
     * Merge all chunk content
     */
    private let buffer = StringBuilder()

    /**
     * Whether the execution is finished
     * If not finished, the content is still being generated
     * If finished, the content is complete
     */
    private var finished = false

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
            if (this.finished) {
                return buffer.toString()
            } else {
                // Consume all chunks
                for (_ in this) { }
                return buffer.toString()
            }
        }
    }

    override public func next(): Option<String> {
        if (this.finished) {
            return None
        }
        if (let Some(chunk) <- this.chunks.next()) {
            buffer.append(chunk)
            return chunk
        } else {
            if (let Some(execution) <- this._execution) {
                execution.setAnswer(buffer.toString())
            }
            this.finished = true
            return None
        }
    }

    /**
     * Cancel the agent execution
     * Wait until the execution is stopped.
     */
    public func cancel(): Unit {
        this.execution.markCancellation()
        // Consume all chunks
        for (_ in this) { }
    }
}
