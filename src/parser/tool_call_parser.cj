/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import std.collection.{ArrayList, HashMap}

/**
 * A tool call is like a python function call
 * return: function name and argument array
 */
func parseToolCallImpl(str: String): (toolName: String, arguments: Array<String>) {
    let callStr = str.trimAscii()
    // Parsing the tool name
    let endOfToolName = if (let Some(idx) <- callStr.indexOf(b'(')) {
        idx
    } else {
        return ("", ["Parsing tool name failed"])
    }
    let toolName = callStr[0..endOfToolName].trimAscii()
    if (!isValidIdentifier(toolName)) {
        return ("", ["Invalid tool name"])
    }
    // Parsing the arguments
    let endOfArgument = if (let Some(idx) <- callStr.lastIndexOf(b')')) {
        idx
    } else {
        return ("", ["Parsing arguments failed"])
    }
    let arguments = callStr[endOfToolName+1..endOfArgument]
    try {
        let args = parseArguments(arguments)
        return (toolName, args)
    } catch(_) {
        return ("", ["Parsing arguments failed"])
    }
}

func isValidIdentifier(str: String): Bool {
    for (rune in str.runes()) {
        if (!(rune.isAsciiNumberOrLetter() || rune.compare(r"_") == Ordering.EQ)) {
            return false
        }
    }
    return true
}

let BYTE_PAIR = HashMap<Byte, Byte>([
    (b'"', b'"'),
    (b'\'', b'\''),
    (b'$', b'$')
])

func parseArguments(argumentsStr: String): Array<String> {
    // Preprocess the arguments string
    // If the argument is a multi-line string literal, wrapped by """,
    // change it as wrapped by $
    let arguments = argumentsStr.replace("\"\"\"", "$")
    let result = ArrayList<String>()
    var idx = 0
    while (idx < arguments.size) {
        let currentByte = arguments[idx]
        match (currentByte) {
            case b'"' | b'\'' | b'$' =>
                let endByte = BYTE_PAIR[currentByte]
                idx += 1
                let start = idx
                while (idx < arguments.size && arguments[idx] != endByte) {
                    if (arguments[idx] == b'\\') { // Add the trailing byte bytes, like \x
                        idx += 2
                    } else {
                        idx += 1
                    }
                }
                if (idx == arguments.size) {
                    throw Exception("Parsing arguments failed")
                }
                result.append('"${arguments[start..idx].trimAscii()}"') // Wrap the value as string literal
                idx += 1 // Skip the end byte
            case b',' | b' ' =>
                idx += 1
            case _ =>
                let start = idx
                while (idx < arguments.size && arguments[idx] != b',') {
                    idx += 1
                }
                result.append(arguments[start..idx].trimAscii())
        }
    }
    return result.toArray()
}
