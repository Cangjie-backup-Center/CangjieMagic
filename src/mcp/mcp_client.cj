/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.mcp

import magic.core.tool.{Tool, ToolResponse}
import magic.utils.newProcess
import magic.jsonable.*
import magic.log.LogUtils

/**
 * MCP client
 * Currently, clients support listing/calling tools
 */
public interface MCPClient {

    prop group: String
    
    func getTools(): Array<Tool>

    func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse
}
