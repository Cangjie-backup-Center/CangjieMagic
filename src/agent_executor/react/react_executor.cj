/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.*
import magic.core.rag.RetrieverMode
import magic.log.LogUtils
import magic.config.Config
import magic.parser.WithTag

public class ReactExecutor <: AgentExecutor {
    public ReactExecutor(
        private let loop!: Int64 = Config.maxReactNumber
    ) { }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        LogUtils.info("React executor runs ${agent.name}")
        let task = ReactTask(agent, request)
        for (_ in 0..this.loop) {
            if (let Some(resp) <- task.runOnce()) {
                return resp
            }
        }
        LogUtils.info("Exceed the max react loop")
        return task.summarize()
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        LogUtils.info("React executor async runs ${agent.name}")
        let task = ReactTask(agent, request)
        // Create a thread to execute the react task
        let fut: Future<Iterator<String>> = spawn {
            try {
                for (_ in 0..this.loop) {
                    if (let Some(asyncAnswer) <- task.asyncRunOnce()) {
                        return asyncAnswer
                    }
                }
                LogUtils.info("Exceed the max react loop")
                return task.asyncSummarize()
            } catch (e: Exception) {
                if (request.verbose) {
                    task.execInfo.verboseChannel.close()
                }
                throw e
            }
        }
        return AsyncAgentResponse(IteratorWrapper(task, fut), execInfo: task.execInfo)
    }
}

protected class IteratorWrapper <: Iterator<String> {
    protected IteratorWrapper(
        private let task: AgentTask,
        private let workerFut: Future<Iterator<String>>
    ) { }

    /**
     * Concatenate all response content and log it finally
     */
    private let buffer = StringBuilder()

    override public func next(): Option<String> {
        let asyncAnswer = workerFut.get()
        let data = asyncAnswer.next()
        match (data) {
            case Some(v) => buffer.append(v)
            case None =>
                LogUtils.info(this.task.agent.name, buffer.toString().withTag(Tag.ANSWER))
        }
        return data
    }
}