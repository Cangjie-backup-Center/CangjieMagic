/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.tool_loop

import magic.core.agent.*
import magic.core.message.{ChatMessage, Dialog}
import magic.core.model.{ChatRequest}
import magic.config.Config
import magic.agent_executor.react.{ReactPromptUtils, ToolCall, IteratorWrapper}
import magic.parser.OutputParserUtils
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.parser.{Tag, WithTag}
import magic.prompt.Template
import magic.tool.NativeFuncTool
import magic.utils.*

import encoding.json.*

private let STEP_PROMPT = """
Decide which tool to use next based on user needs and the current state of the execution.
The execution is a chronological event stream containing the following types of events:
    - A tool has been used, which is function call comprising the tool name and arguments
    - ${Tag.OBSERVATION} the result of the action ${Tag.OBSERVATION.getCloseTag()}
You can select ONLY ONE tool!

You MUST output a JSON object with the following schema:
```json
{
    "name": string, name of the tool, it must refer to one of available tools
    "arguments": { [key: string]: unknown }, arguments for the tool, each argument must be a valid json value required by the tool; it can be omitted, if the tool does not accept parameters
}
```
For example,
```json
{
    "name": "foo"
    "arguments": {
        "url": "http://example.com",
        "count": 3,
        "items": ["abc", "xyz"]
    }
}
```

All available tools are listed:
{tools}

Now, select a tool and output it with required format.
"""

private let ANSWER_PROMPT = """
Based on the above steps (including ${Tag.ACTION}s and ${Tag.OBSERVATION}s),
answer the question now.
"""

/*
 * This executor loops to select tools and execute it.
 * Different from the react executor, it does not produce thoughts.
 */
public class ToolLoopExecutor <: AgentExecutor {
    public ToolLoopExecutor(
        private let loop!: Int64 = Config.maxReactNumber
    ) { }

    private func buildStepSystemPrompt(task: AgentTask): String {
        return STEP_PROMPT.format([
            ("tools", ReactPromptUtils.buildAgentToolsPrompt(task))
        ])
    }

    private func answer(task: AgentTask): String {
        let dialog = task.execInfo.dialog
        LogUtils.debug(task.agent.name, ANSWER_PROMPT)
        dialog.addMessage(ChatMessage.system(ANSWER_PROMPT))
        let answer = ModelUtils.makeChat(task.agent.model, dialog).getOrThrow({ => AgentExecutionException("Fail to get chat model response") })
        dialog.removeLast()
        return answer.content
    }

    private func asyncAnswer(task: AgentTask): Iterator<String> {
        let dialog = task.execInfo.dialog
        LogUtils.debug(task.agent.name, ANSWER_PROMPT)
        dialog.addMessage(ChatMessage.system(ANSWER_PROMPT))
        let asyncChatResp = task.agent.model.asyncCreate(ChatRequest(dialog))
        return asyncChatResp.iter()
    }

    private func buildAgentTask(agent: Agent, request: AgentRequest): AgentTask {
        let task = AgentTask(agent, request)
        let dialog = task.execInfo.dialog
        dialog.addMessage([
            ChatMessage.system(agent.systemPrompt),
            ChatMessage.user(request.question)
        ])
        LogUtils.info(agent.name, dialog)
        return task
    }

    /**
     * Return whether the task completed
     */
    private func doRun(task: AgentTask): Bool {
        let agent = task.agent
        LogUtils.info("${agent.name} runs")
        // Inject a special tool
        let idleTool = NativeFuncTool(
            name: "_idle_",
            description: "A special tool to indicate you have completed all tasks and are about to enter idle state.",
            filterable: false
        )
        agent.toolManager.addTool(idleTool)

        let dialog = task.execInfo.dialog
        for (_ in 0..this.loop) {
            // Prepare input messages
            let stepPrompt = this.buildStepSystemPrompt(task)
            LogUtils.debug(agent.name, stepPrompt)
            dialog.addMessage(ChatMessage.system(stepPrompt))
            // Query the LLM
            let msg = ModelUtils.makeChat(agent.model, dialog, stop: [Tag.OBSERVATION])
                .getOrThrow({ => AgentExecutionException("Fail to get chat model response") })
            dialog.removeLast()
            // Parse the response
            if (let Some(_reason) <- msg.reason) {
                LogUtils.info(agent.name, "Reason: ${_reason}")
            }
            LogUtils.info(agent.name, "Content: ${msg.content}")
            // If the content does not contain ```json ... ```, treat the content as a json value
            let jsonStr = OutputParserUtils.extractFirstCode(msg.content, "json") ?? msg.content.trimAscii()
            let json = JsonValue.fromStr(jsonStr).asObject()
            // Parse the content
            let toolRequest = OutputParserUtils.parseToolRequest(jsonStr)
            LogUtils.info(agent.name, ChatMessage.assistant(jsonStr.withTag(Tag.ACTION)))
            if (task.request.verbose) {
                task.execInfo.verboseChannel.putAction(jsonStr)
            }

            // Execute the tool, and the idle tool is specialized
            if (toolRequest.name == idleTool.name) {
                agent.toolManager.delTool(idleTool)
                return true
            }
            let tc = ToolCall(thought: "", request: toolRequest, text: jsonStr)
            let observation = tc.invoke(task)
            LogUtils.info(agent.name, ChatMessage.assistant(observation.withTag(Tag.OBSERVATION)))
            if (task.request.verbose) {
                task.execInfo.verboseChannel.putObservation(observation)
            }
            // Add action and observation to the dialog, and the action message does not have a tag
            dialog.addMessage(ChatMessage.assistant("```json\n${jsonStr}\n```"))
            dialog.addMessage(ChatMessage.assistant(observation.withTag(Tag.OBSERVATION)))
        }
        agent.toolManager.delTool(idleTool)
        return false
    }

    override public func run(agent: Agent, request: AgentRequest): AgentResponse {
        let task = this.buildAgentTask(agent, request)
        let result = if (this.doRun(task)) {
            "✅ Task completed!"
        } else {
            LogUtils.info("Exceed the max loop")
            this.answer(task)
        }
        if (request.verbose) {
            task.execInfo.verboseChannel.put(result.withTag(Tag.ANSWER))
            task.execInfo.verboseChannel.close()
        }
        return AgentResponse(result, execInfo: task.execInfo)
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        let task = this.buildAgentTask(agent, request)
        let fut: Future<Iterator<String>> = spawn {
            try {
                let result = if (this.doRun(task)) {
                    ["✅ Task completed!"].iterator()
                } else {
                    this.asyncAnswer(task)
                }
                if (request.verbose) {
                    task.execInfo.verboseChannel.put("Task completed".withTag(Tag.ANSWER))
                }
                LogUtils.info("Exceed the max loop")
                return result
            } finally {
                if (request.verbose) {
                    task.execInfo.verboseChannel.close()
                }
            }
        }
        return AsyncAgentResponse(IteratorWrapper(agent, fut), execInfo: task.execInfo)
    }
}
