/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter
import magic.agent_executor.naive.NaiveExecutor
import magic.compactor.SimpleConversationCompactor

import std.time.*

@jsonable
struct MyDate {
    let year: String
    let month: String
}

private let data = """
Kobe Bean Bryant (/ˈkoʊbi/ KOH-bee; August 23, 1978 – January 26, 2020) was an American professional basketball player. A shooting guard, he spent his entire 20-year career with the Los Angeles Lakers in the National Basketball Association (NBA). Widely regarded as one of the greatest and most influential basketball players of all time, Bryant won five NBA championships and was an 18-time All-Star, four-time All-Star MVP, 15-time member of the All-NBA Team, 12-time member of the All-Defensive Team, the 2008 NBA Most Valuable Player (MVP), two-time NBA Finals MVP, and two-time scoring champion. He ranks fourth in league all-time regular season and postseason scoring. Bryant was posthumously named to the NBA 75th Anniversary Team in 2021 and was inducted to the Naismith Memorial Basketball Hall of Fame twice, first in 2020 as an NBA player, and again in 2025 as a member of the 2008 U.S. Olympic team.[3]

The son of NBA player Joe Bryant, Bryant was born in Philadelphia and partly raised in Italy. Recognized as the top American high school basketball player while at Lower Merion High School in the Philadelphia suburb of Ardmore, Bryant declared for the 1996 NBA draft and was selected by the Charlotte Hornets with the 13th pick; he was then traded to the Lakers. As a rookie, Bryant earned a reputation as a high-flyer by winning the 1997 Slam Dunk Contest and was named an All-Star by his second season. Despite his contentious relationship with teammate Shaquille O'Neal, the pair led the Lakers to three consecutive NBA championships from 2000 to 2002. In 2003, Bryant was charged with sexual assault. Charges were dropped after the accuser refused to testify, and a lawsuit was settled out of court, with Bryant issuing an apology and admitting to a sexual encounter he maintained was consensual.

After the Lakers lost the 2004 NBA Finals, O'Neal was traded and Bryant became the franchise's cornerstone. He led the NBA in scoring in the 2005–06 and 2006–07 seasons. On January 22, 2006, Bryant scored a career-high 81 points, the second most scored in a single NBA game behind Wilt Chamberlain's 100-point game. Bryant led the team to championships in 2009 and 2010, and was named NBA Finals MVP both times. He continued to be among the league's premier players through the 2012–13 season when he suffered a torn achilles tendon. The last years of his playing career were hampered by injuries and limited playing time. Bryant retired after the 2015–16 season, capping off his illustrious career with a 60-point performance in his final NBA game, leading the Lakers to a comeback victory over the Utah Jazz. In 2017, the Lakers retired both his Nos. 8 and 24, making Bryant the only player in NBA history to have multiple numbers retired by the same franchise.

The all-time leading scorer in Lakers history, Bryant was the first guard in NBA history to play 20 seasons. His 18 All-Star designations are the third most ever, and his four NBA All-Star Game MVP Awards are tied with Bob Pettit for the most in history. Bryant gave himself the nickname Black Mamba in the mid-2000s, and the epithet became widely adopted by the public. He won gold medals on the 2008 and 2012 U.S. Olympic teams. In 2018, Bryant won the Academy Award for Best Animated Short Film for Dear Basketball (2017).[4]

In January 2020, Bryant and his 13-year-old daughter Gianna were among nine people who died in a helicopter crash in Calabasas, California.[5] A number of tributes and memorials followed, and the All-Star Game MVP Award was renamed in Bryant's honor.[6]
"""

@toolset
class MyToolset {
    @tool[description: "获取当前时间"]
    func getCurrentTime(): String {
        DateTime.now().toString()
    }

    @tool[description: "获取当前日期"]
    func getCurrentDate(): String {
        DateTime.now().toString()
    }

    @tool[description: "记录日期到本地", compactable: true]
    func saveDate(year: Int64, month: Int64): String {
        // println("Saving date: ${date.toJsonValue().toJsonString()}")
        // return "Saved date: ${date.year}-${date.month}"
        ""
    }

    @tool[
        description: "web search",
        compactable: true
    ]
    func webSearch(keyword: String): String {
        return data
    }
}

@agent[
    // model: "ark:kimi-k2-250711",
    model: "ark:deepseek-v3-250324",
    executor: "react",
    tools:[MyToolset()]
]
class AbcAgent {
}

@jsonable
struct HelloAnswer {
    let date: MyDate
    let name: String
    let age: Int64
}

func testConversation(): Unit {
    let agent = ConversationAgent(AbcAgent())
    var answer = agent.chatGet<HelloAnswer>("刘德华的个人信息你了解吗？").getOrThrow()
    println(answer.toJsonValue().toJsonString())

    answer = agent.chatGet<HelloAnswer>("现在几点啦").getOrThrow()
    println(answer.toJsonValue().toJsonString())

    let answer2 = agent.asyncChat(AgentRequest("Search content about Kobe, and read detailed results", verbose: true))
    // let answer2 = agent.asyncChat(AgentRequest("how to use cangjie magic to handle conversation", verbose: true))
    ConsolePrinter.print(answer2, verbose: true)

    println(agent.conversation.compactBy(SimpleConversationCompactor(agent.model)))

    println(agent.chat("刘德华的出生日期"))
    return ()
}