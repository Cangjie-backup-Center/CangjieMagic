/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.agent.AsyncAgentResponse
import magic.utils.{Color, Colorful}
import std.console.Console

/**
 * Dumper the verbose react internal information for debugging
 */
public class ReactDumper {
    private let reader: AsyncReactStepReader

    public init(chunks: Iterator<String>) {
        this.reader = AsyncReactStepReader(chunks)
    }

    public init(asyncResponse: AsyncAgentResponse) {
        this.reader = AsyncReactStepReader(
            asyncResponse.execInfo.getOrThrow().verboseInfo
        )
    }

    private func getTagColor(tag: String): Color {
        if (tag == PLAN_TAG) {
            return Color.Red
        } else if (tag == INFO_TAG) {
            return Color.Green
        } else {
            return Color.Blue
        }
    }

    public func dump(): Unit {
        while (let Some(tag) <- this.reader.currTag) {
            if (tag == THOUGHT_TAG || tag == ACTION_TAG ||
                tag == OBSERVATION_TAG || tag == INFO_TAG || tag == PLAN_TAG) {
                let tagColor = getTagColor(tag)
                Console.stdOut.writeln(tag.withColor(tagColor))
                this.reader.removeTag(tag)
                while (let Some((content, isClosed)) <- this.reader.readPartContentBefore(tag)) {
                    Console.stdOut.write(content)
                    if (isClosed) { break }
                }
                Console.stdOut.write("\n")
                Console.stdOut.writeln(tag.getCloseTag().withColor(tagColor))
                if (tag == INFO_TAG) {
                    Console.stdOut.writeln("---------------------------------")
                }
            } else if (tag == ANSWER_TAG) {
                // ANSWER_TAG is redundant
                this.reader.removeTag(tag)
                while (let Some((content, isClosed)) <- this.reader.readPartContentBefore(tag)) {
                    if (isClosed) { break }
                }
                Console.stdOut.writeln("...")
            } else {
                throw Exception("Unreachable")
            }
        }
    }
}
