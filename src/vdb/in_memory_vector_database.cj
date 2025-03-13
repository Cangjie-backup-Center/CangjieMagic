/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.vdb

import magic.log.LogUtils

import std.collection.ArrayList
@When[cjc_version < "0.56.4"]
import std.math.min

struct VectorWithIndex {
    VectorWithIndex(
        let index: Int64,
        let vector: Vector) { }
}

public class InMemoryVectorDatabase <: VectorDatabase<InMemoryVectorDatabase> {
    let vectorBuffer = ArrayList<VectorWithIndex>()

    override public func addVector(vector: Vector): Unit {
        let index = vectorBuffer.size
        vectorBuffer.append(VectorWithIndex(index, vector))
        // return index
    }

    /*
     *  query: the query string
     *  number: number of most similar vectors to be returned
    */
    override public func search(queryVec: Vector, number!: Int64 = 5, minDistance!: Float64 = 0.6): Array<Int64> {
        if (vectorBuffer.isEmpty()) {
            LogUtils.info("Vector buffer is empty")
            return []
        }
        let tempList = vectorBuffer.clone()
        tempList.sortBy(stable: true) { a: VectorWithIndex, b: VectorWithIndex =>
            if(a.vector.cosineSimilarity(queryVec) > b.vector.cosineSimilarity(queryVec)) {
                return Ordering.LT
            }
            if(a.vector.cosineSimilarity(queryVec) < b.vector.cosineSimilarity(queryVec)) {
                return Ordering.GT
            }
            return Ordering.EQ
        }
        let result = ArrayList<Int64>()
        for(i in 0..min(number, tempList.size)) {
            let dist = tempList[i].vector.cosineSimilarity(queryVec)
            if (dist < minDistance) {
                break
            }
            LogUtils.debug("Query distance: ${dist}")
            result.append(tempList[i].index)
        }
        return result.toArray()
    }

    override public func save(filePath: String): Unit {
        throw UnsupportedException()
    }

    redef public static func load(filePath: String): InMemoryVectorDatabase {
        throw UnsupportedException()
    }
}
