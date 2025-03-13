/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.memory

import magic.core.memory.Memory
import magic.vdb.{SemanticSet, InMemoryVectorDatabase, SimpleIndexMap}

public class ShortMemory <: Memory {
    private let vecSet = SemanticSet(vectorDB: InMemoryVectorDatabase(),
                                     indexMap: SimpleIndexMap())

    override public func update(segment: String): Unit {
        vecSet.put(segment)
    }

    /**
     * According to the user question, find related content in the memory
     */
    override public func search(question: String): Array<String> {
        return vecSet.search(question, number: 5)
    }
}