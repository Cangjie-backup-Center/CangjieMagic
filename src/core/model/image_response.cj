/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

public struct ImageResponse {
    public ImageResponse(
        protected let url!: String = "",
        // protected let b64Json: Option<String> = None
        protected let revisedPrompt!: String = "") {
    }
}
