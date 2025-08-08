/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.tool.{ToolRequest, ToolResponse}

import std.collection.HashMap

private struct CacheItem {
    CacheItem(
        let toolRequest: ToolRequest,
        // Result of the tool invocation
        let toolResponse: ToolResponse,
        // Compressed result, if applicable
        // This is used to store the result in a compressed format for efficiency.
        let compressedResult: String
    ) { }
}

/**
 * A simple cache for tool results.
 * It stores the tool request, its invocation result and its compressed result.
 */
class ToolResultCache {
    private let cache = HashMap<Int64, CacheItem>()

    func getOriginalResult(id: Int64): Option<String> {
        return this.cache.get(id)?.compressedResult
    }

    public func put(toolRequest!: ToolRequest,
                    toolResponse!: ToolResponse,
                    compressedResult!: String): String {
        let id = this.cache.size
        this.cache.add(id, CacheItem(toolRequest, toolResponse, compressedResult))
        return String.join(
            [
                "# Summary of Tool Result",
                compressedResult,
                "---------------------------------------",
                "VERY IMPORTANT NOTE: This result is summarized, and detailed results can be viewed by calling tool `${ToolResultViewerTool.NAME}` with ${ToolResultViewerTool.PARAM}: ${id}."
            ],
            delimiter: "\n"
        )
    }

    public func clear(): Unit {
        this.cache.clear()
    }
}