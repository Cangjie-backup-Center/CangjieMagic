/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool.common

import magic.dsl.tool
import magic.jsonable.*
import magic.tool.NativeFuncTool
import magic.core.model.ImageRequest
import magic.model.ModelManager

import encoding.json.JsonValue
import std.collection.{ArrayList, HashMap}

@tool[
    description: "Generate an image according to the input prompt",
    parameters: {
        prompt: "The input prompt describing the image, it should describe the contents of an image in detail. The input should be in English"
    }
]
public func generateImage(prompt: String): String {
    let model = ModelManager.createImageModel("openai:dall-e-3")
    let resp = model.create(
        ImageRequest(
            "${prompt}. The generated image should be as simple as possible, containing only a bar chart, with no additional elements, and composed of simple colors and lines. Use a simple and clean font",
            size: "1024x1024"
        )
    )
    return "Image has been generated, and its url is ${resp.url}"
}