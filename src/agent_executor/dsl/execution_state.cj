/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.agent.{Agent, AgentRequest, AgentExecutionInfo, AgentExecutionException}
import magic.core.message.ChatMessageRole
import magic.agent_executor.common.AgentTask
import magic.dsl.jsonable
import magic.jsonable.{Jsonable, JsonableException, FieldSchema, TypeSchema}
import magic.parser.WithTag

import std.collection.{ArrayList, HashMap, map, collectArray}
import encoding.json.*

@jsonable
struct Subtask {
    let id: String
    let title: String
    let description: String
    let background: String
    let guidelines: Array<String>
}

public class ExecutionState {
    protected let task: AgentTask
    private var _answer: Option<String> = None
    // If the state represents a subtask, it use this field to refer to its parent state
    var parent: Option<ExecutionState> = None
    // If the state represents a subtask, it should be bounded with a subtask
    var subtask: Option<Subtask> = None

    // This constructor is for type safety, it will never be called.
    public init() {
        throw UnsupportedException()
    }

    protected init(task: AgentTask) {
        this.task = task
    }

    protected prop done: Bool {
        get() {
            this._answer.isSome() || this.task.stopInfo.isSome()
        }
    }

    protected mut prop answer: String {
        get() {
            if (let Some(stopInfo) <- this.task.stopInfo) {
                return stopInfo.result
            } else {
                return this._answer.getOrThrow({ =>
                    throw AgentExecutionException("The answer is not set yet")
                })
            }
        }
        set(value) {
            if (this._answer.isNone()) {
                // If the answer is not set, we can set it
                this._answer = Some(value)
            } else {
                // If the answer is already set, we cannot change it
                throw AgentExecutionException("The answer has already been set")
            }
        }
    }

    protected prop execInfo: AgentExecutionInfo {
        get() {
            return this.task.execInfo
        }
    }

    protected func extractSubtaskInfo(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("{\n")
        strBuilder.append("  description: ${this.subtask.getOrThrow().description},\n")
        strBuilder.append("  process: [\n    ${this.extractExecutionProcess()}\n  ],\n")
        strBuilder.append("  result: ${this.answer.withoutTag()}\n")
        strBuilder.append("}")
        return strBuilder.toString()
    }

    private func extractExecutionProcess(): String {
        // All assistant messages comprise the execution process
        let strArr = ArrayList<String>()
        for (msg in this.task.execInfo.dialog) {
            if (msg.role == ChatMessageRole.Assistant) {
                strArr.append(msg.content.withoutTag())
            }
        }
        return String.join(strArr.toArray(), delimiter: ",\n    ")
    }
}