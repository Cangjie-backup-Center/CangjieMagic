/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.message.{Message, MessageList}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.{StringExt, sleep2}
import magic.parser.{Tag, TagStreamParser}

import std.collection.{ArrayList, map, collectArray}

class AsyncReactAnswer <: Iterator<String> {
    private var finished = false

    AsyncReactAnswer(
        let parser: TagStreamParser
    ) {
        if ((this.parser.currTag ?? "") != Tag.ANSWER) {
            throw AgentExecutionException("Invalid async react ${Tag.ANSWER}. Content: ${this.parser.currContent}")
        }
        // Remove the prefix of tag
        this.parser.removeTag(Tag.ANSWER)
    }

    override public func next(): Option<String> {
        if (finished) {
            return None
        }
        if (let Some((content, _isClosed)) <- this.parser.readContentUntilClosed(Tag.ANSWER)) {
            finished = _isClosed
            return content
        }
        return None
    }
}

class AsyncReactStep {
    AsyncReactStep(
        let parser: TagStreamParser
    ) { }

    // Each react step has [Thought], so we parse thoughts and save them
    private let thoughts = ArrayList<String>()

    private func readThoughts(): Unit {
        while (let Some(tag) <- this.parser.currTag) {
            if (tag == Tag.THOUGHT) {
                thoughts.append(this.parser.readTagAndContent(Tag.THOUGHT))
            } else if (tag == Tag.ACTION || tag == Tag.ANSWER) {
                break
            } else {
                throw AgentExecutionException("Invalid react tag `${tag}`")
            }
        }
    }

   func peekTag(): String {
        this.readThoughts()
        // If there are no tags, this step is a single [Thought]
        if (let Some(tag) <- this.parser.currTag) {
            return tag
        } else {
            return Tag.THOUGHT
        }
    }

    func getStepOf(tag: String): ReactStep {
        try {
            let thought = String.join(this.thoughts.toArray(), delimiter: "\n")
            let action = if (tag == Tag.THOUGHT) {
                ""
            } else if (tag == Tag.ACTION) {
                this.parser.readTagAndContent(Tag.ACTION)
            } else {
                throw AgentExecutionException("Unreachable")
            }
            let content = "${thought}\n${action}"
            LogUtils.info("React action content: ${content}")
            return ReactStep.fromStr(content)
        } catch (ex: Exception) {
            return ReactStep.Failure(
                FailureInfo(
                    FailureLevel.Fatal,
                    message: "",
                    reason: ex.toString(),
                    suggestion: ""
                )
            )
        }
    }

    func getAsyncAnswer(): (String, AsyncReactAnswer) {
        let thought = String.join(this.thoughts.toArray(), delimiter: "\n")
        (thought, AsyncReactAnswer(this.parser))
    }
}
