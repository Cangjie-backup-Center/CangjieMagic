/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.log.LogUtils
import magic.utils.{StringExt}

/**
 * Parsing a sequence of tagged content
 * Each tagged content is of form [tag] ... [/tag]
 * ATTENTION: the tag name must be of less than 20 letters!
 */
protected class TagStreamParser {
    private static const MAX_TAG_NAME_SIZE = 20

    protected TagStreamParser(
        /**
         * Data chunks of the tag sequence
        */
        private let chunks: Iterator<String>,
        /**
        * Callback function used to print internal messages
        */
        protected var onChunkFn!: Option<(String) -> Unit> = None
    ) { }

    private var finished = false

    /**
     * Save content has been read
     */
    private let buffer = StringBuilder()

    /**
     * Read a chunk to the buffer
     */
    private func readChunk(trimAscii!: Bool = false): Bool {
        if (let Some(data) <- this.chunks.next()) {
            let chunk = if (trimAscii) {
                data.trimAscii()
            } else {
                data
            }
            buffer.append(chunk)
            if (let Some(fn) <- this.onChunkFn) {
                fn(chunk)
            }
            return true
        }
        return false
    }

    /**
     * Read all chunks to the buffer
     */
    private func readAllChunk(): Unit {
        for (chunk in this.chunks) {
            buffer.append(chunk)
        }
    }

    protected func resetBuffer(content: String): Unit {
        this.buffer.reset()
        this.buffer.append(content)
    }

    protected prop currContent: String {
        get() {
            buffer.toString()
        }
    }

    protected prop currTag: Option<String> {
        get() {
            while (this.currContent.trimAscii().size < Tag.longestTag.size) {
                // When read tags, trim whitespaces because the LLM may generate [\nTAG\n]
                if (!this.readChunk(trimAscii: true)) { break }
            }
            // Check whether the current content starts with a tag
            let content = this.currContent.trimAscii()
            for (tag in Tag.ALL_TAGS) {
                if (content.startsWith(tag)) {
                    return tag
                }
            }
            if (!content.isEmpty()) {
                throw ParserException("Fail to peek tag. Invalid content: `${this.currContent}`")
            }
            return None
        }
    }

    protected func readTagAndContent(tag: String): String {
        let closeTag = tag.getCloseTag()
        while (true) {
            let content = this.currContent.trimAscii()
            // If the current content contains the close tag, split it as two parts
            if (let Some(index) <- content.lastIndexOf(closeTag)) {
                let pivot = index + closeTag.size
                let (tagWithContent, rest) = (content[0..pivot], content[pivot..])
                // Save the part after the close tag
                this.resetBuffer(rest)
                return tagWithContent
            } else {
                // If the current content does not contain the close tag, continue to read chunks
                if (!this.readChunk()) { break }
            }
        }
        throw ParserException("Fail to parse tag ${tag}")
    }

    protected func removeTag(tag: String): Unit {
        let content = this.currContent
        let pivot = content.indexOf(tag).getOrThrow()
        this.resetBuffer(content[(pivot + tag.size)..].trimAsciiLeft())
    }

    /**
     * Return part content and whether the close tag is read
     */
    protected func readContentUntilClosed(tag: String): Option<(String, Bool)> {
        if (finished) {
            if (this.readChunk()) {
                LogUtils.debug("Tag stream is finished but the stream is not finished")
            }
            return None
        }
        let closeTag = tag.getCloseTag()
        // Read a chunk
        let exhausted = !this.readChunk()
        let (content, rest) = this.splitByCloseTag(closeTag)
        if (exhausted) {
            // When the stream is over, the close tag must exist
            // The answer tag is special, the LLM may not generate its close tag
            if (!rest.trimAscii().startsWith(closeTag) && tag != Tag.ANSWER) {
                throw ParserException("Fail to read async react ${tag} content. Rest: `${rest}`")
            }
            if (rest.trimAscii().size == closeTag.size || tag == Tag.ANSWER) {
                finished = true
                this.resetBuffer("")
            } else {
                this.resetBuffer(rest[(rest.indexOf(closeTag).getOrThrow() + closeTag.size)..])
            }
            return (content.trimAsciiRight(), true)
        } else {
            // If the rest starts with the complete close tag, remove it
            if (rest.trimAscii().startsWith(closeTag)) {
                this.resetBuffer(rest[(rest.indexOf(closeTag).getOrThrow() + closeTag.size)..])
                return (content.trimAsciiRight(), true)
            } else {
                this.resetBuffer(rest)
                return (content, false)
            }
        }
    }

    private func splitByCloseTag(closeTag: String): (String, String) {
        let content = this.currContent
        // The current content contains the full close tag
        if (let Some(pivot) <- content.indexOf(closeTag)) {
            return (content[0..pivot], content[pivot..])
        }
        // Or check whether it ends with a prefix of the close tag
        for (index in closeTag.size..1 : -1) {
            let prefix = closeTag[0..index]
            if (content.trimAscii().endsWith(prefix)) {
                let pivot = content.lastIndexOf(prefix).getOrThrow()
                return (content[0..pivot], content[pivot..])
            }
        }
        return (content, "")
    }
}
