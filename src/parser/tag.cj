/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import std.regex.Regex

const OPEN_TAG_SYMBOL = '<'

const CLOSE_TAG_SYMBOL = '>'

protected struct Tag {
    protected static let THOUGHT = "${OPEN_TAG_SYMBOL}thinking${CLOSE_TAG_SYMBOL}"

    protected static let ACTION = "${OPEN_TAG_SYMBOL}action${CLOSE_TAG_SYMBOL}"

    protected static let OBSERVATION = "${OPEN_TAG_SYMBOL}observation${CLOSE_TAG_SYMBOL}"

    protected static let ANSWER = "${OPEN_TAG_SYMBOL}answer${CLOSE_TAG_SYMBOL}"

    protected static let INFO = "${OPEN_TAG_SYMBOL}info${CLOSE_TAG_SYMBOL}" // Not in react

    protected static let PLAN = "${OPEN_TAG_SYMBOL}plan${CLOSE_TAG_SYMBOL}" // Not in react

    protected static let FAIL = "${OPEN_TAG_SYMBOL}fail${CLOSE_TAG_SYMBOL}" // Not in react

    static let ALL_TAGS = [
        Tag.THOUGHT,
        Tag.ACTION,
        Tag.OBSERVATION,
        Tag.ANSWER,
        Tag.INFO,
        Tag.PLAN,
        Tag.FAIL
    ]

    protected static func startsWith(str: String, tag: String): Bool {
        let tagName = tag[1..tag.size-1]
        let regex = Regex("^\\s*\\${OPEN_TAG_SYMBOL}\\s*${tagName}\\s*\\${CLOSE_TAG_SYMBOL}")
        return regex.find(str).isSome()
    }

    protected static func endsWith(str: String, tag: String): Bool {
        let tagName = tag[1..tag.size-1]
        let regex = Regex("\\${OPEN_TAG_SYMBOL}/\\s*${tagName}\\s*\\${CLOSE_TAG_SYMBOL}\\s*$")
        return regex.find(str).isSome()
    }

    protected static func trimTag(str: String, tag: String): String {
        let tagName = tag[1..tag.size-1]
        let regex = Regex("^\\s*\\${OPEN_TAG_SYMBOL}\\s*${tagName}\\s*\\${CLOSE_TAG_SYMBOL}")
        if (let Some(md) <- regex.find(str)) {
            let pos = md.matchPosition()
            return str[pos.end..]
        } else {
            return str
        }
    }

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
    protected static func extract(str: String, tag: String): Option<String> {
        if (let Some(start) <- str.lastIndexOf(tag)) {
            let contentStart = start + tag.size
            // Case 1: the tag is well-formed, i.e., it has both the open tag and close tag
            if (let Some(end) <- str.indexOf(tag.close, contentStart)) {
                return str[contentStart..end].trimAscii()
            }
            // Case 2: it only has the open tag and is followed by another tag
            for (anotherTag in Tag.ALL_TAGS) {
                if (let Some(end) <- str.indexOf(anotherTag.close, contentStart)) {
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
