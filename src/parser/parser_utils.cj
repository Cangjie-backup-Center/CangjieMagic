/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.core.tool.ToolRequest
import magic.jsonable.{Jsonable, JsonUtils, JsonableException}
import magic.log.LogUtils

import stdx.encoding.json.*

public struct ParserUtils {
    private static func extractCode(str: String, lang: String, last!: Bool): Option<String> {
        let langStartMark = "```${lang}"
        let langEndMark = "```"
        let found = if (last) {
            str.lastIndexOf(langStartMark)
        } else {
            str.indexOf(langStartMark)
        }
        if (let Some(start) <- found) {
            let contentStart = start + langStartMark.size
            // Code blocks may be nested, like ```plain ```json ... ``` ```
            var nested = 0
            var currStart = contentStart
            while (let Some(pos) <- str.indexOf(langEndMark, currStart)) {
                // Check whether ``` or ```xxx is found
                let posAfterEndMark = pos + langEndMark.size
                // Case 1: ``` is found, which is a close mark
                if (posAfterEndMark == str.size ||
                    !str[posAfterEndMark].isAsciiLetter()) {
                    if (nested == 0) {
                        return str[contentStart..pos].trimAscii()
                    } else {
                        nested -= 1
                    }
                } else { // Case 2: ```xxx is found, which means a new nested code block starts
                    nested += 1
                }
                currStart = posAfterEndMark
            }
        }
        return None  // The target section is not found
    }

    /**
     * Extract a JSON object from the string using a heuristic method.
     * This method tries to find the first complete JSON object in the string.
     * It is not guaranteed to work in all cases, but it is useful for quick extraction.
     */
    private static func extractFirstJsonWithHeuristic(str: String): Option<String> {
        let start = if (let Some(idx) <- str.indexOf("{")) {
            idx
        } else {
            return None
        }
        var numberOfBraces = 0
        for (idx in start..str.size) {
            match (str[idx]) {
                case b'{' =>
                    numberOfBraces += 1
                case b'}' =>
                    numberOfBraces -= 1
                    // Found the end of the JSON object
                    if (numberOfBraces == 0) {
                        return str[start..(idx+1)].trimAscii()
                    }
                case _ => ()
            }
        }
        return None
    }

    private static func extractLastJsonWithHeuristic(str: String): Option<String> {
        let end = if (let Some(idx) <- str.lastIndexOf("}")) {
            idx
        } else {
            return None
        }
        var numberOfBraces = 0
        for (idx in end..=0:-1) {
            match (str[idx]) {
                case b'{' =>
                    numberOfBraces -= 1
                    // Found the beginning of the JSON object
                    if (numberOfBraces == 0) {
                        return str[idx..=end].trimAscii()
                    }
                case b'}' =>
                    numberOfBraces += 1
                case _ => ()
            }
        }
        return None
    }

    /**
     * Extract the last code block of the specified language from the string.
     */
    public static func extractLastCode(str: String, lang: String): Option<String> {
        return extractCode(str, lang, last: true)
    }

    /**
     * Extract the first code block of the specified language from the string.
     */
    public static func extractFirstCode(str: String, lang: String): Option<String> {
        return extractCode(str, lang, last: false)
    }

    public static func parseToolRequest(str: String): ToolRequest {
        let json = JsonValue.fromStr(str)
        let name = JsonUtils.getString(json, "name").getOrThrow({
            => ParserException("Failed to parse tool request: tool name is missing")
        })
        let args = (JsonUtils.getJsonObject(json, "arguments") ?? JsonObject()).getFields()
        return ToolRequest(name: name, args: args)
    }

    public static func extractFirstToolRequest(str: String): ToolRequest {
        let jsonStr = extractFirstCode(str, "json") ?? extractFirstJsonWithHeuristic(str).getOrThrow({ =>
            ParserException("There is no JSON output in the string: ${str}")
        })
        LogUtils.debug("Extracted JSON string: `${jsonStr}`")
        return parseToolRequest(jsonStr)
    }

    public static func extractLastToolRequest(str: String): ToolRequest {
        let jsonStr = extractLastCode(str, "json") ?? extractLastJsonWithHeuristic(str).getOrThrow({ =>
            ParserException("There is no JSON output in the string: ${str}")
        })
        LogUtils.debug("Extracted JSON string: `${jsonStr}`")
        return parseToolRequest(jsonStr)
    }

    public static func extractLastJsonValue(str: String): JsonValue {
        let jsonStr = extractLastCode(str, "json") ?? extractLastJsonWithHeuristic(str).getOrThrow({ =>
            ParserException("There is no JSON output in the string: ${str}")
        })
        LogUtils.debug("Extracted JSON string: `${jsonStr}`")
        // Parse the JSON string to the expected type
        try {
            return JsonValue.fromStr(jsonStr)
        } catch (ex: JsonException) {
            throw ParserException("Failed to parse the JSON string `${jsonStr}`")
        }
    }

    /**
     * Extract the last value of the specified type from a string that contains a JSON value.
     */
    public static func extractLastValue<T>(str: String): T where T <: Jsonable<T> {
        // Parse the JSON string to the expected type
        let jv = extractLastJsonValue(str)
        try {
            return T.fromJsonValue(jv)
        } catch (ex: JsonableException) {
            throw JsonableException("Failed to convert the JSON value `${jv}` as the specified type")
        }
    }
}