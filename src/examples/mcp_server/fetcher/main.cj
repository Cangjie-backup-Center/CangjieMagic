/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.mcp_server.fetcher

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.mcp.{StdioMCPClient, MCPServer}
import magic.core.rag.Document
import magic.log.LogUtils
import magic.rag.splitter.MarkdownSplitter
import magic.vdb.{SemanticMap, InMemoryVectorDatabase, JsonlIndexMap}

import log.LogLevel
import std.collection.{map, collectArray}

private type SimpleMarkdownSemanticMap = SemanticMap<InMemoryVectorDatabase, JsonlIndexMap<Document>, Document>

@tool[
    description: "Fetch web page content from a specified URL as markdown and retrieve related parts",
    parameters: {
        target: "Describe which content is expected from the URL",
        url: "The URL of the web page to fetch (required parameter)"
    }
]
func fetchAndRetrieve(target: String, url: String): String {
    let client = StdioMCPClient("cmd.exe", ["/C", "npx -y fetcher-mcp"])
    let toolResponse = client.callTool("fetch_url", [("url", url)])
    if (toolResponse.isError) {
        return "Fail to fetch url: ${toolResponse.content}"
    }
    LogUtils.info("Fetched Content:\n ${toolResponse.content}\n")
    LogUtils.info("-----------------------------------")
    // Load and split the document
    let splitter = MarkdownSplitter(returnEachLine: false)
    let docs = splitter.split(toolResponse.content)
    // Initialize the semantic map
    let smap = SimpleMarkdownSemanticMap(vectorDB: InMemoryVectorDatabase(),
                                        indexMap: JsonlIndexMap<Document>(),
                                        embeddingModel: Config.defaultEmbeddingModel)
    // Add all document
    for (doc in docs) {
        LogUtils.info("Splitted Docs:\n ${doc.toString()}\n")
        LogUtils.info("-----------------------------------")
        smap.put(doc.content, doc)
    }

    let foundDocs = smap.search(target)
    LogUtils.info("Retrieved Docs:\n ${foundDocs.toString()}\n")
    LogUtils.info("-----------------------------------")
    return String.join(
        foundDocs |> map { doc: Document => doc.toPrompt() } |> collectArray,
        delimiter: "\n"
    )
}

main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/fetch-retrieve-server.log"
    Config.defaultEmbeddingModel = ModelManager.createEmbeddingModel("ollama:nomic-embed-text")

    MCPServer.startWith([fetchAndRetrieve])
}