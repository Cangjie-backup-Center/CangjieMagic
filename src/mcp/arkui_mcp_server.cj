package magic.mcp

import stdx.net.http.*
import std.net.*
import std.io.*
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.*
import magic.core.agent.Agent
import magic.tool.AgentAsTool
import magic.log.LogUtils
import magic.jsonable.*
import magic.core.tool.Tool
import magic.utils.{randomString}
import std.fs.{Path, Directory, File, exists, remove, copy}
import std.process.*
import std.regex.*

import stdx.net.http.*

public class ArkUIMCPServer <: SseMCPServer {
    public init(ui: Array<Tool>) {
        super(ui)
    }
}
