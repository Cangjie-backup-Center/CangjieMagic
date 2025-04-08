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
        if (tag == ReactTag.PLAN) {
            return Color.Red
        } else if (tag == ReactTag.INFO) {
            return Color.Green
        } else {
            return Color.Blue
        }
    }

    public func dump(): Unit {
        while (let Some(tag) <- this.reader.currTag) {
            if (tag == ReactTag.THOUGHT || tag == ReactTag.ACTION ||
                tag == ReactTag.OBSERVATION || tag == ReactTag.INFO || tag == ReactTag.PLAN) {
                let tagColor = getTagColor(tag)
                Console.stdOut.writeln(tag.withColor(tagColor))
                this.reader.removeTag(tag)
                while (let Some((content, isClosed)) <- this.reader.readPartContentBefore(tag)) {
                    Console.stdOut.write(content)
                    if (isClosed) { break }
                }
                Console.stdOut.write("\n")
                Console.stdOut.writeln(tag.getCloseTag().withColor(tagColor))
                if (tag == ReactTag.INFO) {
                    Console.stdOut.writeln("---------------------------------")
                }
            } else if (tag == ReactTag.ANSWER) {
                // ReactTag.ANSWER is redundant
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

    public static func print(asyncResponse: AsyncAgentResponse, verbose!: Bool = false): Unit {
        if (verbose) {
            let dumper = ReactDumper(asyncResponse)
            dumper.dump()
        }
        for (data in asyncResponse) {
            Console.stdOut.write(data)
        }
        Console.stdOut.write("\n")
    }
}
