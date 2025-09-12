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
     * The status of the response
     */
    private var _status: Option<AgentResponseStatus> = None

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
     * The final result
     * This is a synchronous method, which will wait until the executor completes
     */
    public prop content: String {
        get() {
            if (!this.finished) {
                this.waitUntilFinished()
            }
            return buffer.toString()
        }
    }

    /**
     * The status of the response
     * This is a synchronous method, which will wait until the executor completes
     */
    public prop status: AgentResponseStatus {
        get() {
            if (!this.finished) {
                this.waitUntilFinished()
            }
            return this._status.getOrThrow()
        }
    }

    /**
     * Wait until the response is finished
     */
    private func waitUntilFinished() {
        if (!this.finished) {
            // Consume all chunks
            for (_ in this) { }
        }
    }

    override public func next(): Option<String> {
        if (this.finished) {
            return None
        }

        try {
            match (this.chunks.next()) { // The exception will be thrown here if any
                case Some(data) =>
                    buffer.append(data)
                    return data
                case None =>
                    let answer = buffer.toString()
                    if (let Some(execution) <- this._execution) {
                        execution.setAnswer(answer)
                    }
                    this._status = AgentResponseStatus.Success
                    this.finished = true
                    return None
            }
        } catch (ex: AgentCancelException) {
            LogUtils.info("Task cancelled by user")
            // Clear the result buffer
            this.buffer.reset()
            // Set the status to canceled
            this._status = AgentResponseStatus.Cancelled
            this.buffer.append(ex.reason)
            this.finished = true
            return None
        }
    }

    /**
     * Cancelled the agent execution
     * Wait until the execution is stopped.
     */
    public func cancel(): Unit {
        this.execution.markCancellation()
        // Consume all chunks
        for (_ in this) { }
    }
}
