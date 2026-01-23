/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.tool

/**
 * A set of tools that can be used by an agent.
 */
public interface Toolset {
    /**
     * Get the name of the toolset.
     */
    prop name: String
    /**
     * Get all tools
     */
    prop tools: Array<Tool>
}
