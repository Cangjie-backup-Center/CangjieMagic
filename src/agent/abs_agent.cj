/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.agent.*
import magic.core.message.Message
import magic.core.model.ChatModel
import magic.model.ModelUtils
import magic.config.Config
import magic.jsonable.Jsonable
import std.collection.{HashMap, map, collectArray}
import magic.instrumentor.Instrumentor
import magic.log.LogUtils
import magic.parser.{ParserUtils, ParserException}
import magic.prompt.Template

private let QUESTION_WITH_JSON_CONSTRAINT = """
The output must be a valid JSON value wrapped by ```json and ```.
For example,
```json 1 ```
```json "result" ```
```json [1, 2, 3] ```
```json ["abc", "opq", "xyz"] ```

The json value must obey the type schema:
"schema": {
  { schema }
}

Question: { question }
"""

//------------------------------------------------
// The agent type hierarchy:
// Interface Agent
//  |- AbsAgent
//      |- UserDefinedAgent
//          |- Agents defined by `@agent`
//      |- BaseAgent
//          |- Customized agents defined by APIs
//------------------------------------------------

public abstract class AbsAgent <: Agent {
    public func chat(question: String): String {
        return chat(AgentRequest(question)).content
    }

    public open override func chat(request: AgentRequest): AgentResponse {
        if (let Some(interceptor) <- this.interceptor) {
            if (interceptor.shouldIntercept(request)) {
                return interceptor.doIntercept(request)
            } else {
                interceptor.doBypass(request)
            }
        }
        var resp = if (let Some(r) <- Instrumentor.doInstrumentBeforeAgentRun(this, request)) {
            r
        } else {
            this.executor.run(this, request)
        }
        resp = Instrumentor.doInstrumentAfterAgentRun(this, request, resp)
        if (let Some(memory) <- this.memory) {
            memory.update(resp.execution.chatRound.toString()) // Update the agent memory
        }
        return resp
    }

    public func asyncChat(question: String): AsyncAgentResponse {
        return asyncChat(AgentRequest(question))
    }

    override open public func asyncChat(request: AgentRequest): AsyncAgentResponse {
        return this.executor.asyncRun(this, request)
    }

    public func chatGet<T>(question: String): Option<T> where T <: Jsonable<T> {
        return chatGet<T>(AgentRequest(question))
    }

    /**
     * Query the agent, get a response of required schema,
     * and convert the response content to the required type
     */
    public func chatGet<T>(request: AgentRequest): Option<T> where T <: Jsonable<T> {
        let schema = T.getTypeSchema()
        let fullQuestion = QUESTION_WITH_JSON_CONSTRAINT.format(
            ("schema", schema),
            ("question", request.question)
        )

        let resp = this.chat(AgentRequest(fullQuestion, conversation: request.conversation))
        // Reuse the message list
        var (answer, messageList) = (resp.content, resp.execution.messages)
        for (_ in 0..Config.outputRepairRetryNumber) {
            // Convert the answer to a value of type T
            try {
                return ParserUtils.extractLastValue<T>(answer)
            } catch(_: ParserException) {
                let userMsg = Message.user("Output does not obey the type schema.")
                LogUtils.info(this.name, userMsg)
                messageList.addMessage(userMsg)
                // Continue to let the model repair the output
                let msg = ModelUtils.makeChat(this.model, messageList).getOrThrow({ =>
                    AgentExecutionException("Fail to get chat model response")
                })
                LogUtils.info(this.name, msg)
                messageList.addMessage(msg)
                answer = msg.content
                resp.execution.setAnswer(answer)
            }
        }
        LogUtils.error("${this.name}: Fail to generate an output obeying the type schema")
        return None
    }
}
