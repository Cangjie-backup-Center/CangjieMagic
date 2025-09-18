/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.*
import magic.core.interaction.*

import std.env.getStdOut

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

// Modified from https://github.com/modelcontextprotocol/servers/blob/main/src/sequentialthinking/index.ts
const THINKING_TOOL_DESC = """
A detailed tool for dynamic and reflective problem-solving through thoughts.
This tool helps analyze problems through a flexible thinking process that can adapt and evolve.
Each thought can build on, question, or revise previous insights as understanding deepens.

When to use this tool:
- Breaking down complex problems into steps
- Planning and design with room for revision
- Analysis that might need course correction
- Problems where the full scope might not be clear initially
- Problems that require a multi-step solution
- Tasks that need to maintain context over multiple steps
- Situations where irrelevant information needs to be filtered out

Parameters explained:
- thought: Your current thinking step, which can include:
* Regular analytical steps
* Revisions of previous thoughts
* Questions about previous decisions
* Realizations about needing more analysis
* Changes in approach
* Hypothesis generation
* Hypothesis verification
"""

@tool[
    description: "Ask the user to get his/her input to clarify the question or provide more details.",
    terminal: true,
    filterable: false,
    parameters: {
        prompt: "The question or prompt to ask the user"
    }
]
private func askUser(prompt: String): String {
    return "I want to go to Beijing 一等座 HA 345 ￥600 元"
}

@tool[description: "Generate a image for the given topic. An URL will be returned"]
func genImage(topic: String): String { "http://a.b.c.com/url/foo-bar-image.jpg" }

@tool[description: ""]
func sendEmail(content: String): String { "The email has been sent" }


@agent[
    model: "ark:deepseek-v3-250324",
    // model: "siliconflow:Qwen/Qwen3-235B-A22B",
    // model: "siliconflow:Pro/deepseek-ai/DeepSeek-V3",
    // model: "ollama:gpt-oss:20b",
    // model: "ark:kimi-k2-250711",
    // executor: "tool-loop",
    executor: "react",
    enableToolFilter: true,
    tools: [
        httpMCP("https://mcp.amap.com/sse?key=e52794430e9b4a2583dc3060236e2d37")
        // http("http://119.3.125.66:8080/sse"),
        // http("http://119.3.125.66:80/sse"),
        // askUser, sendEmail
        // http("http://127.0.0.1:8080/sse")
    ]
]
class MagicAgent {
    @prompt("""
${PROMPT}
在使用工具时：
- 根据你的任务需求选择合适的工具。
- 按照工具要求提供格式正确的参数。
请遵循以下准则：
- 按照工具模式中记录的要求，使用有效的参数调用工具。
- 对于图片URL的回复，你在最终回答中要保持MarkDown的引用格式并且不可以修改URL中的字符。
记住要向用户清晰地解释你的推理过程和操作步骤。
"""
    )

    // @execution(
        // loop(action)
        // tool(askUser |> sendEmail) |> answer
        // switch(
        //     onCase("问题是询问天气", answer),
        //     onCase("问题是出行类问题", tool(askUser |> sendEmail) |> answer),
        //     otherwise(think |> answer)
        // )
        // divide |> each(think |> answer) |> summary |> answer
    // )

    @tool[
        description: "${THINKING_TOOL_DESC}",
        parameters: {
            thought: "Your current thinking content"
        },
        filterable: false
    ]
    func thinking(thought: String): String {
        // Console.stdErr.writeln(text)
        // Console.stdErr.flush()
        return "Good job! Continue to work"
    }
}

func testMagic(): Unit {
    let agent = MagicAgent()

    let manager = EventHandlerManager()
    manager.addHandler { evt: ToolCallStartEvent =>
        getStdOut().writeln("...${evt.toString()}...")
        EventResponse.Continue
    }
//     let q1 = """
// 我将要举办一个关于动物保护主题的宣讲。请你帮我搜索一些相关的新闻或活动，生成约200字的中文演讲稿。
// 同时我需要你帮我生成一张相关的漫画海报，以及一个跳转到活动官网https://animal.com的二维码。
// 最后把相关的内容全部发送到我的邮箱dongjie_cdj@163.com
// """
    // let q1 = "北京到深圳坐高铁有什么推荐"
    //result = agent.chat("这篇文献的主要内容是什么？https://arxiv.org/pdf/2401.08406")
    // let q1 = "我想购物"
    let q1 = "小明在上海青浦练秋湖华为研发中心，小红在上海东方明珠，两人想约会，找一个折中的位置，你能给推荐吗？"
    // let q1 = "我在杭州参加马拉松比赛（起点西湖断桥），家人想在沿途观赛点苏堤给我送补给，请规划每个补给点的最佳抵达时间和交通方式"
    // println(agent.chat(q1))
    // return ()

    // let resp = consolePrint(agent, request: AgentRequest(q1, verbose: true))
    // let asyncResp = agent.asyncChat(AgentRequest(q1, verbose: true))
    let asyncResp = _asyncInteract(agent, request: AgentRequest(q1, verbose: true), manager: manager)
    ConsolePrinter.print(
        asyncResp,
        verbose: true
    )
    return ()
}
