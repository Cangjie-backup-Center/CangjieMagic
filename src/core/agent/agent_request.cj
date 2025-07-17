/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.Conversation

import std.collection.HashMap

/**
 * The execution request to an agent executor
 * This type encodes the agent communication protocol
 */
public class AgentRequest {
    /**
     * The current user question
     */
    public let question: String

    /**
     * The user input question for using VLM
     */
    public let image: Option<String>

    /**
     * Conversation between the user and agent
     */
    public let conversation: Option<Conversation>

    /**
     * Dump internal execution information
     */
    public let verbose: Bool

    /**
     * The maximum number of tools that can be used when enable tool filter
     */
    public let maxTool: Int64

    public init(question: String,
                image!: Option<String> = None,
                conversation!: Option<Conversation> = None,
                verbose!: Bool = false,
                maxTool!: Int64 = 10) {
        this.question = question
        this.image = image
        this.conversation = conversation
        this.verbose = verbose
        this.maxTool = maxTool
    }

    /**
     * Save extra internal data structures; currently support:
     * - "previous-execution": AgentExecution
     *    An agent request may be handled by multiple agents,
     *    so this field stores previous execution info
     *
     * - "EventHandlerManager.CLASS_NAME": EventHandlerManager
     *    Users can register event handlers for each request
     * - "install-verbose-event-handler": AtomicBool
     *    Subagents may inherit event handlers from its parent agent
     *    Default: true
     */
    protected let extra = HashMap<String, Object>()
}
