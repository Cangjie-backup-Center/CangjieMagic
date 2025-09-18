/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter
import magic.agent_executor.naive.NaiveExecutor

@tool[
    description: "This function takes a list of strings and displays each item in the list",
    parameters: {
        items: "A list containing strings to be displayed"
    },
    terminal: true
]
public func displayListItems(items: Array<String>): String {
    if (items.size <= 4) {
        return "Simple List UI: ${items}"
    } else {
        return "Scrolled List UI for more than 4 items: ${items}"
    }
}

@agent[
    model: "siliconflow:Pro/deepseek-ai/DeepSeek-V3",
    tools: [
        displayListItems
    ],
]
class UIGenerator {
    @prompt(
        """
        You are an assistant that interacts with users using predefined functions.
        Given a question or prompt, you must select the appropriate function call to display information or collect user input.

        Examples:

        Input: "Clarify which city you would like to go"
        Output:
        ```json
        {
            "name": "displayListItems",
            "arguments": {
                "items": ["上海", "北京", "其他"]
            }
        }
        ```

        Input: "What is your budget?"
        Output:
        ```json
        {
            "name": "displayListItems",
            "arguments": {
                "items": ["100-300", "300-500", "500-1000", "1000以上"]
            }
        }
        ```
        """
    )
}

@tool[
    description: "Ask the user to get his/her input to clarify the question or provide more details. When using this tool, make sure each call focuses on either one clarifying question or one piece of information at a time. AVOID overwhelming the user with dense questions or information in a single call, as this is unfriendly to users",
    parameters: {
        prompt: "The question or prompt to ask/show the user"
    }
    filterable: false,
    terminal: true
]
private func askUser2(prompt: String): String {
    let agent = UIGenerator()
    let html = agent.chat(prompt)
    println(html)
    return html
}

@agent[
    // model: "ark:deepseek-v3-250324",
    model: "siliconflow:Pro/deepseek-ai/DeepSeek-V3",
    executor: "react",
    tools: [
        httpMCP("https://mcp.amap.com/sse?key=e52794430e9b4a2583dc3060236e2d37"),
        httpMCP("http://119.3.125.66:8080/sse"),
        httpMCP("http://119.3.125.66:80/sse"),
        askUser2
        // http("http://127.0.0.1:8080/sse")
    ]
]
class UIDemoAgent {
    @prompt("""
        在使用工具时：
        - 根据你的任务需求选择合适的工具。
        - 按照工具要求提供格式正确的参数。
        请遵循以下准则：
        - 按照工具模式中记录的要求，使用有效的参数调用工具。
        - 对于图片URL的回复，你在最终回答中要保持MarkDown的引用格式并且不可以修改URL中的字符。
        记住要向用户清晰地解释你的推理过程和操作步骤。
    """
    )
}

func testUI(): Unit {
    let agent = UIDemoAgent()
    // let q1 = "北京到深圳坐高铁有什么推荐"
    let q1 = "我想买衣服"
    // let q1 = "小明在上海青浦练秋湖华为研发中心，小红在上海东方明珠，两人想约会，找一个折中的位置，你能给推荐吗？"

    let asyncResp = agent.asyncChat(AgentRequest(q1, verbose: true))
    ConsolePrinter.print(
        asyncResp,
        verbose: true
    )
    return ()
}