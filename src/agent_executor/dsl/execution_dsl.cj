/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.dsl

import magic.core.tool.Tool

import std.collection.{ArrayList, map, collectArray}

public type DSLExecutionOp = (ExecutionState) -> ExecutionState

/**
 * Operator is a function that transforms an ExecutionState into another ExecutionState.
 */
open public class DSLOperator {
    DSLOperator(private let fn: DSLExecutionOp) {
    }

    public operator func ()(state: ExecutionState): ExecutionState {
        return fn(state)
    }

    public operator func ()(clause: DSLWhenClause): DSLWhenClause {
        clause.operations.add(this)
        return clause
    }
}

public class DSLAction <: DSLOperator {
    DSLAction() {
        super({ state => doAction(state, tool: None) })
    }

    public operator func ()(tool!: Tool): DSLOperator {
        return DSLOperator({ state: ExecutionState =>
            return doAction(state, tool: Some(tool))
        })
    }
}

public struct DSLWhenClause {
    let condition: String
    let operations: ArrayList<DSLOperator>
    let default: Bool

    public init(condition: String) {
        this.condition = condition
        this.operations = ArrayList<DSLOperator>()
        this.default = false
    }

    public init() {
        this.condition = ""
        this.operations = ArrayList<DSLOperator>()
        this.default = true
    }
}

/**
 * ExecutionDSL provides a set of operations for executing in the DslExecutor.
 * It includes operations like planning, thinking, invoking tools, and handling subtasks.
 */
public struct ExecutionDSL {
    public static let plan = DSLOperator(doPlan)

    public static let think = DSLOperator(doThink)

    public static let action = DSLAction()

    public static let done = DSLOperator(doDone)

    public static let answer = DSLOperator(doAnswer)

    public static let otherwise = DSLWhenClause()

    public static func repeat(op: DSLExecutionOp, until!: String): DSLOperator {
        return DSLOperator({ state: ExecutionState =>
            return doRepeat(state, op, untilCondition: until)
        })
    }

    public static func orchestrate(op: DSLExecutionOp): DSLOperator {
        return DSLOperator({ state: ExecutionState =>
            let initStatesOfSubtasks = doDivide(state)
            let statesOfSubtasks = doEach(initStatesOfSubtasks, op)
            return doSummary(statesOfSubtasks)
        })
    }

    public static func decide(whenClauses: Array<DSLWhenClause>): DSLOperator {
        return DSLOperator({ state: ExecutionState =>
            return doDecide(state, whenClauses)
        })
    }

    public static func decide(whenClause: DSLWhenClause): DSLOperator {
        return decide([whenClause])
    }

    public static func when(condition: String): DSLWhenClause {
        return DSLWhenClause(condition)
    }
}
