/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.agent.AgentTask
import magic.core.message.{ChatMessage, Dialog}
import magic.log.LogUtils
import magic.model.ModelUtils
import magic.utils.{StringExt, sleep2}

import std.collection.{ArrayList, map, collectArray}

/**
 * Wrap the async chat response as a chunk stream of a react step
 */
class AsyncReactStepReader {
    var enableVerbose = false

    AsyncReactStepReader(
        private let chunks: Iterator<String>,
        /**
        * Callback function used to print internal messages
        */
        private let verboseFn!: Option<(String)->Unit> = None
    ) { }

    private var finished = false

    /**
     * Save content has been read
     */
    private let buffer = StringBuilder()

    /**
     * Read a chunk to the buffer
     */
    private func readChunk(): Bool {
        if (let Some(chunk) <- this.chunks.next()) {
            buffer.append(chunk)
            if (enableVerbose) {
                if (let Some(fn) <- this.verboseFn) {
                    fn(chunk)
                }
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

    func resetBuffer(content: String): Unit {
        this.buffer.reset()
        this.buffer.append(content)
    }

    prop currContent: String {
        get() {
            buffer.toString()
        }
    }

    prop currTag: Option<String> {
        get() {
            // The tag with the max length is [Final Answer]
            while (this.currContent.trimAscii().size < ANSWER_TAG.size) {
                if (!this.readChunk()) { break }
            }
            // Check whether the current content starts with a tag
            let content = this.currContent.trimAscii()
            for (tag in [THOUGHT_TAG, ACTION_TAG, OBSERVATION_TAG, ANSWER_TAG]) {
                if (content.startsWith(tag)) {
                    return tag
                }
            }
            if (!content.isEmpty()) {
                throw AgentExecutionException("React content has unparsed parts `${this.currContent}`")
            }
            return None
        }
    }

    func readTagAndContent(tag: String): String {
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
        throw AgentExecutionException("Fail to parse react ${tag}")
    }

    func removeTag(tag: String): Unit {
        this.readChunk() // Read one more chunk to trim empty spaces
        let content = this.currContent
        let pivot = content.indexOf(tag).getOrThrow()
        this.resetBuffer(content[(pivot + tag.size)..].trimAsciiLeft())
    }

    /**
     * Return part content and whether the close tag is read
     */
    func readPartContentBefore(tag: String): Option<(String, Bool)> {
        if (finished) {
            if (this.readChunk()) {
                LogUtils.debug("Async react step is finished but the chat stream is not finished")
            }
            return None
        }
        let closeTag = tag.getCloseTag()
        // Read a chunk
        let exhausted = !this.readChunk()
        let (content, rest) = this.splitByCloseTag(closeTag)
        if (exhausted) {
            // When the full content is read, the close tag must exist
            // ANSWER_TAG is special, the LLM may not generate its close tag
            if (rest.trimAscii() != closeTag && tag != ANSWER_TAG) {
                throw AgentExecutionException("Fail to read async react ${tag} content. Rest: `${rest}`")
            } else {
                finished = true
                return (content.trimAsciiRight(), true)
            }
        } else {
            // If the rest starts with the full close tag, remove it
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
