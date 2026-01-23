/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.rag

import std.collection.ArrayList

public class RAGException <: Exception {
    public init(msg: String) { super(msg) }
}