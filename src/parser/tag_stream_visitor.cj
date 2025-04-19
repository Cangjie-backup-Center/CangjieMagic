/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.utils.{Color, Colorful}

/**
 * Visitor of a tag stream
 */
public abstract class TagStreamVisitor {
    private let parser: TagStreamParser

    public init(chunks: Iterator<String>) {
        this.parser = TagStreamParser(chunks)
    }

    protected func onTag(tag: String): Unit

    protected func onCloseTag(tag: String): Unit

    protected func onChunk(chunk: String): Unit

    private var _currTag: String = ""
    protected prop currTag: String {
        get() {
            this._currTag
        }
    }

    public func start(): Unit {
        while (let Some(tag) <- this.parser.currTag) {
            _currTag = tag
            this.onTag(tag)
            this.parser.removeTag(tag)
            while (let Some((content, isClosed)) <- this.parser.readPartContentBefore(tag)) {
                this.onChunk(content)
                if (isClosed) { break }
            }
            this.onCloseTag(tag)
        }
    }
}
