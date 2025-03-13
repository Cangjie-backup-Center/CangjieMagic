/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

@When[cjc_version < "0.56.4"]
import std.time.Duration

public class ChatUsage <: ToString {
    public let promptTokens: Int64
    public let completionTokens: Int64
    public let totalTokens: Int64
    public let timeCost: Option<Duration>

    public init(promptTokens!: Int64,
                completionTokens!: Int64,
                totalTokens!: Int64,
                timeCost!: Option<Duration>) {
        this.promptTokens = promptTokens
        this.completionTokens = completionTokens
        this.totalTokens = totalTokens
        this.timeCost = timeCost
    }
    public func toString(): String {
        "ChatUsage[completionTokens ${completionTokens}, promptTokens ${promptTokens}, totalTokens ${totalTokens}, timeCost ${timeCost.toString()}]"
    }
}
