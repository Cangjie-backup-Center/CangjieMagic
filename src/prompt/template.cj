/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.prompt

import std.regex.Regex
import std.collection.HashMap

public interface Template {
    func format(kv: Array<(String, ToString)>): String
    func format(kv: HashMap<String, ToString>): String
}

extend String <: Template {
    public func format(kv: Array<(String, ToString)>): String {
        let map = HashMap<String, ToString>(kv)
        return this.format(map)
    }

    public func format(kv: HashMap<String, ToString>): String {
        let regex = Regex("{\\s*([_a-zA-Z][_a-zA-Z0-9]+)\\s*}")
        let matcher = regex.matcher(this)
        let subStrings = matcher.split()
        let keys = match (matcher.findAll()) {
            case Some(mdArray) =>
                Array<String>(mdArray.size, { i: Int64 =>
                    mdArray[i].matchStr(1)
                })
            case None => Array<String>()
        }
        if (subStrings.size != keys.size + 1) {
            throw Exception("String format error")
        }
        // "... {key1}...{key2}...{keyN}..."
        let sb = StringBuilder()
        sb.append(subStrings[0])
        for (i in 0..keys.size) {
            sb.append(kv[keys[i]])
            sb.append(subStrings[i+1])
        }
        return sb.toString()
    }
}