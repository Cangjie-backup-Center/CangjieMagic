/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent

import magic.core.agent.{Agent, AgentRequest, AgentResponse, AsyncAgentResponse}
import magic.core.model.ChatModel
import magic.core.message.{Dialog, ChatMessage}
import magic.log.LogUtils

/**
 * Wrap an agent as a conversation agent that is able to save chat messages.
 */
public class ConversationAgent <: BaseAgent {
    private let agent: Agent
    let dialog: Dialog

    public init(agent: Agent) {
        super (
            model: unsafe { zeroValue<ChatModel>() }, // This agent has no models
            name: "Conversation Agent",
            description: "An proxy agent that saves chat messages."
        )
        this.agent = agent
        this.dialog = Dialog()
    }

    private func buildFullRequest(request: AgentRequest): AgentRequest {
        if (request.dialog.isSome()) {
            LogUtils.error("The request of ConversationAgent should have no dialog, which will be omitted.")
        }
        return AgentRequest(
            request.question,
            dialog: this.dialog,
            verbose: request.verbose
        )
    }

    override public func chat(request: AgentRequest): AgentResponse {
        let resp = this.agent.chat(this.buildFullRequest(request))
        this.dialog.addMessage(ChatMessage.user(request.question))
        this.dialog.addMessage(ChatMessage.assistant(resp.content))
        return resp
    }

    override public func asyncChat(request: AgentRequest): AsyncAgentResponse {
        let asyncResp = this.agent.asyncChat(this.buildFullRequest(request))
        return AsyncAgentResponse( // Wrap the iterator as the AsyncAgentResponse
            IteratorWrapper(this, request.question, asyncResp), // Wrap the original AsyncAgentResponse as an iterator
            execInfo: asyncResp.execInfo
        )
    }
}

/**
 * Wrap the AsyncAgentResponse,
 * merge the full response content and add to the dialog
 */
private class IteratorWrapper <: Iterator<String> {
    protected IteratorWrapper(
        private let agent: ConversationAgent,
        private let question: String,
        private let asyncAgentResp: AsyncAgentResponse
    ) { }

    /**
     * To merge all response content
     */
    private let buffer = StringBuilder()

    override public func next(): Option<String> {
        let data = this.asyncAgentResp.next()
        match (data) {
            case Some(v) => buffer.append(v)
            case None =>
                this.agent.dialog.addMessage(ChatMessage.user(this.question))
                this.agent.dialog.addMessage(ChatMessage.assistant(this.buffer.toString()))
        }
        return data
    }
}

