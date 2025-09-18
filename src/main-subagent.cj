/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.utils.http.HttpUtils
import magic.config.Config
import magic.interaction.ConsolePrinter
import magic.tool.{AgentAsTool, SubAgentMode}

import std.fs.File

@tool[description: "读取文件内容"]
private func readFile(path: String): String {
    let content = String.fromUtf8(File.readFrom(path))
    return "文件内容如下:\n${content}\n--- 以上是文件 ${path} 的内容"
}

@agent[
    model: "ark:deepseek-v3-250324",
    executor: "naive"
]
class SummaryAgent {
    @prompt(
        "你是一个总结专家，擅长将大量信息进行总结"
        "请将以下内容进行总结，要求："
        "1. 内容全面，涵盖所有重要信息"
        "2. 语言简洁明了，避免冗长"
        "3. 结构清晰，有逻辑性"
        "4. 使用项目符号或编号列表来组织信息"
        "5. 确保没有语法或拼写错误"
    )
}

@agent[
    // model: "deepseek:deepseek-chat",
    model: "ark:deepseek-v3-250324",
    // model: "maas:deepseek-v3-32k",
    // model: "siliconflow:Qwen/Qwen2.5-VL-72B-Instruct",
    // model: "ollama:deepseek-r1:14b",
    executor: "tool-loop",
    tools: [readFile, AgentAsTool(SummaryAgent(), mode: SubAgentMode.WithContext)]
]
class ParentAgent {
    @prompt(
        "你是一个智能体，擅长创建和管理子智能体"
        "当用户有文件查看需求时，你可以s使用工具来处理该需求"
    )
}

func testSubagent() {
    let agent = ParentAgent()
    let response = agent.asyncChat(AgentRequest("请扮演一个文件助手，帮助用户查看文件。你可以创建一个子智能体来处理文件查看需求。总结 ./a.txt"))
    ConsolePrinter.print(response)
}