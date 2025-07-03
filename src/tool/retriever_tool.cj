/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.tool.*
import magic.core.rag.*
import magic.jsonable.TypeSchema

import std.collection.{HashMap, map, collectArray}
import stdx.encoding.json.JsonValue

public class RetrieverTool <: AbsTool {
    private let retriever: Retriever

    public init(retriever: Retriever) {
        this.retriever = retriever
    }

    public prop name: String {
        get() { "__retriever__tool___" }
    }

    public prop description: String {
        get() {
            if (retriever.description == "") {
                return "Search related knowledge and context"
            } else {
                retriever.description
            }
        }
    }

    public prop parameters: Array<ToolParameter> {
        get() { [ToolParameter("query", "The query to search", TypeSchema.Str)] }
    }

    public prop retType: TypeSchema {
        get() { TypeSchema.Str }
    }

    public prop examples: Array<String> {
        get() { [] }
    }

    public func invoke(args: HashMap<String, JsonValue>): ToolResponse {
        // The retriever model tool must accept a string
        let query = args["query"].asString().getValue()
        let retrieval = retriever.search(query)
        return ToolResponse(retrieval.toPrompt())
    }
}