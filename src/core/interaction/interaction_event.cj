/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.interaction

import std.deriving.*

@Derive[Equatable, ToString]
protected enum EventKind {
    | ToolCall
    | PromptValidate
    | AnswerValidate
    | ChatModelFailure
    | Timeout
    | UserInput
    | Notify
    | Sentinel
}

public open class InteractionEvent <: ToString {
    protected InteractionEvent(
        protected let kind: EventKind
    ) { }

    open override public func toString(): String {
        return this.kind.toString()
    }
}
