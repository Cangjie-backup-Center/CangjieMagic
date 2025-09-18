/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.utils.http.HttpUtils
import magic.config.Config

@jsonable
struct Invoice {
    let vendor: String
    let number: String
    // let date: DateTime
}

@ai[
    model: "ark:deepseek-v3-250324"
    // model: "google:gemini-2.0-flash"
]
foreign func extractInvoice(email: String): Invoice

let fakeEmail = """
Hey Alex,

Just wanted to follow up on our call earlier and confirm that I’ve sent over the updated project timeline. I’ve also just attached the invoice (#VT-2024-0428) for this month’s retainer—let me know if you spot any discrepancies.

Quick Details:

Vendor: Vertex Tech
Invoice #: VT-2024-0428
Date: March 5, 2024
Due: March 20, 2024
Otherwise, we’re on track for the demo next Thursday—I’ll share the agenda by EOD Friday. Also, any thoughts on the design revisions we discussed?

Keep me posted!

Cheers,

David
"""

@tool[
    description: "Fetches the theml content of a URL."
]
func fetch(url: String): String {
    let header = HashMap<String, String>([
        ("User-Agent", "CangjieMagic/1.0")
    ])
    return HttpUtils.get(url, header, None) ?? "Nothing"
}

@ai[
    // model: "google:gemini-2.5-pro",
    model: "ark:deepseek-v3-250324",
    prompt: "不超过 3 个关键字",
    tools: [fetch]
]
foreign func keywordsOf(url: String): Array<String>

@ai[
    // model: "google:gemini-2.5-flash"
    model: "ark:deepseek-v3-250324"
]
foreign func translate(text: String, targetLang: String): String

func testAI() {
    // Config.defaultChatModel = ModelManager.createChatModel("ark:deepseek-v3-250324")
    // Config.defaultChatModel = ModelManager.createChatModel("google:gemini-2.0-flash")

    let url = "https://docs.cangjie-lang.cn/docs/0.53.18/white_paper/source_zh_cn/cj-wp-abstract.html"
    println(keywordsOf(url))
    // model: "ark:doubao-seed-1-6-250615",

    println(translate("你好，Cangjie Magic！", "en"))
}