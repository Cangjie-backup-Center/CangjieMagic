/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.parser.*
import magic.core.agent.AsyncAgentResponse
import magic.utils.{Color, Colorful}

import std.console.Console

/**
 * Dumper the verbose react internal information for debugging
 */
public class ConsolePrinter <: TagStreamVisitor {
    public init(chunks: Iterator<String>) {
        super(chunks)
    }

    public init(asyncResponse: AsyncAgentResponse) {
        super(asyncResponse.execution.verboseInfo)
    }

    private func getTagColor(tag: String): Color {
        if (tag == Tag.PLAN) {
            return Color.Red
        } else if (tag == Tag.INFO) {
            return Color.Green
        } else {
            return Color.Blue
        }
    }

    override protected func onTag(tag: String): Unit {
        if (tag == Tag.THOUGHT || tag == Tag.ACTION ||
            tag == Tag.OBSERVATION || tag == Tag.INFO || tag == Tag.PLAN) {
            let tagColor = getTagColor(tag)
            Console.stdOut.writeln(tag.withColor(tagColor))
        }
    }

    override protected func onCloseTag(tag: String): Unit {
        let tagColor = getTagColor(tag)
        if (tag == Tag.INFO) {
            Console.stdOut.writeln(tag.getCloseTag().withColor(tagColor))
            Console.stdOut.writeln("---------------------------------")
        } else if (tag == Tag.ANSWER) {
            Console.stdOut.writeln("...")
        } else {
            Console.stdOut.writeln(tag.getCloseTag().withColor(tagColor))
        }
    }

    protected func onChunk(chunk: String): Unit {
        if (this.currTag != Tag.ANSWER) {
            Console.stdOut.write(chunk)
        }
    }

    public func dump(): Unit {
        this.start()
    }

    public static func print(asyncResponse: AsyncAgentResponse, verbose!: Bool = false): Unit {
        if (verbose) {
            let dumper = ConsolePrinter(asyncResponse)
            dumper.dump()
        }
        for (data in asyncResponse) {
            Console.stdOut.write(data)
        }
        Console.stdOut.write("\n")
    }
}
