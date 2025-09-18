/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.utils.http.HttpUtils
import magic.config.Config
import magic.interaction.ConsolePrinter

@agent[
    // model: "deepseek:deepseek-chat",
    // model: "ark:deepseek-v3-250324",
    // model: "maas:deepseek-v3-32k",
    model: "siliconflow:Qwen/Qwen2.5-VL-72B-Instruct",
    // model: "ollama:deepseek-r1:14b",
    executor: "naive"
]
class ImageDetector {
}

func testImage() {
    // Config.defaultChatModel = ModelManager.createChatModel("ark:deepseek-v3-250324")
    // let url = "https://csdnimg.cn/release/devpress-cangjie/public/img/app-0.5fabc29c.png"
    let url = "https://i-blog.csdnimg.cn/devpress/blog/dbace040b8974a8c9d87b6999025fc99.png"
    let agent = ImageDetector()
    let response = agent.asyncChat(AgentRequest("简要总结图片里的内容为 markdown", image: url))
    ConsolePrinter.print(response)
    println(response.content)
}