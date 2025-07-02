/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

import std.fs.{File, Path, Directory, FileInfo}

@When[cjc_version >= "1.0.0"]
import std.fs.OpenMode

import std.collection.*
@When[cjc_version >= "1.0.0"]
public import std.fs.{exists, removeIfExists, canonicalize, rename}
@When[cjc_version >= "1.0.0"]
public import std.io.readToEnd

import std.io.{StringReader, StringWriter, IOException}

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

@When[cjc_version < "1.0.0"]
protected func readToEnd(file: File): Array<Byte> {
    return file.readToEnd()
}

@When[cjc_version < "1.0.0"]
protected func exists(path: String): Bool {
    return File.exists(path) || Directory.exists(path)
}

@When[cjc_version < "1.0.0"]
protected func exists(path: Path): Bool {
    return File.exists(path) || Directory.exists(path)
}

@When[cjc_version < "1.0.0"]
protected func removeIfExists(path: Path): Unit {
    if (File.exists(path)) {
        File.delete(path)
    } else if (Directory.exists(path)) {
        Directory.delete(path)
    }
}

@When[cjc_version < "1.0.0"]
protected func removeIfExists(path: String): Unit {
    removeIfExists(Path(path))
}

@When[cjc_version < "1.0.0"]
protected func fileNameWithoutExt(path: Path): String {
    return path.fileNameWithoutExtension ?? ""
}

@When[cjc_version >= "1.0.0"]
protected func fileNameWithoutExt(path: Path): String {
    return path.fileNameWithoutExtension
}

@When[cjc_version < "1.0.0"]
protected func fileExt(path: Path): String {
    return path.extensionName ?? ""
}

@When[cjc_version >= "1.0.0"]
protected func fileExt(path: Path): String {
    return path.extensionName
}

@When[cjc_version < "1.0.0"]
protected func isRegularFile(fileInfo: FileInfo): Bool {
    return fileInfo.isFile()
}

@When[cjc_version >= "1.0.0"]
protected func isRegularFile(fileInfo: FileInfo): Bool {
    return fileInfo.isRegular()
}

@When[cjc_version < "1.0.0"]
protected func canonicalize(path: Path): Path {
    return path.toCanonical()
}

@When[cjc_version < "1.0.0"]
protected func directoryOf(path: Path): Path {
    return path.directoryName ?? Path("")
}

@When[cjc_version >= "1.0.0"]
protected func directoryOf(path: Path): Path {
    return path.parent
}

@When[cjc_version < "1.0.0"]
protected func move(source: Path, to: Path, overwrite: Bool): Unit {
    if (source.isFile()) {
        File.move(source, to, overwrite)
    } else if (source.isDirectory()) {
        Directory.move(source, to, overwrite)
    }
}

@When[cjc_version >= "1.0.0"]
protected func move(source: Path, to: Path, overwrite: Bool): Unit {
    rename(source, to: to, overwrite: overwrite)
}

protected func readFile(path: Path): String {
    try (file = File(path, OpenMode.Read)) {
        let reader = StringReader(file)
        return reader.readToEnd()
    }
    throw UnsupportedException()
}

protected func writeFile(path: Path, content: String): Unit {
    try (file = File(path, OpenMode.Write)) {
        let writer = StringWriter(file)
        writer.write(content)
        writer.flush()
    }
}

protected func readLines(path: Path): Array<String> {
    let content = readFile(path)
    let lines = content.split('\n')
    return lines |> map { line: String => line.trimAscii() } |> collectArray
}

protected func writeLines(path: Path, lines: Array<String>): Unit {
    try (file = File(path, OpenMode.Append)) {
        for (line in lines) {
            file.write("${line}\n".toArray())
        }
    }
}