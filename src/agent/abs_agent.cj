/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.*
import magic.core.message.ChatMessage
import magic.core.model.ChatModel
import magic.jsonable.Jsonable
import std.collection.{HashMap, map, collectArray}
import magic.instrumentor.Instrumentor

//------------------------------------------------
// The agent type hierarchy:
// Interface Agent
//  |- AbsAgent
//      |- AgentProxy
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
            if (let Some(info) <- resp.execInfo) {
                memory.update(info.dialog.toString()) // Update the agent memory
            }
        }
        return resp
    }

    override open public func asyncChat(request: AgentRequest): AsyncAgentResponse {
        return this.executor.asyncRun(this, request)
    }
}
