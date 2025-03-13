/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.rag.splitter

import magic.core.rag.Document

import std.fs.{File, OpenOption}
import std.io.StringReader
import std.collection.{ArrayList, HashMap}

public class DocumentLoader {
    public DocumentLoader(
        private let filePath: String
    ) { }

    public func load(): Array<Document> {
        try (file = File(this.filePath, OpenOption.Open(true, false))) {
            let reader = StringReader(file)
            let content = reader.readToEnd()

            let metadata = HashMap<String, String>([("source", filePath)])
            return [ Document(content, metadata: metadata) ]
        }
        throw UnsupportedException()
    }

    public func loadSplit(splitter: Splitter): Array<Document> {
        let allDocs = ArrayList<Document>()
        for (doc in this.load()) {
            allDocs.appendAll(
                splitter.split(doc.content)
            )
        }
        return allDocs.toArray()
    }
}
