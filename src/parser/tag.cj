/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

protected struct Tag {
    protected static const THOUGHT = "[Thought]"

    protected static const ACTION = "[Action]"

    protected static const OBSERVATION = "[Observation]"

    protected static const ANSWER = "[Final Answer]"

    protected static const INFO = "[INFO]" // Not in react

    protected static const PLAN = "[PLAN]" // Not in react

    static let ALL_TAGS = [
        Tag.THOUGHT,
        Tag.ACTION,
        Tag.OBSERVATION,
        Tag.ANSWER,
        Tag.INFO,
        Tag.PLAN
    ]

    static prop longestTag: String {
        get() {
            var result = Tag.THOUGHT
            var maxLength = result.toString().size
            for (t in Tag.ALL_TAGS) {
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
            if (tag == Tag.ANSWER) {
                return str[contentStart..str.size].trimAscii()
            }
        }
        return None
    }
}

func getTagSymbol(tag: String): (String, String) {
    if (tag.startsWith("[")) {
        return ("[", "]")
    } else if (tag.startsWith("<")) {
        return ("<", ">")
    }
    throw Exception("Invalid tag symbol `${tag}`")
}

