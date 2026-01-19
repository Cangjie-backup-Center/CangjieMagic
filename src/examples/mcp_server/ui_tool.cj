/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.mcp_server

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.mcp.ArkUIMCPServer
import magic.ui.arkui.*
// import magic.ui.html.*
import magic.ui.*

@tool[
    description: "饼图，展示数据占比",
    terminal: true,
    kind: "display",
    parameters: {
        info: "展示信息"
    }
]
public func pieCharttUI(info: PieChartInfo): String {
    template_pie_chart(info)
}

@tool[
    description: "以纯文本为核心内容的列表，每个列表项是一段文字，比如步骤说明列表",
    terminal: true,
    kind: "display",
    parameters: {
        info: "列表展示信息"
    }
]
public func textListUI(info: TextInfo): String {
    template_text_list(info)
}

@tool[
    description: "单选列表，用户只能从预设选项中选择唯一一项，适用于需要用户在互斥选项中做出唯一选择的场景（如性别、支付方式、学历等）",
    parameters: {
        info: "选项列表"
    },
    terminal: true
]
public func radioListUI(info: TextInfo): String {
    // if (info.arr.size <= 5) {
        return template_radio_list(info)
    // } else {
    //     return template_drop_list(info)
    // }
}


main() {
    Config.logLevel = "TRACE"
    Config.logFile = "./logs/mcp-server.log"
    println("--------------UIMCPServer----------------")
    ArkUIMCPServer.startWith([textListUI, pieCharttUI], "0.0.0.0", 8000)
    // HTMLUIMCPServer.startWith([textListUI, commonResume], "0.0.0.0", 8000)
}