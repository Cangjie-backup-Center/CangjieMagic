/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.parser

import magic.core.tool.ToolRequest
import magic.jsonable.JsonUtils

import encoding.json.*

public struct OutputParserUtils {
    public static func extractLastCode(str: String, lang: String): Option<String> {
        let langStartMark = "```${lang}"
        let langEndMark = "```"
        if (let Some(start) <- str.lastIndexOf(langStartMark)) {
            let contentStart = start + langStartMark.size
            var nested = 0
            var currStart = contentStart
            while (let Some(pos) <- str.indexOf(langEndMark, currStart)) {
                // Check whether ``` or ```xxx is found
                let posAfterEndMark = pos + langEndMark.size
                if (posAfterEndMark >= str.size ||
                    str[posAfterEndMark].isAsciiWhiteSpace()) {
                    if (nested == 0) {
                        return str[contentStart..pos].trimAscii()
                    } else {
                        nested -= 1
                    }
                } else {
                    nested += 1
                }
                currStart = posAfterEndMark
            }
        }
        return None  // The target section is not found
    }

    public static func extractLastSection(str: String, section: String): ?String {
        let sectionName = if (section.startsWith("[") && section.endsWith("]")) {
            section[1..section.size-1]
        } else {
            section
        }
        let sectionStart = "[${sectionName}]"
        let sectionEnd = "[/${sectionName}]"
        if (let Some(start) <- str.lastIndexOf(sectionStart)) {
            let contentStart = start + sectionStart.size
            if (let Some(end) <- str.indexOf(sectionEnd, contentStart)) {
                return str[contentStart..end].trimAscii()
            }
            if (section == "[Final Answer]" || section == "[Tool]") {
                // Special treatment for this section
                // because LLM is prone to generate the final answer without [/Final Answer]
                return str[contentStart..str.size].trimAscii()
            }
        }
        return None  // The target section is not found
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