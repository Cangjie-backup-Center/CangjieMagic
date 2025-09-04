/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.interaction

import magic.core.interaction.*
import magic.core.agent.{Agent, AgentRequest, AgentResponse}
import magic.core.tool.{ToolRequest, ToolResponse}
import magic.core.model.{ChatRequest, ChatResponse}
import magic.core.agent.AgentExecution

import std.deriving.*

/**
 * Triggered when before tool call
 */
public class ToolCallStartEvent <: InteractionEvent { // Return: ToolResponse
    public ToolCallStartEvent(
        public let agent: Agent,
        public let toolRequest: ToolRequest // Details of the tool being invoked
    ) {
        super(EventKind.ToolCallStart)
    }
}

/**
 * Triggered when after tool call
 */
public class ToolCallEndEvent <: InteractionEvent { // Return: Unit
    public ToolCallEndEvent(
        public let agent: Agent,
        public let toolRequest: ToolRequest,  // Details of the tool being invoked
        public let toolResponse: ToolResponse // Result of calling the tool
    ) {
        super(EventKind.ToolCallEnd)
    }
}

/**
 * Triggered before an agent calling the chat model
 */
public class ChatModelStartEvent <: InteractionEvent { // Return: ChatResponse
    public ChatModelStartEvent(
        public let agent: Agent,
        public let chatRequest: ChatRequest
    ) {
        super(EventKind.ChatModelStart)
    }
}

/**
 * Triggered after an agent calling the chat model
 */
public class ChatModelEndEvent <: InteractionEvent { // Return: Unit
    public ChatModelEndEvent(
        public let agent: Agent,
        public let chatRequest: ChatRequest,
        public let chatResponse: ChatResponse
    ) {
        super(EventKind.ChatModelEnd)
    }
}

/**
 * Triggered when the LLM fails to generate a response.
 */
public class ChatModelFailureEvent <: InteractionEvent { // Return: ChatResponse
    public ChatModelFailureEvent(
        public let agent: Agent,
        public let chatRequest: ChatRequest, // The failing chat request
        public let error: String // Error message
    ) {
        super(EventKind.ChatModelFailure)
    }
}

/**
 * Triggered after execution to validate the agent’s final response.
 */
public class AgentStartEvent <: InteractionEvent { // Return: AgentResponse
    public AgentStartEvent(
        public let agent: Agent,
        public let agentRequest: AgentRequest
    ) {
        super(EventKind.AgentStart)
    }
}

/**
 * Triggered after execution to validate the agent’s final response.
 */
public class AgentEndEvent <: InteractionEvent { // Return: Unit
    public AgentEndEvent(
        public let agent: Agent,
        public let agentRequest: AgentRequest
        // Since sync and async agent requests result in different response type,
        // we do not use them
    ) {
        super(EventKind.AgentEnd)
    }
}

/**
 * Triggered when agent execution exceeds a time limit.
 */
public class AgentTimeoutEvent <: InteractionEvent { // Return: Unit
    public AgentTimeoutEvent(
        public let agent: Agent,
        public let execution: AgentExecution // The stalled execution context
    ) {
        super(EventKind.AgentTimeout)
    }
}

/**
 * Triggered when the agent requires additional human guidance.
 */
public class UserInputEvent <: InteractionEvent { // Return: String
    public UserInputEvent(
        public let agent: Agent,
        public let question: String // Clarification needed from a human
    ) {
        super(EventKind.UserInput)
    }
}

/**
 * Notify the agent execution
 */
public class NotifyEvent <: InteractionEvent { // Return: Unit
    public NotifyEvent(
        public let agent: Agent,
        public let tag: String, // The tag like [Info], [Action], etc.
        public let content: String // The tagged content
    ) {
        super(EventKind.Notify)
    }

    override public func toString(): String {
        return "${this.kind} ${this.tag} ${this.content}"
    }
}