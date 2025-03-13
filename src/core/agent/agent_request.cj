/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

import magic.core.message.{Dialog, ChatMessage}

/**
 * The execution request to an agent executor
 * This type encodes the agent communication protocol
 */
public struct AgentRequest {
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

    public init(question: String, dialog!: Option<Dialog> = None, verbose!: Bool = false) {
        this.question = question
        this.dialog = dialog
        this.verbose = verbose
    }
}
