/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.plan_react

import magic.core.agent.*
import magic.utils.*
import magic.agent_executor.common.FutureIteratorWrapper
import magic.parser.{Tag, WithTag}
import magic.log.LogUtils
import magic.core.message.{Message, MessageList}
import magic.core.model.ChatRequest
import magic.model.ModelUtils
import magic.prompt.Template

protected class PlanReactExecutor <: AgentExecutor {
    protected PlanReactExecutor() { }

    override public prop name: String {
        get() { "plan-react" }
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        // Extract necessary knowledge
        let knowledge = knowledgeExtract(agent, request)
        // Decompose the problem
        let subtasks: Array<Subtask> = problemDecompose(agent, request)
        let planTask = PlanTask(agent, request, subtasks, knowledge)
        planTask.execution.addRequest(request)
        // Solve each subtask
        for (subtask in subtasks) {
            let worker = ReactWorker(planTask)
            let result = worker.solve(subtask)
            subtask.result = result
        }
        // Summarize the result
        let result = resultSummarize(planTask)
        LogUtils.info(agent.name, "Summarized answer: ${result}")
        return AgentResponse(result, execution: planTask.execution)
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let planTask = PlanTask(agent, request)
        planTask.execution.addRequest(request)
        // Create the worker thread
        let fut: Future<Iterator<String>> = spawn {
            try {
                return workFn(planTask)
            } catch(ex: Exception) {
                planTask.execution.verboseChannel.close()
                throw ex
            }
            throw UnsupportedException("Unreachable")
        }
        return AsyncAgentResponse(FutureIteratorWrapper(planTask, fut), execution: planTask.execution)
    }
}

private func workFn(planTask: PlanTask): Iterator<String> {
    let agent = planTask.agent
    let request = planTask.request
    // Extract necessary knowledge
    planTask.knowledge = knowledgeExtract(agent, request)
    // Decompose the problem
    let subtasks: Array<Subtask> = problemDecompose(agent, request)
    planTask.subtasks = subtasks
    if (request.verbose) {
        let strBuilder = StringBuilder()
        strBuilder.append("# The Plan\n")
        for (subtask in subtasks) {
            strBuilder.append(subtask.toMarkdown())
            strBuilder.append("\n")
        }
        planTask.execution.verboseChannel.put(strBuilder.toString().withTag(Tag.PLAN))
    }
    // Solve each subtask
    for (subtask in subtasks) {
        if (request.verbose) {
            planTask.execution.verboseChannel.put("Solve the subtask: ${subtask.name}".withTag(Tag.PLAN))
        }
        let worker = ReactWorker(planTask)
        let asyncResp = worker.asyncSolve(subtask, verbose: request.verbose)
        if (request.verbose) {
            // Transfer the internal information from the react worker to this agent
            for (data in asyncResp.execution.verboseInfo) {
                planTask.execution.verboseChannel.put(data)
            }
        }
        subtask.result = asyncResp.content
        if (request.verbose) {
            planTask.execution.verboseChannel.put("# Subtask DONE!\n${subtask.toMarkdown()}".withTag(Tag.INFO))
        }
    }
    if (request.verbose) {
        planTask.execution.verboseChannel.close()
    }
    // Summarize the result
    return asyncResultSummarize(planTask)
}