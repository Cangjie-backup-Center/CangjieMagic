/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

import magic.core.model.{ChatModel, EmbeddingModel}

public struct ToolSearchConfig {
    public ToolSearchConfig(
        /**
         * Filter tools via an embedding model or a chat model
         */
        public let viaEmbedding!: Bool = false,

        /**
         * The chat model to use
         */
        public let chatModel!: Option<ChatModel> = None,

        /**
         * The embedding model to use
         */
        public let embeddingModel!: Option<EmbeddingModel> = None,

        /**
         * The maximum number of tools to filter
         */
        public let number!: Int64 = 10
    ) { }
}

/**
 * Manage agent tools
 */
public interface ToolManager <: Toolset {
    /**
     * Add a new tool
     */
    func addTool(tool: Tool): Unit

    /**
     * Delete a tool if it exists
     */
    func delTool(tool: Tool): Unit

    /**
     * Add new tools
     */
    func addTools(tools: Collection<Tool>): Unit

    /**
     * Delete all tools
     */
    func clear(): Unit

    /**
     * Find a tool according to its name
     */
    func findTool(name: String): Option<Tool>

    /**
     * Filter related tools to the question
     */
    func filterTool(question: String, config: ToolSearchConfig): Array<Tool>

    /**
     * Whether filtering tools is enabled
     */
    prop enableFilter: Bool
}