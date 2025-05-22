/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.utils.StringExt

protected interface WithTag { }

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
extend String <: WithTag {
    public func getCloseTag(): String {
        if (this.startsWith("[") && this.endsWith("]")) {
            return "[/${this[1..this.size-1]}]"
        }
        throw Exception("Invalid tag name `${this}`")
    }

    /**
     * Wrap the string with the specified tag if necessary
     */
    public func withTag(tag: String): String {
        let closeTag = tag.getCloseTag()
        let content = this.trimAscii()
        if (!content.startsWith(tag)) {
            return "${tag} ${content} ${closeTag}"
        } else {
            if (content.endsWith(closeTag)) {
                return content
            } else {
                return "${content} ${closeTag}"
            }
        }
    }

    /**
     * Remove the specified tag from the string if necessary
     */
    public func withoutTag(tag: String): String {
        var content = this.trimAscii()
        content = content.removePrefix(tag)
        content = content.removeSuffix(tag.getCloseTag())
        return content.trimAscii()
    }

    public func withoutTag(): String {
        var content = this.trimAscii()
        for (tag in Tag.ALL_TAGS) {
            if (content.startsWith(tag)) {
                return content.withoutTag(tag)
            }
        }
        return this
    }
}
