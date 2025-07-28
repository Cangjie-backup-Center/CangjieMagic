/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.tool.{Tool, ToolException}
import magic.tool.NativeFuncTool
import magic.jsonable.TypeSchema

import std.collection.HashMap
import stdx.encoding.json.{JsonObject, JsonValue}

private let ANSWER_TOOL_DESC = """
This is a special tool that can only be used after you complete all the steps and resolve the task.
You use this tool to provide the user with the final answer.
If you interact with them using this tool without finishing the task, the user will get upset.
"""

private let ANSWER_TOOL_PARAM_DESC = """
The argument is a JSON value representing the final answer.
You MUST obey the the argument schema.
"""

private let ANSWER_TOOL = NativeFuncTool(
    name: "_answer_",
    description: ANSWER_TOOL_DESC,
    parameters: [
        ("result", "The final result", TypeSchema.Str)
    ],
    terminal: true,
    filterable: false,
    execFn: { args: HashMap<String, JsonValue> =>
        // The result is the final answer
        return args.get("result")
            .getOrThrow({ => ToolException("Parameter `result` is required by the answer tool") })
            .asString()
            .getValue()
    }
)

/**
* Build a special fake tool
* This tool is used to provide the final answer after all steps are completed
* There is an internal **trick** that we can inject our answer tool with the same name
*/
func buildAnswerTool(schema: Option<TypeSchema>): NativeFuncTool {
    if (let Some(schema) <- schema) {
        return NativeFuncTool(
            name: "_answer_",
            description: ANSWER_TOOL_DESC,
            parameters: [
                ("result", ANSWER_TOOL_PARAM_DESC, schema)
            ],
            terminal: true,
            filterable: false,
            execFn: { args: HashMap<String, JsonValue> =>
                // The result is the final answer
                return args.get("result")
                    .getOrThrow({ => ToolException("Parameter `result` is required by the answer tool") })
                    .toJsonString()
            }
        )
    } else {
        return ANSWER_TOOL
    }
}