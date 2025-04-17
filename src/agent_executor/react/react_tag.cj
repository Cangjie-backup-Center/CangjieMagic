/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

protected struct ReactTag {
    protected static const THOUGHT = "[Thought]"

    protected static const ACTION = "[Action]"

    protected static const OBSERVATION = "[Observation]"

    protected static const ANSWER = "[Final Answer]"

    protected static const INFO = "[INFO]" // Not in react

    protected static const PLAN = "[PLAN]" // Not in react

    static let ALL_TAGS = [
        ReactTag.THOUGHT,
        ReactTag.ACTION,
        ReactTag.OBSERVATION,
        ReactTag.ANSWER,
        ReactTag.INFO,
        ReactTag.PLAN
    ]

    static prop longestTag: String {
        get() {
            var result = ReactTag.THOUGHT
            var maxLength = result.toString().size
            for (t in ReactTag.ALL_TAGS) {
                let l = t.toString().size
                if (l > maxLength) {
                    maxLength = l
                    result = t
                }
            }
            return result
        }
    }

    public static func extract(str: String, tag: String): Option<String> {
        if (let Some(start) <- str.lastIndexOf(tag)) {
            let contentStart = start + tag.size
            if (let Some(end) <- str.indexOf(tag.getCloseTag(), contentStart)) {
                return str[contentStart..end].trimAscii()
            }
            // Special treatment for the answer tag
            // because LLM is prone to generate the final answer without a close tag
            if (tag == ReactTag.ANSWER) {
                return str[contentStart..str.size].trimAscii()
            }
        }
        return None
    }
}

private func getTagSymbol(tag: String): (String, String) {
    if (tag.startsWith("[")) {
        return ("[", "]")
    } else if (tag.startsWith("<")) {
        return ("<", ">")
    }
    throw Exception("Invalid tag symbol `${tag}`")
}

protected interface WithTag { }

/**
 * Add auxiliary methods to wrap strings with react tags.
 */
extend String <: WithTag {
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
