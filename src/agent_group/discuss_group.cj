/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_group

internal import magic.core.model.*
internal import magic.core.agent.*
internal import magic.prompt.Template
internal import magic.log.LogUtils
internal import magic.parser.OutputParserUtils
internal import magic.core.message.{ChatMessage, ChatMessageRole, Dialog}

import std.collection.ArrayList

const DISCUSSION_MAX_ROUND = 14

private let AGENT_SPEAK_PROMPT = """
You are an agent, named as {name}, involved in a discussion.

The topic/question is: {topic}

The following is the discussion content.
The discussion is split as speeches, and each speech is wrapped by the pair of [Speech] and [/Speech].
----- Begin of discussion -----
{discussion}
----- End of discussion -----

Now, it's your turn to speak.
Wrap the output with ```speech and ```. For example, ```speech An apple a day, keeps doctor away.```
"""

/**
 * The type of speaker selection
 */
enum Selection {
    | Speaker(Agent)
    | Summary(String)
    | Failure(String)
}

abstract class DiscussGroup {
    let name = "FreeGroup Host"
    let topic: String
    let members: ArrayList<Agent>
    let model: ChatModel
    let discussion = Dialog()
    var currSpeakerIndex = 0

    public init(topic: String, members: ArrayList<Agent>) {
        this.topic = topic
        this.members = members
        model = members[0].model // Set the chat model of the first member
    }

    public func discuss(initiator: String, speech: String, maxRound!: Int64): AgentResponse {
        if (let Some(idx) <- findAgent(initiator)) {
            discussion.addMessage(ChatMessage.assistant(speech, name: members[idx].name))
            currSpeakerIndex = idx + 1 // For round robin, we should adjust the index
        } else {
            throw AgentExecutionException("Initiator agent is not existed.")
        }
        return discuss(maxRound: maxRound)
    }

    public func discuss(maxRound!: Int64): AgentResponse {
        LogUtils.info(this.name, "FreeGroup Host run")
        for (round in 0..maxRound) {
            LogUtils.info(this.name, "Round ${round}")
            let speaker: Agent = match (selectSpeaker()) {
                case Speaker(agent) =>
                    LogUtils.info(this.name, "Select the next speaker: ${agent.name}")
                    agent
                case Summary(result) =>
                    return AgentResponse(result)
                case Failure(reason) =>
                    throw AgentExecutionException("Host failed to select the next agent. Reason: ${reason}")
            }
            let speech = match (makeSpeech(speaker)) {
                case Some(s) => s
                case None =>
                    throw AgentExecutionException("The speaker agent failed to make speech")
            }
            LogUtils.info(this.name, "The speaker says: ${speech}")
            discussion.addMessage(ChatMessage.assistant(speech, name: speaker.name))
            // LogUtils.info(this.name, assistantMsg)
        }
        throw AgentExecutionException("Exceed the max discussion round")
    }

    public func selectSpeaker(): Selection

    private func makeSpeech(speaker: Agent): Option<String> {
        let question = buildSpeakPrompt(speaker.name)
        let result = speaker.chat(AgentRequest(question)).content
        return OutputParserUtils.extractLastCode(result, "speech")
    }

    func buildDiscussionPrompt(): String {
        let strBuilder = StringBuilder()
        for (msg in discussion) {
            strBuilder.append("[Speech] ${msg.name} says: ${msg.content} [/Speech]\n")
        }
        return strBuilder.toString()
    }

    private func buildSpeakPrompt(speakerName: String): String {
        return AGENT_SPEAK_PROMPT.format(
            ("name", speakerName),
            ("topic", topic),
            ("discussion", buildDiscussionPrompt())
        )
    }

    func findAgent(name: String): Option<Int64> {
        for (i in 0..members.size) {
            if (members[i].name == name) {
                return Some(i)
            }
        }
        return None
    }
}
