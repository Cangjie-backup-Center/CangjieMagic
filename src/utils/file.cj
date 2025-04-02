/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

import std.fs.{File, Path, Directory, FileInfo}
import std.io.{StringWriter, IOException}
import std.collection.*
@When[cjc_version >= "0.56.4"]
public import std.fs.{exists, removeIfExists, canonicalize}
@When[cjc_version >= "0.56.4"]
public import std.io.readToEnd
@When[cjc_version >= "0.56.4"]
public import std.fs.OpenOption

/**
 * Save the content to a temp file and return its path.
 */
protected func saveTempFile(tempDir: String, content: String): Path {
    if (!exists(tempDir)) {
        Directory.create(tempDir, recursive: true)
    }
    let tempFile = File.createTemp(tempDir)
    let writer = StringWriter(tempFile)
    writer.write(content)
    writer.flush()
    tempFile.close()
    return tempFile.info.path
}

@When[cjc_version < "0.56.4"]
protected func readToEnd(file: File): Array<Byte> {
    return file.readToEnd()
}

@When[cjc_version < "0.56.4"]
protected func exists(path: String): Bool {
    return File.exists(path) || Directory.exists(path)
}

@When[cjc_version < "0.56.4"]
protected func exists(path: Path): Bool {
    return File.exists(path) || Directory.exists(path)
}

@When[cjc_version < "0.56.4"]
protected func removeIfExists(path: Path): Unit {
    if (File.exists(path)) {
        File.delete(path)
    } else if (Directory.exists(path)) {
        Directory.delete(path)
    }
}

@When[cjc_version < "0.56.4"]
protected func removeIfExists(path: String): Unit {
    return removeIfExists(Path(path))
}

@When[cjc_version < "0.56.4"]
protected func fileNameWithoutExt(path: Path): String {
    return path.fileNameWithoutExtension ?? ""
}

@When[cjc_version >= "0.56.4"]
protected func fileNameWithoutExt(path: Path): String {
    return path.fileNameWithoutExtension
}

@When[cjc_version < "0.56.4"]
protected func fileExt(path: Path): String {
    return path.extensionName ?? ""
}

@When[cjc_version >= "0.56.4"]
protected func fileExt(path: Path): String {
    return path.extensionName
}

@When[cjc_version < "0.56.4"]
protected func isRegularFile(fileInfo: FileInfo): Bool {
    return fileInfo.isFile()
}

@When[cjc_version >= "0.56.4"]
protected func isRegularFile(fileInfo: FileInfo): Bool {
    return fileInfo.isRegular()
}

@When[cjc_version < "0.56.4"]
protected func canonicalize(path: Path): Path {
    return path.toCanonical()
}

@When[cjc_version < "0.56.4"]
protected func directoryOf(path: Path): Path {
    return path.directoryName ?? Path("")
}

@When[cjc_version >= "0.56.4"]
protected func directoryOf(path: Path): Path {
    return path.parent
}

protected func readLines(path: Path): Array<String> {
    let file = File(path, OpenOption.Open(true, false))
    try {
        let bytes = readToEnd(file)
        let content = String.fromUtf8(bytes)
        let lines = content.split('\n')
        return collectArray<String>(lines |> map({line: String => line.trimAscii()}))
    } finally {
        file.close()
    }
}

protected func writeLines(path: Path, lines: Array<String>): Unit {
    try (file = File(path, OpenOption.Append)) {
        for (line in lines) {
            file.write("${line}\n".toArray())
        }
    }
}

protected func readFile(path: Path): Array<Byte> {
    try (file = File(path, OpenOption.Open(true, false))) {
        return readToEnd(file)
    }
    throw IOException("File ${path} dos not exists")
}