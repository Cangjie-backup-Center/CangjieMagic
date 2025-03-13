/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.rag.splitter

import magic.core.rag.Document

import std.collection.LinkedList
import std.collection.ArrayList

public class CharacterTextSplitter <: Splitter {
    public CharacterTextSplitter(
        private let separator!: String = "\n\n",
        private let chunkSize!: Int64 = 1024,
        private let chunkOverlap!: Int64 = 1024
    ) {
        if (chunkOverlap > chunkSize) {
            throw Exception("Chunk overlap must be less than or equal to chunk size")
        }
    }

    override public func split(text: String): Array<Document> {
        if (text.isEmpty()) {
            return []
        }
        if (text.size < this.chunkSize) {
            return [Document(text)]
        }
        let res: Iterator<String> = text.lazySplit(this.separator, this.chunkSize)
        return mergeSplit(res)
    }

    private func mergeSplit(splits: Iterator<String>): Array<Document> {
        let separatorSize = this.separator.size
        let chunks = ArrayList<Document>()

        let currChunk: LinkedList<String> = LinkedList()
        var total = 0
        for (i in splits) {
            let len = i.size
            var separatorSizeToAdd = 0
            if (currChunk.size > 0) {
                separatorSizeToAdd = separatorSize
            }
            if (total + len + separatorSizeToAdd > this.chunkSize) {
                if (total > this.chunkSize) {
                    // TODO: warning
                }
                let chunk = String.join(currChunk.toArray(), delimiter: this.separator).trimAscii()
                if (!chunk.isEmpty()) {
                    chunks.append(Document(chunk))
                }

                while ((total > this.chunkOverlap) || ((total + len + separatorSizeToAdd) > this.chunkSize && total > 0)) {
                    let firstChunk = currChunk.popFirst()
                    separatorSizeToAdd = 0
                    if (currChunk.size > 0) {
                        separatorSizeToAdd = separatorSize
                    }
                    match (firstChunk) {
                        case Some(value) => total -= value.size + separatorSizeToAdd
                        case None => break
                    }
                }
            }
            currChunk.append(i)
            total += len + separatorSizeToAdd
        }
        let chunk = String.join(currChunk.toArray(), delimiter: this.separator).trimAscii()
        if (!chunk.isEmpty()) {
            chunks.append(Document(chunk))
        }
        return chunks.toArray()
    }
}
