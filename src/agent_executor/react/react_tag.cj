/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

protected interface ReactTag { }

protected const THOUGHT_TAG = "[Thought]"
const ACTION_TAG = "[Action]"
const OBSERVATION_TAG = "[Observation]"
const ANSWER_TAG = "[Final Answer]"
protected const INFO_TAG = "[INFO]" // Not in react
protected const PLAN_TAG = "[PLAN]" // Not in react
let ALL_TAGS = [THOUGHT_TAG, ACTION_TAG, OBSERVATION_TAG, ANSWER_TAG, INFO_TAG, PLAN_TAG]

private func getTagSymbol(tag: String): (String, String) {
    if (tag.startsWith("[")) {
        return ("[", "]")
    } else if (tag.startsWith("<")) {
        return ("<", ">")
    }
    throw Exception("Invalid tag symbol `${tag}`")
}

/**
 * Add auxiliary methods to wrap strings with react tags.
 */
extend String <: ReactTag {
    func getCloseTag(): String {
        if (this.startsWith("[") && this.endsWith("]")) {
            return "[/${this[1..this.size-1]}]"
        }
        throw Exception("Invalid tag name `${this}`")
    }

    public func withTag(tag: String): String {
        let (left, right) = getTagSymbol(tag)

        let tagName = if (tag.startsWith(left) && tag.endsWith(right)) {
            tag[1..tag.size-1]
        } else {
            throw Exception("Invalid tag name `${tag}`")
        }

        return "${left}${tagName}${right} ${this} ${left}/${tagName}${right}"
    }
}
