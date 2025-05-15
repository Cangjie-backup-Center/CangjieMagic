/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

protected struct Tag {
    protected static const THOUGHT = "[Thought]"

    protected static const ACTION = "[Action]"

    protected static const OBSERVATION = "[Observation]"

    protected static const ANSWER = "[Answer]"

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
            var result = Tag.ALL_TAGS[0]
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

    /**
     * Extract tagged content from a string which is generate by LLMs
     */
    public static func extract(str: String, tag: String): Option<String> {
        if (let Some(start) <- str.lastIndexOf(tag)) {
            let contentStart = start + tag.size
            // Case 1: the tag is well-formed, i.e., it has both the open tag and close tag
            if (let Some(end) <- str.indexOf(tag.getCloseTag(), contentStart)) {
                return str[contentStart..end].trimAscii()
            }
            // Case 2: it only has the open tag and is followed by another tag
            for (anotherTag in Tag.ALL_TAGS) {
                if (let Some(end) <- str.indexOf(anotherTag.getCloseTag(), contentStart)) {
                    return str[contentStart..end].trimAscii()
                }
            }
            // Case 3: it only has the open tag
            // LLMs are prone to generate output without a close tag
            return str[contentStart..str.size].trimAscii()
        }
        return None
    }
}
