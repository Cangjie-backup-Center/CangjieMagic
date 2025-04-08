/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_group

import magic.core.message.Dialog
import magic.model.ModelUtils
import magic.log.LogUtils

import std.collection.ArrayList

private let RR_SPEAKER_SELECT_PROMPT = """
There are agents collaborate to solve questions, i.e., the topic.
They solve the problem by discussion.
The discussion can be divided as multiple rounds. During each round, there is an agent to speak.
You should decide whether the question has been solved according to existed discussion.
If so, return the final answer.

## Topic
The topic is: {topic}

## Discussion
The discussion is split as speeches, and each speech is wrapped by the pair of [Speech] and [/Speech].
The following is the discussion content.
{discussion}

## Output Format
1. If the problem is solved, the output should be formatted as [Answer] ... [/Answer]
2. Otherwise, output NO-ANSWER
"""

class RoundRobinDiscussGroup <: DiscussGroup {
    init(topic!: String, members!: ArrayList<Agent>) {
        super(topic, members)
    }

    private func buildSelectSystemPrompt(): String {
        return RR_SPEAKER_SELECT_PROMPT.format(
            ("topic", topic),
            ("discussion", buildDiscussionPrompt())
        )
    }

    override public func selectSpeaker(): Selection {
        let sysPrompt = buildSelectSystemPrompt()
        let dialog = Dialog([
            ChatMessage.system(sysPrompt)
        ])
        LogUtils.info(this.name, sysPrompt)
        for (msg in discussion) {
            dialog.addMessage(ChatMessage.assistant("${msg.name} says: ${msg.content}"))
        }
        dialog.addMessage(
            ChatMessage.user("Select the next speaker now")
        )

        let msg = match (ModelUtils.makeChat(this.model, dialog)) {
            case Some(msg) => msg
            case None => return Selection.Failure("LLM model failed")
        }
        LogUtils.info(this.name, msg)
        if (let Some(answer) <- OutputParserUtils.extractLastSection(msg.content, "[Answer]")) {
            return Selection.Summary(answer)
        } else {
            let selection = Selection.Speaker(members[currSpeakerIndex % members.size])
            currSpeakerIndex += 1
            return selection
        }
    }
}