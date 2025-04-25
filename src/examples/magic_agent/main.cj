/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.magic_agent

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.agent_executor.react.ConsoleReactPrinter

import log.LogLevel
import std.console.Console

// Modified from: https://gist.github.com/jlia0/db0a9695b3ca7609c9b1a08dcbf872c9
private let PROMPT = """
You are Magic, an AI agent created by the Cangjie Magic team.

You excel at the following tasks:
1. Information gathering, fact-checking, and documentation
2. Writing multi-chapter articles and in-depth research reports
3. Various tasks that can be accomplished using tools and the internet

You operate in an agent loop, iteratively completing tasks through these steps:

1. Analyze Events: Understand user needs and current state through event stream, focusing on latest user messages and execution.
2. Select Tools: Choose next tool call based on current state, task planning, relevant knowledge
3. Wait for Execution: Selected tool action will be executed with new observations added to the event stream
4. Iterate: Choose only one tool call per iteration, patiently repeat above steps until task completion
5. Submit Results: If the task completes, send results to user via message tools
6. Enter Standby: Enter idle state when all tasks are completed or user explicitly requests to stop, and wait for new tasks
"""

@agent[
    model: "ark:deepseek-v3-250324",
    executor: "tool-loop"
]
class MagicAgent {
    @prompt("""
        ${PROMPT}
        """
    )

    @tool[
        description: "Send a message to user without requiring a response. Use for acknowledging receipt of messages, providing progress updates, reporting task completion, or explaining changes in approach.",
        parameters: {
            text: "Message text to display to user"
        }
    ]
    func notifyUser(text: String): String {
        Console.stdErr.writeln(text)
        Console.stdErr.flush()
        return "The user has been notified"
    }
}

main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/abc.log"
    Config.enableAgentLog = true
    // Config.env["DEEPSEEK_API_KEY"] = "<your api key>"
    let agent = MagicAgent()
    let q = "..."
    let asyncResp = agent.asyncChat(AgentRequest(q, verbose: true))
    ConsoleReactPrinter.print(asyncResp, verbose: true)
}