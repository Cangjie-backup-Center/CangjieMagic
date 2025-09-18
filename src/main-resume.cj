/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter
import magic.agent_executor.naive.NaiveExecutor

import std.console.*

/**
 * Interface for abstracting user interaction
 */
interface UserInteraction {
    /**
     * Display a message to the user and get input from the user
     */
    func interact(info: String): String
}

class ConsoleInteraction <: UserInteraction {
    override public func interact(prompt: String): String {
        Console.stdOut.write("> ")
        Console.stdOut.writeln(prompt)
        return Console.stdIn.readln().getOrThrow()
    }

    public static func startInteract(agent: Agent): Unit {
        let interaction = ConsoleInteraction()
        while (true) {
            let input = interaction.interact("有什么可以帮助您的？")
            if (input == "q" || input == "quit") {
                return
            }
            let asyncResp = agent.asyncChat(AgentRequest(input, verbose: true))
            if (agent.executor is NaiveExecutor) {
                for (chunk in asyncResp) {
                    Console.stdOut.write(chunk)
                }
                Console.stdOut.write("\n")
            } else {
                ConsolePrinter.print(asyncResp, verbose: true)
            }
        }
    }
}

// const MODEL_TO_USE = "ark:deepseek-v3-250324"
const MODEL_TO_USE = "siliconflow:deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
@agent[
    model: "${MODEL_TO_USE}",
    executor: "naive"
]
class ResumeMaker {
    @prompt(
        "你正在求职中，需要向公司投递简历"
        "根据个人信息，使用 HTML 制作一份精美的简历。"
        "一定要遵从个人信息制作简历，不能随意编写虚假得信息，这是及其重要得要求"
        "在保持信息正确得前提下，在简历中对个人信息做一个完整的展示，丰富简历"
        "注意你的输出将直接被公司接收，所以仅包含 html 内容，不需要输出任何不想管出内容"
    )
}

@agent[
    model: "${MODEL_TO_USE}",
    executor: "react",
]
class ResumeAgent {
    ResumeAgent(private let interaction: UserInteraction) { }

    @prompt(
        """
        你正在帮助一位求职者制作简历，你需要完成的任务是收集他的个人信息来后续制作简历。
        首先，你需要考虑好哪些信息是制作简历需要的，然后决定当前的个人信息是否充足。
        如果有缺失的信息，询问求职者。
        收集信息的过程不要着急，一步一步和求职者交互，引导他给出各种信息来完成简历制作。
        一下子让别人填写信息是不友好得交互方式，
        例如，询问求职者“请问您的电话号码或电子邮件地址是什么？”，这里让他一步填写两种信息并不友好，
        你可以分为两步，逐一让求职者完成填写。
        你绝对不能自己假设求职者的个人信息，这是非常严重的错误。
        最后把求职者的个人信息输出，但你不需要制作简历，这不是你的任务。
        """
    )

    @tool[description: "向用户输出提示消息，并接收用户输入"]
    func interact(prompt: String): String {
        return this.interaction.interact(prompt)
    }
}

func buildResumeAgent(): Agent {
    return GroupAsAgent(
        ResumeAgent(ConsoleInteraction()) |> ResumeMaker(),
        description: "和用户交互，收集用户个人信息并生成简历"
    )
}

func testResume() {
    let ag = buildResumeAgent()
    ConsolePrinter.print(ag.asyncChat(AgentRequest("帮我制作一份简历")))
    return ()
}