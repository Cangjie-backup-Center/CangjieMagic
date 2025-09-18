/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.config.Config

import magic.vdb.*
import magic.parser.*
@When[os == "Windows"]
import magic.utils.winGetArgs
import magic.parser.ParserUtils
import magic.interaction.*
import magic.core.interaction.*

// import magic.oh_dsl.*
import std.ast.*
import stdx.encoding.json.*
import std.regex.*
import std.time.*
import std.collection.*
import std.env.getStdOut

import std.fs.{File, Path}
import magic.utils.http.*
import magic.utils.readFile
import magic.compactor.*
import magic.jsonable.JsonUtils

@tool[description: "Search the web"]
func search(query: String): String { "Found ${query}" }

@agent[
    model: "siliconflow:Pro/deepseek-ai/DeepSeek-V3",
    temperature: 0.0,
    // model: "ark:kimi-k2-250711",
    executor: "react",
    tools: [
        search,
        httpMcp("https://mcp.context7.com/mcp", CONTEXT7_API_KEY: "ctx7sk-e4a99b9b-6ec8-4dc7-924a-5ae57ce7b1e7")
    ]
]
private class Foo {
    @prompt(
        "For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially."
    )
}

main() {
    Config.logLevel = "TRACE"
    Config.logFile = "./logs/abc.log"
    // Config.enableModelToolCall = true
    Config.saveCodeInterpreter = true
    // Config.enableAgentLog = true
    // Config.saveModelRequest = true
    Config.defaultEmbeddingModel = ModelManager.createEmbeddingModel("siliconflow:Qwen/Qwen3-Embedding-4B")

    let agent = Foo()
    let aresp = agent.asyncChat(AgentRequest(
        "which tools do you have?", verbose: true))
    ConsolePrinter.print(aresp, verbose: true)
    return ()

    let client = HttpMCPClient("https://mcp.context7.com/mcp", headers: [("CONTEXT7_API_KEY", "ctx7sk-e4a99b9b-6ec8-4dc7-924a-5ae57ce7b1e7")])

    // let client = StdioMCPClient("npx", ["-y", "@upstash/context7-mcp", "--api-key", "ctx7sk-e4a99b9b-6ec8-4dc7-924a-5ae57ce7b1e7"])
    let libId = client.callTool("resolve-library-id", [("libraryName", "cangjie")])
    println(libId.content)
    let topic = "join two strings"
    // // /dyingchinese/cangjie-stdx
    let docs = client.callTool("get-library-docs", [("context7CompatibleLibraryID", "/websites/cangjie-lang_cn-1.0.0"), ("topic", topic), ("tokens", 3000)])
    println(docs.content)
    // println(client.tools.toJsonValue().toJsonString())
    // return ()

    // testSubagent()
    // testAI()
    // testImage()
    // testFilesystem()
    // testTemplate()
    // testUI()
    testMagic()
    // testImport()
    // testInteract()
    // testModel()
    ()
}

func testModel() {
    // let embModel = ModelManager.createEmbeddingModel("ollama:nomic-embed-text")
    // let resp = embModel.create(EmbeddingRequest("花椰菜又称菜花、花菜，是一种常见的蔬菜。"))
    // println(resp)
    // return ()

    // let imgModel = ModelManager.createImageModel("siliconflow:Kwai-Kolors/Kolors")
    // let resp = imgModel.create(ImageRequest("花椰菜又称菜花、花菜，是一种常见的蔬菜。"))
    // println(resp.url)
    // return ()

    // let model = ModelManager.createChatModel("siliconflow:deepseek-ai/DeepSeek-V3")
    let model = ModelManager.createChatModel("ollama:gpt-oss:20b")
    // let model = ModelManager.createChatModel(
    //     ModelConfig(
    //         provider: "ark",
    //         kind: "chat",
    //         // name: "bot-20250313163125-s42dl",
    //         name: "bot-20250313163825-mjg8q",
    //         baseURL: "https://ark.cn-beijing.volces.com/api/v3/bots",
    //         apiKey: '27f20532-7bb4-4e22-850e-e28f42eb68c1')
    // )
    let resp = model.create(
        ChatRequest(
            [Message.user("今天是 2023年10月1号，记录到本地")],
            tools: MyToolset().tools
        )
    )
    println(resp)
    // for (chunk in model.asyncCreate(ChatRequest("啊啊"))) {
    //     print(chunk.message.reason ?? chunk.message.content)
    // }
    // println()
    // return ()
}

func testMCP() {
    // let url = "http://localhost:8000/sse"
    // let url = "https://mcp.amap.com/sse?key=e52794430e9b4a2583dc3060236e2d37"
    // let url = "http://119.3.125.66:8080/sse"
    // let myClient = SseMCPClient(url)

    // let myClient = StdioMCPClient("cjpm", ["run", "--skip-build", "--name", "magic.examples.mcp_server.fetcher"])
    // let tools = myClient.getTools()
    // println(tools)
    // return ()
    // var v = myClient.callTool(
    //     "maps_weather",
    //     [
    //         ("city", "上海")
    //     ]
    // )
    // println(v.content)
    // return ()
}
