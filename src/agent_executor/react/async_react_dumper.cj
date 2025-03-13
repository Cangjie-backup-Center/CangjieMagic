/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.utils.{StringExt, Color}

/**
 * Dumper the verbose react internal information for debugging
 */
public class ReactDumper {
    private let reader: AsyncReactStepReader

    public init(chunks: Iterator<String>) {
        this.reader = AsyncReactStepReader(chunks)
    }

    public func dump(): Unit {
        while (let Some(tag) <- this.reader.currTag) {
            if (tag == THOUGHT_TAG || tag == ACTION_TAG || tag == OBSERVATION_TAG) {
                println(tag.withColor(Color.Blue))
                this.reader.removeTag(tag)
                while (let Some((content, isClosed)) <- this.reader.readPartContentBefore(tag)) {
                    print(content)
                    if (isClosed) { break }
                }
                println()
            } else if (tag == ANSWER_TAG) {
                return
            } else {
                throw Exception("Unreachable")
            }
        }
    }
}
