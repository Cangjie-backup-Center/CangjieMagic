/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.health_monitor

import magic.dsl.*
import magic.prelude.*
import std.time.DateTime

@tool[description: "获取当前时间"]
func getCurrentTime(): String {
    return DateTime.now().toString()
}

@tool[description: "向用户发送短信通知",
      parameters: {
          msg: "发送短信的内容"
      }
]
func sendNotification(msg: String): String {
    println(">>>>>> ${msg} <<<<<")
    return "Done"
}

@agent[model: "deepseek:deepseek-chat",
       tools: [getCurrentTime, sendNotification]]
class CgmAgent {
    @prompt(
        """
        检测用户当前血糖是否正常。回答“正常”或是“异常”
        检查结果可以结合当前所处的时间综合判断
        如果异常，则向用户发送通知并告知可实施的建议
        仅使用已有工具
        """
    )
}

//================================================
@agent[model: "deepseek:deepseek-chat",
       tools: [sendNotification]]
class HeartBeatAgent {
    @prompt(
        """
        检测用户当前心跳是否正常。回答“正常”或是“异常”
        如果异常，则向用户发送通知并告知可实施的建议
        仅使用已有工具
        """
    )
}
//================================================
@agent[model: "deepseek:deepseek-chat"]
class MonitorAgent {
    @prompt(
        """
        根据接受到的监测数据，交由不同的检测模块进行检测
        """
    )
}

main() {
    let cgmAgent = CgmAgent()
    let heartBeatAgent = HeartBeatAgent()
    let monitorAgent =  MonitorAgent()
    let group = monitorAgent <= [cgmAgent, heartBeatAgent]

    let resp = group.chat(AgentRequest("当前血糖 189 mg/dL"))
    println(resp.content)
}