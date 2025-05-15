/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.common

import magic.core.agent.Agent
import magic.parser.{Tag, WithTag}
import magic.log.LogUtils

protected class IteratorWrapper <: Iterator<String> {
    protected IteratorWrapper(
        private let agent: Agent,
        private let workerFut: Future<Iterator<String>>
    ) { }

    /**
     * Concatenate all response content and log it finally
     */
    private let buffer = StringBuilder()

    override public func next(): Option<String> {
        let asyncAnswer = workerFut.get()
        let data = asyncAnswer.next()
        match (data) {
            case Some(v) => buffer.append(v)
            case None =>
                LogUtils.info(this.agent.name, buffer.toString().withTag(Tag.ANSWER))
        }
        return data
    }
}