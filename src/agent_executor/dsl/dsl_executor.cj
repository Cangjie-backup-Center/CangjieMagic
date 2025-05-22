/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.agent.*
import magic.agent.UserDefinedAgent
import magic.agent_executor.common.{AgentTask, IteratorWrapper}
import magic.log.LogUtils

public class DslExecutor <: AgentExecutor {
    private func doRun(task: AgentTask): String {
        let ag = (task.agent as UserDefinedAgent).getOrThrow({ =>
            AgentExecutionException("Only agents defined by @agent can use the dsl executor")
        })
        let initState = ExecutionState(task)
        try {
            let object = ag.__CUSTOMIZED_EXECUTION_FUNC__(initState).getOrThrow({ =>
                throw AgentExecutionException("Agent failed to execute __CUSTOMIZED_EXECUTION_FUNC__")
            })
            let finalState = (object as ExecutionState).getOrThrow()
            if (!finalState.done) {
                throw AgentExecutionException("Agent has not solved the question")
            }
            return finalState.answer.getOrThrow()
        } finally {
            if (task.request.verbose) {
                task.execInfo.verboseChannel.close()
            }
        }
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        let task = AgentTask(agent, request, initPrompt: true)
        let answer = this.doRun(task)
        return AgentResponse(answer, execInfo: task.execInfo)
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let task = AgentTask(agent, request, initPrompt: true)
        let fut: Future<Iterator<String>> = spawn {
            let answer = this.doRun(task)
            return [answer].iterator()
        }
        return AsyncAgentResponse(IteratorWrapper(agent, fut), execInfo: task.execInfo)
    }
}
