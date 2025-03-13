package magic.rag.splitter

import magic.core.rag.Document

public interface Splitter {
    func split(text: String): Array<Document>
}