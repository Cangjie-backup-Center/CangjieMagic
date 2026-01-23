/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.rag.vdb

import magic.core.rag.Vector
import magic.core.model.{EmbeddingModel, EmbeddingRequest}

public class VectorBuilder {
    public VectorBuilder(private let model!: EmbeddingModel) { }

    public func createEmbeddingVector(content: String): Vector {
        let resp = model.create(EmbeddingRequest(content))
        return Vector(resp.data)
    }
}
