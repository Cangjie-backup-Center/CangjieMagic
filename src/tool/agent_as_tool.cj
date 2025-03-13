/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool

import magic.core.agent.*
import magic.core.tool.*
import magic.jsonable.{TypeSchema, ToJsonValue}

import std.collection.HashMap

protected class AgentAsTool <: AbsTool {
    protected let agent: Agent

    public init(agent: Agent) {
        this.agent = agent
    }

    public prop name: String {
        get() { this.agent.name }
    }

    public prop description: String {
        get() {
            return if (this.agent.description == "") {
                summarize(this.agent.model, this.agent.systemPrompt)
            } else {
                this.agent.description
            }
        }
    }

    public prop parameters: Array<ToolParameter> {
        get() { [ToolParameter("question", "The input question", TypeSchema.Str)] }
    }

    public prop retType: TypeSchema {
        get() { TypeSchema.Str }
    }

    public prop examples: Array<String> {
        get() { [] }
    }

    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        if (args.size == 1) {
            // The agent tool must receive a string
            let question = args["question"].toJsonValue().asString().getValue()
            let resp = this.agent.chat(AgentRequest(question))
            return ToolResponse(resp.content)
        } else {
            throw ToolException("Agent as tool with invalid arguments")
        }
    }
}