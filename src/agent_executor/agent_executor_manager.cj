/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor

import magic.core.agent.AgentExecutor
import magic.agent_executor.naive.NaiveExecutor
import magic.agent_executor.react.ReactExecutor

import std.collection.ArrayList
import magic.core.agent.AgentExecutionException

private struct AgentExecutorBuilder {
    AgentExecutorBuilder(
        let checkFn: (String) -> Bool,
        let buildFn: (String) -> AgentExecutor) { }
}

public struct AgentExecutorManager {
    private static let AGENT_EXECUTOR_BUILDS = ArrayList<AgentExecutorBuilder>()

    public static func register(checkFn: (String) -> Bool,
                                buildFn: (String) -> AgentExecutor): Unit {
        AGENT_EXECUTOR_BUILDS.append(AgentExecutorBuilder(checkFn, buildFn))
    }

    public static func register(name: String,
                                buildFn: () -> AgentExecutor): Unit {
        AGENT_EXECUTOR_BUILDS.append(
            AgentExecutorBuilder(
                { n: String => n == name },
                { n: String => buildFn() }
            )
        )
    }

    public static func create(name: String): AgentExecutor {
        if (name == "naive") {
            return NaiveExecutor()
        } else if (name == "react") {
            return ReactExecutor()
        }
        for (builder in AGENT_EXECUTOR_BUILDS) {
            if (builder.checkFn(name)) {
                return builder.buildFn(name)
            }
        }
        throw AgentExecutionException("Unknown executor: `${name}`")
    }
}
