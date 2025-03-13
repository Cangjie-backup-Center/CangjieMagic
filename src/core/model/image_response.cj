/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

public struct ImageResponse {
    public let b64Json: String
    public let url: String
    public let revisedPrompt: String

    public init(b64Json!: String = "",
                url!: String = "",
                revisedPrompt!: String = "") {
        this.b64Json = b64Json
        this.url = url
        this.revisedPrompt = revisedPrompt
    }
}
