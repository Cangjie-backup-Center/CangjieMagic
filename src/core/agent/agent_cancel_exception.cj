/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.agent

/**
 * This exception is used to indicate that the agent execution is cancelled by user.
 */
public class AgentCancelException <: Exception {
    public let result: String = "Cancelled by user"

    public init() {
        super("Cancelled by user")
    }
}
