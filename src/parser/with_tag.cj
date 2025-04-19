/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

protected interface WithTag { }

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
