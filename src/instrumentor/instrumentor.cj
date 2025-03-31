/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.instrumentor

import magic.core.agent.{Agent, AgentRequest, AgentResponse}
import magic.core.model.{ChatModel, ChatRequest, ChatResponse}
import magic.core.tool.{Tool, ToolRequest, ToolResponse}

public class Instrumentor {
    public static var BEFORE_CHAT_MODEL_FN: Option<(ChatModel, ChatRequest) -> Option<ChatResponse>> = None
    public static var BEFORE_CHAT_MODEL_FN2: Option<(String, ChatModel, ChatRequest) -> Option<ChatResponse>> = None

    public static func registerBeforeChatModel(fn: (ChatModel, ChatRequest) -> Option<ChatResponse>) {
        BEFORE_CHAT_MODEL_FN = fn
    }

    protected static func doInstrumentBeforeChatModel(model: ChatModel, request: ChatRequest, who!: Option<String> = None): Option<ChatResponse> {
        if (let Some(name) <- who) {
            return match (BEFORE_CHAT_MODEL_FN2) {
                case Some(fn) => fn(name, model, request)
                case None => None
            }
        } else {
            return match (BEFORE_CHAT_MODEL_FN) {
                case Some(fn) => fn(model, request)
                case None => None
            }
        }
    }

    public static func registerBeforeChatModel(fn: (String, ChatModel, ChatRequest) -> Option<ChatResponse>) {
        BEFORE_CHAT_MODEL_FN2 = fn
    }

    //---------------------------------------------------------------------------------------

    public static var BEFORE_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Option<AgentResponse>> = None

    public static func registerBeforeAgentRun(fn: (Agent, AgentRequest) -> Option<AgentResponse>) {
        BEFORE_AGENT_RUN_FN = fn
    }

    protected static func doInstrumentBeforeAgentRun(agent: Agent, request: AgentRequest): Option<AgentResponse> {
        return match (BEFORE_AGENT_RUN_FN) {
            case Some(fn) => fn(agent, request)
            case None => None
        }
    }

    public static var AFTER_AGENT_RUN_FN: Option<(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>> = None

    public static func registerAfterAgentRun(fn: (Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>) {
        AFTER_AGENT_RUN_FN = fn
    }

    protected static func doInstrumentAfterAgentRun(
        agent: Agent, request: AgentRequest, response: AgentResponse): AgentResponse {
        if (let Some(fn) <- AFTER_AGENT_RUN_FN) {
            if (let Some(newResp) <- fn(agent, request, response)) {
                return newResp
            }
        }
        return response
    }

    //---------------------------------------------------------------------------------------

    public static var BEFORE_TOOL_CALL_FN: Option<(Agent, ToolRequest) -> Option<ToolResponse>> = None

    public static func registerBeforeToolCall(fn: (Agent, ToolRequest) -> Option<ToolResponse>) {
        BEFORE_TOOL_CALL_FN = fn
    }

    protected static func doInstrumentBeforeToolCall(agent: Agent, request: ToolRequest): Option<ToolResponse> {
        if (let Some(fn) <- BEFORE_TOOL_CALL_FN) {
            return fn(agent, request)
        }
        return None
    }

    public static var AFTER_TOOL_CALL_FN: Option<(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>> = None

    public static func registerAfterToolCall(fn: (Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>) {
        AFTER_TOOL_CALL_FN = fn
    }

    protected static func doInstrumentAfterToolCall(
        agent: Agent, request: ToolRequest, response: ToolResponse): ToolResponse {
        if (let Some(fn) <- AFTER_TOOL_CALL_FN) {
            if (let Some(newResp) <- fn(agent, request, response)) {
                return newResp
            }
        }
        return response
    }
}