/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.*
import magic.core.rag.RetrieverMode
import magic.log.LogUtils
import magic.config.Config
import magic.parser.WithTag
import magic.agent_executor.common.*

public class ReactExecutor <: AgentExecutor {
    public ReactExecutor(private let loop!: Int64 = Config.maxReactNumber) {}

    override public prop name: String {
        get() {"react"}
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        LogUtils.info("React executor runs ${agent.name}")
        let task = ReactTask(agent, request)
        for (_ in 0..this.loop) {
            if (let Some(resp) <- task.runOnce()) {
                return resp
            }
            if (let Some(stopInfo) <- task.stopInfo) {
                if (request.verbose) {
                    task.execution.verboseChannel.close()
                }
                LogUtils.info("Task stopped: ${stopInfo.reason}")
                return AgentResponse(stopInfo.result, execution: task.execution)
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
                    if (let Some(stopInfo) <- task.stopInfo) {
                        if (request.verbose) {
                            task.execution.verboseChannel.close()
                        }
                        LogUtils.info("Task stopped: ${stopInfo.reason}")
                        return AsyncAgentResponse([stopInfo.result].iterator(), execution: task.execution)
                    }
                }
                LogUtils.info("Exceed the max react loop")
                return task.asyncSummarize()
            } catch (e: Exception) {
                if (request.verbose) {
                    task.execution.verboseChannel.close()
                }
                throw e
            }
        }
        return AsyncAgentResponse(FutureIteratorWrapper(task, fut), execution: task.execution)
    }
}
