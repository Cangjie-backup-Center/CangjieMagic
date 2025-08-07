/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent.base

import magic.core.agent.*
import magic.core.message.Message
import magic.config.Config
import magic.model.ModelUtils
import magic.jsonable.Jsonable
import magic.log.LogUtils
import magic.parser.{ParserUtils, ParserException}

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
        let resp = this.executor.run(this, request)
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
        request.extra.add(AgentRequestExtra.OUTPUT_SCHEMA, T.getTypeSchema())
        let resp = this.chat(request)
        // Reuse the message list
        var (answer, messageList) = (resp.content, resp.execution.messages)
        for (_ in 0..Config.outputRepairRetryNumber) {
            // Convert the answer to a value of type T
            try {
                return ParserUtils.extractLastValue<T>(answer)
            } catch(_: ParserException) {
                let schema = T.getTypeSchema()
                let userMsg = Message.user("Output does not follow the type schema: ${schema}")
                LogUtils.info(this.name, userMsg)
                messageList.addMessage(userMsg)
                // Continue to let the model repair the output
                let msg = ModelUtils.agentMakeChat(this, messageList).getOrThrow({ =>
                    AgentExecutionException("Fail to get chat model response")
                }).message
                LogUtils.info(this.name, msg)
                messageList.addMessage(msg)
                answer = msg.content
                resp.execution.setAnswer(answer)
            }
        }
        LogUtils.error("${this.name}: Fail to generate an output following the type schema")
        return None
    }
}
