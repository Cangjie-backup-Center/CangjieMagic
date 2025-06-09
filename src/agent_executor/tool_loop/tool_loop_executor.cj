/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.tool_loop

import magic.core.agent.*
import magic.core.message.{Message, MessageList}
import magic.core.model.{ChatRequest}
import magic.config.Config
import magic.agent_executor.common.{AgentTask, FutureIteratorWrapper}
import magic.agent_executor.dsl.{ExecutionOpSet, ExecutionState}
import magic.parser.OutputParserUtils
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.parser.{Tag, WithTag}
import magic.prompt.Template
import magic.tool.NativeFuncTool
import magic.utils.*

/*
 * This executor loops to select tools and execute it.
 * Different from the react executor, it does not produce thoughts.
 */
public class ToolLoopExecutor <: AgentExecutor {
    public ToolLoopExecutor(
        private let loop!: Int64 = Config.maxReactNumber
    ) { }

     override public prop name: String {
        get() {"tool-loop"}
    }

    private func doRun(task: AgentTask): String {
        LogUtils.info("${task.agent.name} runs")
        var state = ExecutionState(task)
        try {
            for (_ in 0..this.loop) {
                state = ExecutionOpSet.action(state)
                if (state.done) {
                    return state.answer
                }
                if (let Some(stopInfo) <- state.task.stopInfo) {
                    LogUtils.info("Task stopped: ${stopInfo.reason}")
                    return stopInfo.result
                }
            }
            LogUtils.info("Exceed the max loop")
            state = ExecutionOpSet.answer(state)
            return state.answer
        } finally {
            if (task.request.verbose) {
                task.execution.verboseChannel.close()
            }
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
