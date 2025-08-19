/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser


protected interface WithTag {
    prop close: String
    func withTag(tag: String): String
    func withoutTag(tag: String): String
    func withoutTag(): String
}

/**
 * Add auxiliary methods to wrap strings with react tags.
 */
extend String <: WithTag {
    public prop close: String {
        get() {
            if (this.startsWith(OPEN_TAG_SYMBOL) && this.endsWith(CLOSE_TAG_SYMBOL)) {
                return "${OPEN_TAG_SYMBOL}/${this[1..this.size-1]}${CLOSE_TAG_SYMBOL}"
            }
            throw Exception("Invalid tag name `${this}`")
        }
    }

    /**
     * Wrap the string with the specified tag if necessary
     */
    public func withTag(tag: String): String {
        let closeTag = tag.close
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
        content = content.removeSuffix(tag.close)
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
