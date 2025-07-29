/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.interaction

import magic.core.agent.Agent
import magic.core.interaction.{InteractionEvent, EventKind}
import magic.core.tool.ToolRequest
import magic.core.model.ChatRequest
import magic.core.agent.AgentExecution

import std.deriving.*

/**
 * Triggered when a tool call requires human approval.
 */
public class ToolCallEvent <: InteractionEvent { // Return: ToolResponse
    public ToolCallEvent(
        public let agent: Agent,
        public let toolRequest: ToolRequest // Details of the tool being invoked
    ) {
        super(EventKind.ToolCall)
    }
}

/**
 * Triggered before execution to validate the agent’s system prompt.
 */
public class PromptValidateEvent <: InteractionEvent { // Return: Bool
    public PromptValidateEvent(
        public let agent: Agent,
        public let prompt: String // The initial LLM system prompt
    ) {
        super(EventKind.PromptValidate)
    }
}

/**
 * Triggered after execution to validate the agent’s final response.
 */
public class AnswerValidateEvent <: InteractionEvent { // Return: Bool
    public AnswerValidateEvent(
        public let agent: Agent,
        public let answer: String // The agent's generated output
    ) {
        super(EventKind.AnswerValidate)
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
 * Triggered when agent execution exceeds a time limit.
 */
public class TimeoutEvent <: InteractionEvent { // Return: Unit
    public TimeoutEvent(
        public let agent: Agent,
        public let execution: AgentExecution // The stalled execution context
    ) {
        super(EventKind.Timeout)
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