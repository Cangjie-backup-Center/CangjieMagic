/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.core.tool.ToolRequest
import magic.jsonable.JsonUtils

import stdx.encoding.json.*

public struct OutputParserUtils {
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
                    str[posAfterEndMark].isAsciiWhiteSpace()) {
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

    public static func extractLastCode(str: String, lang: String): Option<String> {
        return extractCode(str, lang, last: true)
    }

    public static func extractFirstCode(str: String, lang: String): Option<String> {
        return extractCode(str, lang, last: false)
    }

    public static func parseToolRequest(str: String): ToolRequest {
        let json = JsonValue.fromStr(str)
        let name = JsonUtils.getString(json, "name").getOrThrow({
            => ParserException("Failed to parse tool request: there is no name")
        })
        let args = (JsonUtils.getJsonObject(json, "arguments") ?? JsonObject()).getFields()
        return ToolRequest(name: name, args: args)
    }
}