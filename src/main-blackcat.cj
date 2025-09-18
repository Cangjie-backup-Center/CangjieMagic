/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter


@tool[description: "..."]
func ta(a: Int64): String { "" }

@tool[description: "..."]
func tb(a: Int64): String { "" }

@agent[
    // model: "deepseek:deepseek-chat",
    model: "ark:deepseek-v3-250324",
    // model: "maas:deepseek-v3-32k",
    // model: "siliconflow:deepseek-ai/DeepSeek-V3",
    // model: "ollama:deepseek-r1:14b",
    executor: "naive",
    tools: [
        httpMCP("http://localhost:8000"),
        httpMCP("http:localhost.com"),
        stdioMCP("cmd.exe /C npx -y fetcher-mcp"),
        stdioMCP("cmd.exe /C 'npm -y fetcher-mcp'"),
        stdioMCP("cmd.exe /C 'npm -y @browserbasehq/mcp'", BROWSERBASE_API_KEY: "...", BROWSERBASE_PROJECT_ID: "..."),
        { command: "cjpm",
          args: [ "run",
                  "--skip-build",
                  "--target-dir", "../CangjieMagic-MCPServer/target"
                  "--name", "filesystem",
                  "--run-args", "--allowed-dir D:/CangjieMagic/temp-docs" ] },
        stdioMCP('cjpm run --skip-build --target-dir ../CangjieMagic-MCPServer/target --name filesystem --run-args "--allowed-dir D:/CangjieMagic/temp-docs"', PATH: "NO-PATH", A: "A"),
        ta, tb,
        ta
    ],
    // memory: true
    // rag: {source: Abc(), mode: "oops", description: "xyz" }
]
class BlackCatAssistant {
    @prompt(
        "你是黑猫警长的助手"
        "当接到群众通知后，你需要唱起黑猫警长的专属 BGM 并安抚群众情绪"
    )
}

func testBlackCat() {
    let a = ConversationAgent(BlackCatAssistant())
    println(a.chat("龟派气功是什么"))
    let aresp = a.asyncChat(AgentRequest("该怎么练习？", verbose: true))
    ConsolePrinter.print(aresp, verbose: true)
    return ()
}