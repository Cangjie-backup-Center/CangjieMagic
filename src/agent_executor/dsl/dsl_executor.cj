/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.agent.*
import magic.agent.base.{AgentOp, UserDefinedAgent}
import magic.agent_executor.common.{AgentTask, FutureIteratorWrapper}
import magic.log.LogUtils
import magic.interaction.{AgentStartEvent, AgentEndEvent}

public class DslExecutor <: AgentExecutor {
    override public prop name: String {
        get() { "dsl" }
    }

    private func doRun(task: AgentTask): String {
        let ag = (task.agent as UserDefinedAgent).getOrThrow({ =>
            AgentExecutionException("Only agents defined by @agent can use the dsl executor")
        })
        let initState = ExecutionState(task)
        try {
            task.begin()
            let object = ag.__CUSTOMIZED_EXECUTION_FUNC__(initState).getOrThrow({ =>
                throw AgentExecutionException("Agent failed to execute __CUSTOMIZED_EXECUTION_FUNC__")
            })
            let finalState = (object as ExecutionState).getOrThrow()
            if (!finalState.done) {
                throw AgentExecutionException("Agent has not solved the question")
            }
            return finalState.answer
        } catch (ex: AgentCancelException) {
            LogUtils.info("Task cancelled by user")
            return ex.result
        } finally {
            task.end()
        }
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        let task = AgentTask(agent, request, initPrompt: true)
        let answer = this.doRun(task)
        return AgentResponse(answer, execution: task.execution)
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let task = AgentTask(agent, request, initPrompt: true)
        let fut: Future<Iterator<String>> = spawn {
            let answer = this.doRun(task)
            return [answer].iterator()
        }
        return AsyncAgentResponse(FutureIteratorWrapper(task, fut), execution: task.execution)
    }
}
