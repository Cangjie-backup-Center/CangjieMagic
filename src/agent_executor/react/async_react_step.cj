/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.agent.AgentTask
import magic.core.message.{ChatMessage, Dialog}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.{StringExt, sleep2}

import std.collection.{ArrayList, map, collectArray}

class AsyncReactFinalAnswer <: Iterator<String> {
    AsyncReactFinalAnswer(
        let reader: AsyncReactStepReader
    ) {
        if ((this.reader.currTag ?? "") != ReactTag.ANSWER) {
            throw AgentExecutionException("Invalid async react final answer. Content: ${this.reader.currContent}")
        }
        // Remove the prefix of tag
        this.reader.removeTag(ReactTag.ANSWER)
    }

    override public func next(): Option<String> {
        if (let Some((content, _isClosed)) <- this.reader.readPartContentBefore(ReactTag.ANSWER)) {
            return content
        }
        return None
    }
}

class AsyncReactStep {
    AsyncReactStep(
        let reader: AsyncReactStepReader
    ) { }

    // Each react step has [Thought], so we parse thoughts and save them
    private let thoughts = ArrayList<String>()

    private func readThoughts(): Unit {
        while (let Some(tag) <- this.reader.currTag) {
            if (tag == ReactTag.THOUGHT) {
                thoughts.append(this.reader.readTagAndContent(ReactTag.THOUGHT))
            } else if (tag == ReactTag.ACTION || tag == ReactTag.ANSWER) {
                break
            } else {
                throw AgentExecutionException("Invalid react tag `${tag}`")
            }
        }
    }

   func peekTag(): String {
        this.readThoughts()
        // If there are no tags, this step is a single [Thought]
        if (let Some(tag) <- this.reader.currTag) {
            return tag
        } else {
            return ReactTag.THOUGHT
        }
    }

    func getStepOf(tag: String): ReactStep {
        try {
            let thought = String.join(this.thoughts.toArray(), delimiter: "\n")
            let action = if (tag == ReactTag.THOUGHT) {
                ""
            } else if (tag == ReactTag.ACTION) {
                this.reader.readTagAndContent(ReactTag.ACTION)
            } else {
                throw AgentExecutionException("Unreachable")
            }
            let content = "${thought}\n${action}"
            LogUtils.info("React action content: ${content}")
            return ReactStep.fromStr(content)
        } catch (_: Exception) {
            return ReactStep.Failure(
                FailureInfo(
                    FailureLevel.Fatal,
                    message: "",
                    reason: "Fail to get chat model response",
                    suggestion: ""
                )
            )
        }
    }

    func getAsyncFinalAnswer(): (String, AsyncReactFinalAnswer) {
        let thought = String.join(this.thoughts.toArray(), delimiter: "\n")
        (thought, AsyncReactFinalAnswer(this.reader))
    }
}
