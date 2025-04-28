/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.tool.*
import magic.jsonable.{TypeSchema, ToJsonValue}
import std.collection.{ArrayList, HashMap}

private type ExecFn = (HashMap<String, ToJsonValue>) -> String

open public class NativeFuncTool <: AbsTool {
    private let _name: String
    private let _description: String
    private let _parameters: ArrayList<ToolParameter>
    private var _retType: TypeSchema = TypeSchema.Str
    private let _examples: ArrayList<String>
    private var _fnOpt: Option<ExecFn>

    public init(name!: String,
                description!: String,
                parameters!: Array<(String, String, TypeSchema)> = [],
                retType!: TypeSchema = TypeSchema.Str,
                examples!: Array<String> = [],
                filterable!: Bool = true,
                execFn!: Option<ExecFn> = None) {
        _name = name
        _description = description
        _parameters = ArrayList<ToolParameter>()
        for (item in parameters) {
            _parameters.append(ToolParameter(item[0], item[1], item[2]))
        }
        _retType = retType
        _examples = ArrayList<String>()
        _examples.appendAll(examples)
        _fnOpt = execFn
        if (!filterable) {
            this._extra.put("filterable", "false")
        }
    }

    public prop name: String {
        get() { _name }
    }

    public prop description: String {
        get() { _description }
    }

    public prop parameters: Array<ToolParameter> {
        get() { _parameters.toArray() }
    }

    public prop retType: TypeSchema {
        get() { _retType }
    }

    public prop examples: Array<String> {
        get() { _examples.toArray() }
    }

    /**
     * Each argument is represented as a string of Json value
     */
    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        if (let Some(fn) <- _fnOpt) {
            try {
                let result = fn(args)
                return ToolResponse(result)
            } catch (ex: Exception) {
                throw ToolException("Fail to invoke the native function. Reason: ${ex.toString()}")
            }
        } else {
            throw ToolException("The tool `${_name}` has not a native function")
        }
    }

    public func addExamples(examples: Array<String>): Unit {
        _examples.appendAll(examples)
    }
}