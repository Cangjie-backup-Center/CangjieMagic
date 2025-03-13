/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.*
import magic.core.rag.RetrieverMode
import magic.log.LogUtils
import magic.config.Config

public class ReactExecutor <: AgentExecutor {
    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        LogUtils.info("React executor runs ${agent.name}")
        let task = ReactTask(agent, request)
        for (_ in 0..Config.maxReactNumber) {
            if (let Some(resp) <- task.runOnce()) {
                return resp
            }
        }
        throw AgentExecutionException("Exceed the max react loop")
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        LogUtils.info("React executor async runs ${agent.name}")
        let task = ReactTask(agent, request)
        // Create a thread to execute the react task
        let fut: Future<Iterator<String>> = spawn {
            for (_ in 0..Config.maxReactNumber) {
                if (let Some(asyncAnswer) <- task.asyncRunOnce()) {
                    return asyncAnswer
                }
            }
            throw AgentExecutionException("Exceed the max react loop")
        }
        return AsyncAgentResponse(IteratorWrapper(task, fut), execInfo: task.execInfo)
    }
}

private class IteratorWrapper <: Iterator<String> {
    IteratorWrapper(
        private let task: ReactTask,
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
                LogUtils.info(this.task.agent.name, buffer.toString().withTag(ANSWER_TAG))
        }
        return data
    }
}