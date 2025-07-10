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

    private func doRun(task: ReactTask): String {
        try {
            for (_ in 0..this.loop) {
                if (let Some(answer) <- task.runOnce()) {
                    return answer
                }
                if (let Some(stopInfo) <- task.stopInfo) {
                    LogUtils.info("Task stopped: ${stopInfo.reason}")
                    return stopInfo.result
                }
            }
            return task.summarize()
        } finally {
            if (task.request.verbose) {
                task.execution.verboseChannel.close()
            }
        }
        throw UnsupportedException("Unreachable")
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        LogUtils.info("React executor runs ${agent.name}")
        let task = ReactTask(agent, request)
        let answer = this.doRun(task)
        return AgentResponse(answer, execution: task.execution)
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        LogUtils.info("React executor async runs ${agent.name}")
        let task = ReactTask(agent, request)
        // Create a thread to execute the react task
        let fut: Future<Iterator<String>> = spawn {
            let answer = this.doRun(task)
            return [answer].iterator()
        }
        return AsyncAgentResponse(FutureIteratorWrapper(task, fut), execution: task.execution)
    }
}
