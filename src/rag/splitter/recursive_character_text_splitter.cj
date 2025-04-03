package magic.rag.splitter

import magic.core.rag.Document
import std.collection.*

public class RecursiveCharacterTextSplitter <: AbsCharacterSplitter {
    private let _separators: Array<String>
    private let _keep_separator: Bool

    public init(separators!: Array<String> = ["\n\n", "\n", " ", ""], chunkSize!: Int64 = 1024,
        chunkOverlap!: Int64 = 256, keepSeparator!: Bool = false) {
        super(chunkSize, chunkOverlap)
        this._separators = separators
        this._keep_separator = keepSeparator
    }

    public override func split(text: String): Array<Document> {
        if (text.isEmpty()) {
            return []
        }
        var separators = ArrayList<String>(_separators)
        let chunks = recursiveSplit(text, separators)
        return collectArray(chunks |> map({chunk => Document(chunk)}))
    }

    private func recursiveSplit(text: String, separators: ArrayList<String>): ArrayList<String> {
        var separator = ""
        let finalChunks = ArrayList<String>()
        var newSeparators = ArrayList<String>()
        for ((i, _s) in enumerate(separators)) {
            separator = _s
            if (_s == "") {
                separator = _s
                break
            }
            if (text.contains(_s)) {
                separator = _s
                newSeparators = separators[(i + 1)..separators.size]
                break
            }
        }
        let _separator = separator
        let splits = collectArray(
            text.lazySplit(separator, removeEmpty: true) |> filter {line => line.trimAscii().size > 0} |> map(
            {
            line => if (this._keep_separator) {
                "${line}${_separator}"
            } else {
                line
            }
        }))
        if (this._keep_separator) {
            separator = ""
        }
        var validSplits = ArrayList<String>()
        for (s in splits) {
            if (textSize(s) <= this._chunk_size) {
                validSplits.append(s)
            } else {
                if (!validSplits.isEmpty()) {
                    let meregedChunks = mergeSplit(validSplits.iterator(), separator)
                    finalChunks.appendAll(meregedChunks)
                    validSplits.clear()
                }
                if (newSeparators.isEmpty()) {
                    finalChunks.append(s)
                } else {
                    finalChunks.appendAll(recursiveSplit(s, newSeparators))
                }
            }
        }
        if (!validSplits.isEmpty()) {
            let mergedChunks = mergeSplit(validSplits.iterator(), separator)
            finalChunks.appendAll(mergedChunks)
        }
        finalChunks
    }
}
