/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.dsl.jsonable
import magic.core.tool.*
import magic.core.model.ChatModel
import magic.core.message.ChatMessage
import magic.config.Config
import magic.log.LogUtils
import magic.jsonable.*
import magic.model.{ModelManager, ModelUtils}
import magic.prompt.Template
import magic.parser.OutputParserUtils
import magic.vdb.{SemanticMap, InMemoryVectorDatabase, SimpleIndexMap}

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.*

@jsonable
private class Response {
    let relevantTools: Array<FoundTool>
}

@jsonable
private class FoundTool {
    let name: String
    let reason: String
}

private const FILTER_TOOL_PROMPT = """
Objective: Select the most relevant tool(s) for a given user question from a predefined list.

# Instructions

Analyze the user's question and the provided list of tools.
For each tool, evaluate its relevance to the question based on its name and description.
Return the top {number} most relevant tools (if any), ranked by relevance. If no tool fits, return "None."
Justify your selections with a brief reasoning.

# Available Tools

{tools}
...

# Output Structure:

```json
{
  "relevantTools": [
    {
      "name": "[Selected Tool Name]",
      "reason": "[Brief justification]"
    },
    ... 
  ]
}
```

# Examples of Input/Output

## Example 1

User Question: "How can I extract text from a PDF?"
Available Tools:

PDF Text Extractor: Extracts raw text from PDFs while preserving formatting.
-----
Image OCR: Converts text in images/scans to machine-readable text.
-----
PDF Editor: Edits PDF metadata, merges/splits pages, but does not extract text.

Output:
```json
{
  "relevantTools": [
    {
      "name": "PDF Text Extractor",
      "reason": "Directly matches the task of extracting text from PDFs."
    },
    {
      "name": "Image OCR",
      "reason": "May be useful if the PDF contains scanned images of text."
    }
  ]
}
```

## Example 2

User Question: "What's the weather today?"
Available Tools:

PDF Text Extractor: Extracts raw text from PDFs while preserving formatting.
-----
Image OCR: Converts text in images/scans to machine-readable text.
-----
Web Search: Retrieve information from the internet by querying search engines.
-----
Get Time: Retrieves the current date and time

Output:
```json
{
  "relevantTools": [
    {
      "name": "Web Search",
      "reason": "Search the Weather forecast."
    },
    {
      "name": "Get Time",
      "reason": "I need to know today's date to get the accurate weather."
    }
  ]
}
```

# Input
User Question: {question}
"""

private type InMemSemanticMap = SemanticMap<InMemoryVectorDatabase, SimpleIndexMap, String>

public class SimpleToolManager <: ToolManager {
    private let tools = HashMap<String, Tool>()

    private let _enableFilter: Bool

    public init() {
        _enableFilter = false
    }

    public init(tools: Collection<Tool>, enableFilter!: Bool = false) {
        this._enableFilter = enableFilter
        for (t in tools) {
            addTool(t)
        }
    }

    override public prop enableFilter: Bool {
        get() { return _enableFilter }
    }

    override public func addTool(tool: Tool): Unit {
        tools.put(tool.name, tool)
    }

    override public func delTool(tool: Tool): Unit {
        if (tools.contains(tool.name)) {
            tools.remove(tool.name)
        }
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

    override public func filterTool(question: String, config: ToolSearchConfig): Array<Tool> {
        if (!this.enableFilter) {
            return this.getTools()
        }
        // Tools, whose filterable == false, are special tools
        let (specialTools, normalTools) = this.splitTools({ tool =>
            (tool.extra.get("filterable") ?? "") == "false"
        })
        let filteredTools = if (config.viaEmbedding) {
            this.filterToolViaEmbedding(question, normalTools, config)
        } else {
            this.filterToolViaLLM(question, normalTools, config)
        }
        LogUtils.info("Filtered tools: ${normalTools.size} -> ${filteredTools.size}")
        // Special tools are put first
        specialTools.appendAll(filteredTools)
        return specialTools.toArray()
    }

    private func filterToolViaEmbedding(question: String,
                                        tools: ArrayList<Tool>,
                                        config: ToolSearchConfig): Array<Tool> {
        if (config.embeddingModel.isNone()) {
            throw ToolException("An embedding model is not specified")
        }
        // Do not build the semantic map from scratch
        // Change it later
        let semMap = InMemSemanticMap(
            vectorDB: InMemoryVectorDatabase(),
            indexMap: SimpleIndexMap(),
            embeddingModel: config.embeddingModel.getOrThrow()
        )
        // Put tools in the semantic map
        for (tool in tools) {
            semMap.put(tool.description, tool.name)
        }

        let filteredTools = ArrayList<Tool>()
        for (name in semMap.search(question, number: config.number)) {
            if (let Some(t) <- this.findTool(name)) {
                filteredTools.append(t)
            }
        }
        return filteredTools.toArray()
    }

    private func filterToolViaLLM(question: String,
                                  tools: ArrayList<Tool>,
                                  config: ToolSearchConfig): Array<Tool> {
        if (config.chatModel.isNone()) {
            throw ToolException("A chat model is not specified")
        }
        let toolPrompts = ArrayList<String>()
        for (tool in tools) {
            toolPrompts.append("${tool.name}: ${tool.description}")
        }
        let messages = [
            ChatMessage.system(
                FILTER_TOOL_PROMPT.format(
                    ("number", config.number),
                    ("question", question),
                    ("tools", String.join(toolPrompts.toArray(), delimiter: "\n-----\n"))
                )
            )
        ]
        let model = config.chatModel.getOrThrow()
        let response = ModelUtils.makeChatGet<Response>(
            "Simple Tool Manager", model, messages) { msg: ChatMessage =>
            if (let Some(jsonStr) <- OutputParserUtils.extractLastCode(msg.content, "json")) {
                // LogUtils.info("Tool filtered response: ${jsonStr}")
                try {
                    let json = JsonValue.fromStr(jsonStr)
                    return Response.fromJsonValue(json)
                } catch (_: JsonException) {
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
