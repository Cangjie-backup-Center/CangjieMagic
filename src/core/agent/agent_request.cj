/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.{Dialog, ChatMessage}

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
     * Previous chat history between the user and agent
     */
    public let dialog: Option<Dialog>

    /**
     * Dump internal execution information
     */
    public let verbose: Bool

    /**
     * The maximum number of tools that can be used when enable tool filter
     */
    public let maxTool: Int64

    /**
     * An agent request may be handled by multiple agents,
     * so this field stores previous execution info
     */
    protected var execInfo: Option<AgentExecutionInfo> = None

    public init(question: String,
                dialog!: Option<Dialog> = None,
                verbose!: Bool = false,
                maxTool!: Int64 = 10) {
        this.question = question
        this.dialog = dialog
        this.verbose = verbose
        this.maxTool = maxTool
    }
}
