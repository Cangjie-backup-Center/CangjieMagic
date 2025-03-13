/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

/**
 * Manage agent tools
 */
public interface ToolManager {
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
    func addTools(tools: Array<Tool>): Unit

    /**
     * Delete all tools
     */
    func clear(): Unit

    /**
     * Find a tool according to its name
     */
    func findTool(name: String): Option<Tool>

    /**
     * Get all tools
     */
    func getTools(): Array<Tool>

    /**
     * Search related tools to the question
     */
    func searchTool(question: String, number!: Int64): Array<Tool>

    /**
     * Whether semantic search of tools is enabled
     */
    prop enableToolSearch: Bool
}