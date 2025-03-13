/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.markdown_qa

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.model.ModelManager

import log.LogLevel

@agent[
    model: "deepseek:deepseek-chat",
    executor: "naive",
    rag: {
        source: "./docs/tutorial.md",
        mode: "static"
    }
]
class QABot {
    @prompt[pattern: ERA] (
        expectation: "代码块被标签 ```cangjie 和 ```包裹",
        role: "简单问答助手",
        action: "搜索文档获取知识并回答问题"
    )
}

main () {
    Config.logLevel = LogLevel.INFO
    Config.defaultEmbeddingModel = ModelManager.createEmbeddingModel("ollama:nomic-embed-text")

    let bot = QABot()
    let aresp = bot.asyncChat("Agent RAG 怎么编写")
    for (chunk in aresp) {
        print(chunk)
    }
    println("\n---end---")
    if (let Some(info) <- aresp.execInfo) {
        for (r in info.retrievalInfo) {
            for (doc in r.documents) {
                println(doc.metadata)
            }
        }
    }
}