/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.rag

import magic.core.rag.RAGException
import magic.utils.{fileExt, exists}

import std.collection.{map, collectArrayList, collectArray}
import std.fs.Path

enum RAGSource {
    | Sqlite(String)              // Path to Sqlite DB
    | SqliteTable(String, String) // Path to Sqlite DB, table name
    | Markdown(String)            // Path to markdown file
}

func parseRAGSource(source: String): RAGSource {
    let items = source.split(":") |> map { item: String => item.trimAscii() } |> collectArrayList
    if (items.isEmpty()) {
        throw RAGException("Invalid rag source")
    }
    let path = items[0]
    if (!exists(path)) {
        throw RAGException("File ${path} does not exist")
    }
    match (fileExt(Path(path))) {
        case "md" | "markdown" => return RAGSource.Markdown(path)
        case "db" | "sqlite" =>
            if (items.size == 1) {
                return RAGSource.Sqlite(path)
            } else if (items.size == 2) {
                let table = items[1]
                return RAGSource.SqliteTable(path, table)
            } else {
                throw RAGException("Invalid rag source for Sqlite `${source}`")
            }
        case _ => throw RAGException("Invalid rag source `${source}`")
    }
}
