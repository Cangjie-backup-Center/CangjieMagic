/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.tool.*
import magic.vdb.{SemanticMap, InMemoryVectorDatabase, SimpleIndexMap}
import magic.model.ModelManager
import magic.config.Config

import std.collection.{ArrayList, HashMap, map, collectArray}

private type InMemSemanticMap = SemanticMap<InMemoryVectorDatabase, SimpleIndexMap, String>

public class SimpleToolManager <: ToolManager {
    private let _enableToolSearch: Bool
    private let tools = HashMap<String, Tool>()
    private var _toolSemanticMap: Option<InMemSemanticMap> = None

    private prop toolSemanticMap: InMemSemanticMap {
        get() {
            match (_toolSemanticMap) {
                case Some(v) => v
                case None =>
                    let v = InMemSemanticMap(
                        vectorDB: InMemoryVectorDatabase(),
                        indexMap: SimpleIndexMap(),
                        embeddingModel: Config.defaultEmbeddingModel
                    )
                    _toolSemanticMap = v
                    return v
            }
        }
    }

    public init() {
        _enableToolSearch = false
    }

    public init(tools: Collection<Tool>, enableToolSearch!: Bool = false) {
        this._enableToolSearch = enableToolSearch
        for (t in tools) {
            addTool(t)
        }
    }

    override public func addTool(tool: Tool): Unit {
        tools.put(tool.name, tool)
        if (_enableToolSearch) {
            toolSemanticMap.put(tool.description, tool.name)
        }
    }

    override public func delTool(tool: Tool): Unit {
        if (tools.contains(tool.name)) {
            tools.remove(tool.name)
        }
        // How to update the semantic map?
        // Currently, we do not update it
    }

    override public func addTools(tools: Array<Tool>): Unit {
        for (tool in tools) {
            this.addTool(tool)
        }
    }

    override public func clear(): Unit {
        this.tools.clear()
    }

    override public func findTool(name: String): Option<Tool> {
        return tools.get(name)
    }

    override public func getTools(): Array<Tool> {
        return tools.values().toArray()
    }

    override public func searchTool(question: String, number!: Int64 = 5): Array<Tool> {
        if (!_enableToolSearch) {
            throw ToolException("Tool manager does not enable semantic search")
        }
        let found = ArrayList<Tool>()
        for (name in toolSemanticMap.search(question, number: number)) {
            // The semantic map may contain obsolete tools
            if (let Some(t) <- this.findTool(name)) {
                found.append(t)
            }
        }
        return found.toArray()
    }

    override public prop enableToolSearch: Bool {
        get() { return _enableToolSearch }
    }
}