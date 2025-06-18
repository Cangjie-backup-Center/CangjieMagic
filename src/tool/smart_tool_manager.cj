/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.dsl.jsonable
import magic.core.tool.*
import magic.core.model.{ChatModel, EmbeddingModel}
import magic.core.message.Message
import magic.config.Config
import magic.log.LogUtils
import magic.jsonable.*
import magic.model.{ModelManager, ModelUtils}
import magic.storage.vdb.JsonMemoryVectorStorage
import magic.storage.kv.JsonKVStorage
import magic.core.rag.Document
import magic.prompt.Template
import magic.parser.OutputParserUtils
import magic.vdb.{SemanticMap, InMemoryVectorDatabase, SimpleIndexMap}
import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.*

public class ManagerTool <: AbsTool {
    public let manager: SmartToolManager
    public init(manager: SmartToolManager) {
        this.manager = manager
    }
    public prop name: String {
        get() {
            "__manager__tool__"
        }
    }

    public prop description: String {
        get() {
"""
查询可用工具或工具集，这些工具仅提供原子性的能力，查询前需要将原始需求分解为可能要使用的工具组合
----------------例1：
User:武汉的旅游规划
Assistant: 
[Action]
```json
{
    "name": "__manager__tool__",
    "arguments": {
        "query": "网络搜索|景点信息|车票查询|路线规划"
    }
}
```
[/Action]
----------------例2：
User:最新关于特斯拉的新闻
Assistant: 
[Action]
```json
{
    "name": "__manager__tool__",
    "arguments": {
        "query": "网络搜索|热点资讯"
    }
}
```
[/Action]
----------------例3：
User:帮我阅读xx.pdf
Assistant: 
[Action]
```json
{
    "name": "__manager__tool__",
    "arguments": {
        "query": "PDF阅读器"
    }
}
```
[/Action]
工具执行错误时你需要先观察工具执行错误的原因, 仔细思考后再尝试解决
如果需要更多的工具，需要积极调用本工具来查询更多的工具来满足需求
"""
        }
    }

    public prop parameters: Array<ToolParameter> {
        get() {
            [
                ToolParameter(
                    "query",
                    "要查询的工具集，用顿号|分割",
                    TypeSchema.Str
                )
            ]
        }
    }

    public prop retType: TypeSchema {
        get() {
            TypeSchema.Str
        }
    }

    public prop examples: Array<String> {
        get() {
            []
        }
    }

    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        // The retriever model tool must accept a string
        let find = args["query"].toJsonValue().asString().getValue()
        let tools = this.manager.filterToolViaEmbedding(find)
        LogUtils.info("=================INVOKED TOOLS: ${tools.size}")
        if (tools.size == 0) {
            return ToolResponse("# Available Tools\nNo tools")
        }
        let toolStringArr = tools |> map {t: Tool => t.toString()} |> collectArray
        let str = String.join(toolStringArr, delimiter: ",\n")
        let avaTools = "# Available Tools\n[\n ${str} \n]\n---end of tools---"
        return ToolResponse(avaTools)
    }
}

public class SmartToolManager <: ToolManager {
    private let tools = HashMap<String, Tool>()

    private let _enableFilter: Bool

    private let _embeddingModel: EmbeddingModel
    private let _chatModel: ChatModel

    private let _vdb: JsonMemoryVectorStorage
    private let _kv: JsonKVStorage<String>
    private var _mt: Option<ManagerTool> = None

    public init(tools: Collection<Tool>, enableFilter!: Bool = false) {
        this._enableFilter = enableFilter
        this._embeddingModel = Config.defaultEmbeddingModel.getOrThrow()
        this._chatModel = Config.defaultChatModel.getOrThrow()
        this._vdb = JsonMemoryVectorStorage(this._embeddingModel)
        this._kv = JsonKVStorage()
        for (t in tools) {
            addTool(t)
        }
    }

    public override prop enableFilter: Bool {
        get() {
            return _enableFilter
        }
    }

    public override func addTool(tool: Tool): Unit {
        this.tools.put(tool.name, tool)
        let meta = HashMap<String, String>()
        meta.put("name", tool.name)
        if (this._kv.get(tool.name).isNone()) {
            this._vdb.add(Document(tool.description, metadata: meta))
            this._kv.upsert(tool.name, tool.name)
            this._vdb.commit()
            this._kv.commit()
        }
    }

    public override func delTool(tool: Tool): Unit {
        if (tools.contains(tool.name)) {
            tools.remove(tool.name)
        }
    }

    public override func addTools(tools: Array<Tool>): Unit {
        for (tool in tools) {
            this.addTool(tool)
        }
    }

    public override func clear(): Unit {
        this.tools.clear()
    }

    public override func findTool(name: String): Option<Tool> {
        return tools.get(name)
    }

    public override func getTools(): Array<Tool> {
        return tools.values().toArray()
    }

    private func splitTools(pred: (Tool) -> Bool): (ArrayList<Tool>, ArrayList<Tool>) {
        let groupA = ArrayList<Tool>()
        let groupB = ArrayList<Tool>()
        for (tool in this.getTools()) {
            if (pred(tool)) {
                groupA.append(tool)
            } else {
                groupB.append(tool)
            }
        }
        return (groupA, groupB)
    }

    public override func filterTool(question: String, config: ToolSearchConfig): Array<Tool> {
        let mt = ManagerTool(this)
        if (this._mt.isNone()) {
            this._mt = mt
        }
        return [mt]
    }

    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        return this._mt.getOrThrow().invoke(args)
    }

    protected func filterToolViaEmbedding(question: String): Array<Tool> {
        // Do not build the semantic map from scratch
        // Change it later
        let docs = this._vdb.query(question, 20, threshold: 0.2)
        let tools = docs |> map({doc => doc.metadata.get("name").getOrThrow()}) |> map(
            {name => findTool(name).getOrThrow()}) |> collectArray
        let toolPrompts = ArrayList<String>()
        for (tool in tools) {
            toolPrompts.append("${tool.name}: ${tool.description}")
        }
        LogUtils.info("=================MAYBE TOOLS: ${tools.size}")
        let messages = [
            Message.system(
                FILTER_TOOL_PROMPT.format(
                    ("number", 10),
                    ("question", question),
                    ("tools", String.join(toolPrompts.toArray(), delimiter: "\n-----\n"))
                )
            )
        ]
        let model = this._chatModel
        let response = ModelUtils.makeChatGet<Response>("Simple Tool Manager", model, messages) {
            msg: Message =>
            if (let Some(jsonStr) <- OutputParserUtils.extractLastCode(msg.content, "json")) {
                // LogUtils.info("Tool filtered response: ${jsonStr}")
                try {
                    let json = JsonValue.fromStr(jsonStr)
                    return Response.fromJsonValue(json)
                } catch (_: JsonableException) {
                    LogUtils.error("Failed to parse the chat model response `${jsonStr}` as Jsonable")
                    return None
                } catch (_: JsonException) {
                    LogUtils.error("Failed to parse the chat model response `${jsonStr}` as JsonValue")
                    return None
                }
            }
            LogUtils.error("Failed to parse the chat model response")
            return None
        }
        let filteredTools = ArrayList<Tool>()
        for (tool in (response?.relevantTools) ?? []) {
            if (let Some(t) <- this.findTool(tool.name)) {
                filteredTools.append(t)
            } else {
                LogUtils.error("Invalid tool after being filtered: `${tool.name}`")
            }
        }
        return filteredTools.toArray()
    }
}
