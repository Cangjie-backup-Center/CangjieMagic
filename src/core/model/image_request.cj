/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

public struct ImageRequest {
    public let prompt: String
    // public let n: Int64
    public let quality: String
    public let responseFormat: String
    public let size: String
    public let style: String

    public init(prompt: String,
                quality!: String = "standard",
                responseFormat!: String = "url",
                size!: String = "512x512",
                style!: String = "natural") {
        this.prompt = prompt
        this.quality = quality
        this.responseFormat = responseFormat
        this.size = size
        this.style = style
    }
}
