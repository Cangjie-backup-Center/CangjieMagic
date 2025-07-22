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
import std.collection.{ArrayList, HashMap, map, filter, take, collectArray}
import encoding.json.*
import serialization.serialization.*

public class ManagerTool <: AbsTool {
    public let manager: SmartToolManager
    public init(manager: SmartToolManager) {
        this.manager = manager
    }

    public prop group: String {
        get() {
            "__manager_group__"
        }
    }

    public prop name: String {
        get() {
            "__manager__tool__"
        }
    }

    public prop description: String {
        get() {
            "从工具集(tool set)中获取特定功能的一个或多个工具"
        }
    }

    public prop parameters: Array<ToolParameter> {
        get() {
            [
                ToolParameter(
                    "tool_set_id",
                    "工具集id",
                    TypeSchema.Int
                ),
                ToolParameter(
                    "tool_ablities",
                    "需要工具提供哪些具体的功能",
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
        try {
            let tool_id = args["tool_set_id"].toJsonValue().asInt().getValue()
            if (let Some(group) <- this.manager.getGroupName(tool_id)) {
                let find = args["tool_ablities"].toJsonValue().asString().getValue()
                var tools = this.manager.filterToolByGroup(find, 20, group)
                if (tools.size == 0) {
                    return ToolResponse("# Available Tools\nNo tools")
                }
                let toolStringArr = tools |> map {t: Tool => t.toString()} |> collectArray
                let str = String.join(toolStringArr, delimiter: ",\n")
                let avaTools = "# Available Tools\n[\n ${str} \n]\n---end of tools---"
                return ToolResponse(avaTools)
            } else {
                return ToolResponse("Wrong tool set id ${tool_id}")
            }
        } catch (e: NoneValueException) {
            return ToolResponse("Wrong Parameters")
        }
       
    }

    public func getAllToolSummarize(): String {
        this.manager.getAllToolSummarize()
    }
}

let TOOL_GROUP_SUMMARIZE_PROMPT = """
Objective: Summarize the main capabilities of the current toolset

# Instructions
List the functions of the current toolset and categorize them by domain if they involve multiple fields. The final answer should cover all tool functions concisely.

# Example:
Tools:
maps_direction_transit_integrated:根据用户起终点经纬度坐标规划综合各类公共（火车、公交、地铁）交通方式的通勤方案，并且返回通勤方案的数据，跨城场景下必须传起点城市与终点城市
-----
maps_direction_walking:根据输入起点终点经纬度坐标规划100km 以内的步行通勤方案，并且返回通勤方案的数据
-----
maps_weather:根据城市名称或者标准adcode查询指定城市的天气
Anser：
1.规划公共交通、步行通勤方案 2.查询指定城市天气

# Tools
{tools}
"""

class ToolSet <: Serializable<ToolSet> {
    public let group: String
    public let desc: String
    public let tools: String

    public init(group: String, desc: String, tools: String) {
        this.group = group
        this.desc = desc
        this.tools = tools
    }

    public func serialize(): DataModel {
        let dm = DataModelStruct()
        dm.add(field<String>("group", group))
        dm.add(field<String>("desc", desc))
        dm.add(field<String>("tools", tools))
        return dm
    }

    public static func deserialize(dm: DataModel): ToolSet {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let group = String.deserialize(dms.get("group"))
        let desc = String.deserialize(dms.get("desc"))
        let tools = String.deserialize(dms.get("tools"))
        return ToolSet(group, desc, tools)
    }
}

public class SmartToolManager <: ToolManager {
    private let tools = HashMap<String, Tool>()
    private let groups = HashMap<String, ArrayList<Tool>>()
    private let idgnMap = HashMap<Int64, ToolSet>()
    private let _enableFilter: Bool

    private let _embeddingModel: EmbeddingModel
    private let _chatModel: ChatModel

    private let _vdb: JsonMemoryVectorStorage
    private let _kv: JsonKVStorage<String>
    private let _groupKv: JsonKVStorage<ToolSet>
    private var _mt: Option<ManagerTool> = None

    public init(tools: Collection<Tool>, enableFilter!: Bool = false) {
        this._enableFilter = enableFilter
        this._embeddingModel = Config.defaultEmbeddingModel.getOrThrow()
        this._chatModel = Config.defaultChatModel.getOrThrow()
        this._vdb = JsonMemoryVectorStorage(this._embeddingModel)
        this._kv = JsonKVStorage()
        this._groupKv = JsonKVStorage(collection: "group")
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
        if (!this.groups.contains(tool.group)) {
            this.groups.put(tool.group, ArrayList())
        }
        this.groups.get(tool.group).getOrThrow().append(tool)
        let meta = HashMap<String, String>()
        meta.put("name", tool.name)
        meta.put("group", tool.group)
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

    private func summarizeGroups(): Unit {
        var id = 1
        for ((group, tools) in groups) {
            if (let Some(toolset) <- this._groupKv.get(group)) {
                this.idgnMap.put(id, toolset)
            } else {
                let toolPrompts = ArrayList<String>()
                for (tool in tools) {
                    toolPrompts.append("${tool.name}: ${tool.description}")
                }
                let messages = [Message.system(
                    TOOL_GROUP_SUMMARIZE_PROMPT.format(
                    ("tools", String.join(toolPrompts.toArray(), delimiter: "\n-----\n"))))]
                let desc = ModelUtils.makeChat(this._chatModel, messages).getOrThrow().content
                let toolNames = tools |> map({tool => tool.name}) |> collectArray
                let toolset = ToolSet(group, desc, String.join(toolNames))
                this._groupKv.upsert(group, toolset)
                this._groupKv.commit()
                this.idgnMap.put(id, toolset)
            }
            id += 1
        }
    }

    public func getAllToolSummarize(): String {
        let sb = StringBuilder("# Tool Sets\n")
        for ((id, toolset) in idgnMap) {
            sb.append("-----Tool Set ${id}-----\n${toolset.desc}\n")
        }
        return sb.toString()
    }

    public override func filterTool(question: String, config: ToolSearchConfig): Array<Tool> {
        if (this._mt.isNone()) {
            let mt = ManagerTool(this)
            summarizeGroups()
            this._mt = mt
        }
        return [this._mt.getOrThrow()]
    }

    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        return this._mt.getOrThrow().invoke(args)
    }

    public func getGroupName(id: Int64): Option<String> {
        if (let Some(toolset) <- this.idgnMap.get(id)) {
            toolset.group
        } else {
            None
        }
    }

    protected func filterToolByGroup(question: String, top_k: Int64, group: String): Array<Tool> {
        // Do not build the semantic map from scratch
        // Change it later
        let docs = this._vdb.query(question, 100, threshold: 0.2)
        let tools = docs |> map({doc => doc.metadata.get("name").getOrThrow()}) |> map(
            {name => findTool(name).getOrThrow()}) |> filter({tool => tool.group == group}) |> take(top_k) |>
            collectArray
        LogUtils.info("=================MAYBE TOOLS: ${tools.size}")
        let toolPrompts = ArrayList<String>()
        for (tool in tools) {
            toolPrompts.append("${tool.name}: ${tool.description}")
        }
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
        let response = ModelUtils.makeChatGet<Response>("Smart Tool Manager", model, messages) {
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
        let res = filteredTools.toArray()
        LogUtils.info("=================INVOKED TOOLS: ${res.size}")
        res
    }
}
