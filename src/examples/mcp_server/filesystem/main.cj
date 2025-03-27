/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.examples.mcp_server.filesystem

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import magic.mcp.MCPServer

import std.collection.ArrayList
import std.fs.{Directory, Path, File, FSException, OpenOption}
import std.io.StringReader
@When[cjc_version < "0.56.4"]
import std.os.process.Process
//--------------------------------------------------------
@When[cjc_version >= "0.56.4"]
import std.process.Process

import log.LogLevel

var ALLOWED_DIR = ""

func checkPath(path: String): (Bool, String) {
    let p = Path(path)
    if (!p.isAbsolute()) {
        return (false, "${path} is not an absolute path")
    }
    if (!path.startsWith(ALLOWED_DIR)) {
        return (false, "${path} is not allowed")
    }
    return (true, "")
}

@tool[description: "Get the allowed directory"]
func getAllowedDir(): String {
    if (ALLOWED_DIR.isEmpty()) {
        return "No allowed directory"
    } else {
        return ALLOWED_DIR
    }
}

//---------------------------------------------------------------------

@tool[
    description: "List all files and subdirectories in a directory",
    parameters: {
        path: "Absolute path of the directory to list"
    }
]
func listDir(path: String): String {
    let (status, msg) = checkPath(path)
    if (!status) { return msg }
    let result = ArrayList<String>()
    try {
        let dir = Directory(path)
        for (info in dir.entryList()) {
            result.append(info.path.toString())
        }
    } catch (_: FSException) {
        return "${path} not existed"
    }
    return result.toString()
}

//---------------------------------------------------------------------

@tool[
    description: "Read file content",
    parameters: {
        path: "Absolute path of the file to read"
    }
]
func readFile(path: String): String {
    let (status, msg) = checkPath(path)
    if (!status) { return msg }
    try (file = File(path, OpenOption.Open(true, false))) {
        let reader = StringReader(file)
        return reader.readToEnd()
    } catch(_: FSException) {
        return "${path} not existed"
    }
    return "Unreachable"
}

@tool[
    description: "Recursively search for files and directories matching a pattern. Searches through all subdirectories from the starting path. The search is case-insensitive and matches partial names. Returns full paths to all matching items. Great for finding files when you don't know their exact location. Only searches within allowed directories.",
    parameters: {
        path: "Absolute path of the directory to search",
        pattern: "There are two kinds of patters: 1. extension pattern, like .txt, .json; 2. normal pattern, part of the path to match"
    }
]
func searchFile(path: String, pattern: String): String {
    let (status, msg) = checkPath(path)
    if (!status) { return msg }
    try {
        let result = searchFileImpl(path, pattern)
        if (result.isEmpty()) {
            return "Nothing found"
        } else {
            return String.join(result.toArray(), delimiter: "\n")
        }
    } catch(_: FSException) {
        return "${path} not existed"
    }
}

func searchFileImpl(path: String, pattern: String): ArrayList<String> {
    let result = ArrayList<String>()
    for (entry in Directory(path).entryList()) {
        if (entry.isDirectory()) {
            let subFiles = searchFileImpl(entry.path.toString(), pattern)
            for (file in subFiles) {
                result.append(file)
            }
        } else {
            if (entry.path.toString().contains(pattern)) {
                result.append(entry.path.toString())
            }
        }
    }
    return result
}

//---------------------------------------------------------------------

@agent[
    model: "siliconflow:deepseek-ai/DeepSeek-V3",
    executor: "naive"
]
class SummaryAgent {
    @prompt(
        "Summarize the input as markdown"
        "The generated content is fluent, as if it were written by a professional."
    )
}

@tool[
    description: "Summarize the file content as markdown",
    parameters: {
        path: "Absolute path of the file to read"
    }
]
func summarizeFile(path: String): String {
    let (status, msg) = checkPath(path)
    if (!status) { return msg }
    try (file = File(path, OpenOption.Open(true, false))) {
        let reader = StringReader(file)
        let content = reader.readToEnd()
        let agent = SummaryAgent()
        return agent.chat("Input: ${content}")
    } catch(_: FSException) {
        return "${path} not existed"
    }
    return "Unreachable"
}
//---------------------------------------------------------------------

main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/mcp-server.log"

    let args = Process.current.arguments
    if (args.size != 2 || args[0] != "--allowed-dir") {
        println("Invalid arguments: `${args}`")
        return
    } else {
        ALLOWED_DIR = args[1]
    }

    MCPServer.startWith([getAllowedDir, listDir, readFile, searchFile, summarizeFile])
}