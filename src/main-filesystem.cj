/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter
import magic.agent_executor.tool_loop.ToolLoopExecutor

@agent[
    model: "ark:deepseek-v3-250324",
    executor: "react",
    tools: [
        stdioMCP("cjpm run --skip-build --target-dir ../CangjieMagic-MCPServer/target --name filesystem --run-args '--allowed-dir D:/CangjieMagic/temp-docs'")
    ]
]
class FileAssistant {
    @prompt(
        "你是文件助手，帮助用户查看文件"
        "针对文件查看需求，逐步规划，你可以使用工具"
        "你不需要读取或者了解文件的内容"
    )
}

func testFilesystem() {
    let agent = FileAssistant()
    // agent.model = ModelManager.createChatModel("siliconflow:deepseek-ai/DeepSeek-R1-Distill-Qwen-7B")
    // let resp = agent.chat("我有多少个 pdf 文件，禁止读取任何文件内容")
    // println(resp)
    // return ()

    let aresp = agent.asyncChat(
        AgentRequest(
            "我有多少个 pdf 文件，禁止读取任何文件内容",
            // "为每一个 markdown 文件，生成 PPT",
            // "帮我把所有 PDF 转换为 markdown 格式",
            verbose: true
        )
    )

    ConsolePrinter.print(aresp, verbose: true)
    // let messageList = aresp.execution.messageList
    println(aresp.execution.chatRound)
    return ()
}