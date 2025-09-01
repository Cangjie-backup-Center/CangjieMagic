/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.parser.{ParserUtils, ParserException}
import magic.core.tool.ToolRequest
import magic.log.LogUtils
import magic.parser.{WithTag, Tag}

protected enum FailureLevel {
    | Repairable
    | Fatal
}

protected struct ToolCall {
    protected ToolCall(
        protected let thought!: String,              // Thoughts of choosing the tool
        protected let requests!: Array<ToolRequest>, // Tool call request
        protected let text!: String                  // The original tool call representation
    ) { }
}

protected struct FinalAnswer {
    protected FinalAnswer(
        protected let thought!: String, // Thoughts of summarizing the answer
        protected let content!: String   // Content of the answer
    ) { }
}

protected struct FailureInfo {
    protected FailureInfo(
        protected let level: FailureLevel,
        protected let message!: String, // The original failure message
        protected let reason!: String,
        protected let suggestion!: String
    ) { }
}

protected enum ReactStep <: Hashable & Equatable<ReactStep> & ToString {
    | Action(ToolCall)
    | Thought(String)
    | Answer(FinalAnswer)
    | Failure(FailureInfo)

    public func hashCode(): Int64 {
        return match (this) {
            case ReactStep.Action(tc) => tc.text.hashCode()
            case ReactStep.Thought(t) => t.hashCode()
            case ReactStep.Answer(a) => a.content.hashCode()
            case ReactStep.Failure(f) => f.reason.hashCode()
        }
    }

    public operator func ==(rhs: ReactStep): Bool {
        match ((this, rhs)) {
            case (ReactStep.Action(tc1), ReactStep.Action(tc2)) =>
                return tc1.text == tc2.text
            case (ReactStep.Thought(t1), ReactStep.Thought(t2)) =>
                return t1 == t2
            case (ReactStep.Answer(a1), ReactStep.Answer(a2)) =>
                return a1.content == a2.content
            case (ReactStep.Failure(f1), ReactStep.Failure(f2)) =>
                return f1.reason == f2.reason
            case _ => return false
        }
    }

    public operator func !=(rhs: ReactStep): Bool {
        return !(this == rhs)
    }

    public func toString(): String {
        return match (this) {
            case ReactStep.Action(tc) => "${Tag.THOUGHT} ${tc.thought} ${Tag.THOUGHT.close}; ${Tag.ACTION} ${tc.text} ${Tag.ACTION.close}"
            case ReactStep.Thought(t) => "${Tag.THOUGHT} ${t} ${Tag.THOUGHT.close}"
            case ReactStep.Answer(a) => "${Tag.THOUGHT} ${a.thought} ${Tag.THOUGHT.close}; ${Tag.ANSWER} ${a.content} ${Tag.ANSWER.close}"
            case ReactStep.Failure(f) => "${Tag.FAIL} Original message: ${f.message}; \n Reason: ${f.reason} ${Tag.FAIL.close}"
        }
    }

    static func fromStr(content: String): ReactStep {
        let thought = Tag.extract(content, Tag.THOUGHT)
        if (let Some(answer) <- Tag.extract(content, Tag.ANSWER)) {
            return ReactStep.Answer(
                FinalAnswer(thought: thought ?? "",
                            content: answer)
            )
        }
        match ((thought, Tag.extract(content, Tag.ACTION))) {
            case (_, Some(action)) =>
                try {
                    return ReactStep.Action(
                        ToolCall(
                            text: action,
                            thought: thought ?? "",
                            requests: ParserUtils.extractToolRequestArray(action)
                        )
                    )
                } catch (ex: ParserException) {
                    LogUtils.error("Parsing action failed: ${ex.reason}")
                    return ReactStep.Failure(
                        FailureInfo(FailureLevel.Repairable,
                                    message: content,
                                    reason: ex.reason,
                                    suggestion: "You should regenerate to fix the error: `${ex.reason}`")
                    )
                }
            case (Some(_thought), None) =>
                return ReactStep.Thought(_thought)
            case (None, None) =>
                return ReactStep.Failure(
                    FailureInfo(
                        FailureLevel.Repairable,
                        message: content,
                        reason: "Output format is invalid.",
                        suggestion: "You should generate ${Tag.ACTION} or ${Tag.ANSWER}"
                    )
                )
        }
    }
}