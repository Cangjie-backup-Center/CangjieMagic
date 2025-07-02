/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic.examples.doc_generator

import std.fs.{File, OpenOption, Directory, Path}
import std.io.{StringReader, StringWriter}

func readFile(path: Path): String {
    try (file = File(path, OpenOption.Open(true, false))) {
        let reader = StringReader(file)
        return reader.readToEnd()
    }
    throw UnsupportedException()
}

func readFile(path: String): String {
    return readFile(Path(path))
}

func writeFile(path: Path, content: String): Unit {
    let outfile: File = File(path, OpenOption.CreateOrTruncate(false))
    let writer = StringWriter(outfile)
    writer.write(content)
    writer.flush()
    outfile.close()
}