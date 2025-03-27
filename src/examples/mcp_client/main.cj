/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.mcp_client

import magic.dsl.*
import magic.prelude.*
import magic.config.Config

import log.LogLevel

@agent[
    model: "deepseek:deepseek-chat",
    mcp: [
        { command: "cjpm", args: ["run", "--skip-build", "--name", "magic.examples.mcp_server.calculator"] }
    ]
]
class HomeworkAssistant {
    @prompt(
        "你能够协助小学生们完成家庭作业，让他们在各个学科均衡发展"
    )
}

main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/mcp-client.log"

    let agent = HomeworkAssistant()
    let result = agent.chat("23 + 24 等于多少")
    println(result)
}