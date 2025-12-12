/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.mcp_server

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.mcp.ArkUIMCPServer
import magic.ui.arkui.*
import magic.ui.html.*


// @tool[
//     description: "以纯文本为核心内容的列表，每个列表项是一段文字，比如步骤说明列表",
//     terminal: true,
//     kind: "display",
//     parameters: {
//         info: "列表展示信息"
//     }
// ]
// public func textListUI(info: TextInfo): String {
//     template_text_list(info)
// }

// @tool[
//     description: "单选列表，用户只能从预设选项中选择唯一一项，适用于需要用户在互斥选项中做出唯一选择的场景（如性别、支付方式、学历等）",
//     parameters: {
//         info: "选项列表"
//     },
//     kind: "input",
//     terminal: true
// ]
// public func radioListUI(info: TextInfo): String {
//     // if (info.arr.size <= 5) {
//         return template_radio_list(info)
//     // } else {
//     //     return template_drop_list(info)
//     // }
// }


main() {
    Config.logLevel = "TRACE"
    Config.logFile = "./logs/mcp-server.log"
//    println("--------------UIMCPServer----------------")
//    let info = ArrayList<Position>()
//    let pos1 = Position(name:"青浦森林公园", distance:"5.5", price:'30', openTime:"全天", rating:'4.5', description:"ddfasadfafd", tags:['自然', 'afdfda', 'fads'])
//    let pos2 = Position(name:"dfas园", distance:"5.5", price:'30', openTime:"全天", rating:'4.5', description:"ddfasadfafd", tags:['自然', 'afdfda', 'fads'])
//    info.add(pos1)
//    info.add(pos2)
//    let a = recommend_scenices(info.toArray())
//    println(a)
    // UIMCPServer.startWith([textListUI, radioListUI], "0.0.0.0", 8000)
}