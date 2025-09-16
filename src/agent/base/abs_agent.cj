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
    /**
     * Register uncaught exception handler to avoid ugly stack traces
     * Since this class will always be used as a base class,
     * we register the exception handler here.
    */
    static init() {
        Thread.handleUncaughtExceptionBy { thread: Thread, ex: Exception =>
            let strBuilder = StringBuilder()
            strBuilder.append("Uncaught exception in thread ${thread.name}: ${ex}")
            for (ste in ex.getStackTrace()) {
                strBuilder.append("${ste.fileName}:${ste.lineNumber} ${ste.methodName}\n")
            }
            LogUtils.error(strBuilder.toString())
        }
    }

    public func chat(question: String): String {
        let resp = chat(AgentRequest(question))
        if (resp.status == AgentResponseStatus.Cancelled) {
            throw AgentCancelException(reason: resp.content)
        }
        return resp.content
    }

    public open override func chat(request: AgentRequest): AgentResponse {
        // Process file imports
        let processedRequest = AgentOp.preprocessRequest(request)

        if (let Some(interceptor) <- this.interceptor) {
            if (interceptor.shouldIntercept(processedRequest)) {
                return interceptor.doIntercept(processedRequest)
            } else {
                interceptor.doBypass(processedRequest)
            }
        }
        try {
            let resp = this.executor.run(this, processedRequest)
            match (resp.status) {
                case AgentResponseStatus.Success =>
                    if (let Some(memory) <- this.memory) {
                        memory.update(resp.execution.chatRound.toString()) // Update the agent memory
                    }
                case AgentResponseStatus.Cancelled => ()
            }
            return resp
        } catch (ex: AgentCancelException) {
            LogUtils.info("Agent execution cancelled by user")
            return AgentResponse(AgentResponseStatus.Cancelled, ex.reason)
        }
    }

    public func asyncChat(question: String): AsyncAgentResponse {
        return asyncChat(AgentRequest(question))
    }

    override open public func asyncChat(request: AgentRequest): AsyncAgentResponse {
        // Process file imports
        let processedRequest = AgentOp.preprocessRequest(request)
        return this.executor.asyncRun(this, processedRequest)
    }

    public func chatGet<T>(question: String): Option<T> where T <: Jsonable<T> {
        return chatGet<T>(AgentRequest(question))
    }

    /**
     * Query the agent, get a response of required schema,
     * and convert the response content to the required type
     */
    public func chatGet<T>(request: AgentRequest): Option<T> where T <: Jsonable<T> {
        request.outputSchema = T.getTypeSchema()
        let resp = this.chat(request)
        // Reuse the message list
        var (answer, messageList) = (resp.content, resp.execution.messages)
        for (_ in 0..Config.outputRepairRetryNumber) {
            // Convert the answer to a value of type T
            try {
                return ParserUtils.extractFirstValue<T>(answer)
            } catch(_: ParserException) {
                let schema = T.getTypeSchema()
                let userMsg = Message.user("Output does not follow the type schema: ${schema}")
                LogUtils.info(this.name, userMsg)
                messageList.addMessage(userMsg)
                // Continue to let the model repair the output
                let msg = AgentOp.chatLLM(this, messageList, forRequest: request).getOrThrow({ =>
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
