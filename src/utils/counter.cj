/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package magic.utils

import std.collection.*
@When[cjc_version < "0.56.4"]
import std.math.min

public class Counter<T> where T <: Hashable & Equatable<T> {
    private var cntMap: HashMap<T, Float64> = HashMap()
    private var baseScore: Float64

    public init(baseScore!: Float64 = 1.0) {
        this.baseScore = baseScore
    }

    public init(eles: Collection<T>, baseScore: Float64) {
        this(baseScore: baseScore)
        this.addAll(eles)
    }

    public func add(ele: T): Unit {
        this.add(ele, this.baseScore)
    }

    public func add(ele: T, score: Float64): Unit {
        cntMap.put(ele, cntMap.get(ele).getOrDefault({=> 0.0}) + score)
    }

    public func addAll(eles: Collection<T>): Unit {
        addAll(eles, this.baseScore)
    }

    public func addAll(eles: Collection<T>, score: Float64): Unit {
        for (ele in eles) {
            this.add(ele, score)
        }
    }

    public func merge(counter: Counter<T>): Unit {
        for ((ele, cnt) in counter.cntMap) {
            cntMap.put(ele, cntMap.get(ele).getOrDefault({=> 0.0}) + cnt)
        }
    }

    public func isEmpty(): Bool {
        this.cntMap.isEmpty()
    }

    public func getMostCommon(cnt: Int64): Array<T> {
        let entryList = this.sortedEntryList
        collectArray(entryList[0..min(entryList.size, cnt)] |> map({entry => entry[0]}))
    }

    /**
     * get the highest score key from cntMap
     *
     * if "prefer" is not None:
     *    and it's socre is also the heighest
     *    return "prefer"
     * else:
     *    return getMostCommon(1)
     */
    public func getBest(prefer: Option<T>): Option<T> {
        if (this.isEmpty()) {
            return None
        }
        match (prefer) {
            case Some(_prefer) =>
                let entryList = collectArrayList(this.cntMap)
                let first = entryList.get(0).getOrThrow()
                if (let Some(pScore) <- this.cntMap.get(_prefer)) {
                    if (pScore >= first[1]) {
                        return _prefer
                    } else {
                        return first[0]
                    }
                } else {
                    return first[0]
                }
            case None =>
                if (let Some(v) <- getMostCommon(1).get(0)) {
                    return v
                } else {
                    return None
                }
        }
    }

    private prop sortedEntryList: ArrayList<(T, Float64)> {
        get() {
            let entryList = collectArrayList(this.cntMap)
            entryList.sortBy(stable: true) {
                lht: (T, Float64), rht: (T, Float64) => if (lht[1] == rht[1]) {
                    return Ordering.EQ
                } else if (lht[1] < rht[1]) {
                    return Ordering.GT
                } else {
                    return Ordering.LT
                }
            }
            return entryList
        }
    }
}
