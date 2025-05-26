/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.vdb

import serialization.serialization.*
import std.collection.HashMap
import std.fs.{File, OpenOption}
import encoding.json.*

/**
 * A simple index -> String map
 * Use a hashmap to store the map and save it as a json file
 */
public class SimpleIndexMap <: IndexMap<SimpleIndexMap, String> &Serializable<SimpleIndexMap> {
    // Since we use DataModel to serialize the map, its key should also be String
    var map = HashMap<String, String>()

    public func set(index: Int64, content: String): Unit {
        map.put(index.toString(), content)
    }

    override public func add(content: String): Unit {
        set(map.size, content)
    }

    override public func get(index: Int64): String {
        return map[index.toString()]
    }

    public func serialize(): DataModel {
        return DataModelStruct().add(field<HashMap<String, String>>("map", map))
    }

    public static func deserialize(dm: DataModel): SimpleIndexMap {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let result = SimpleIndexMap()
        result.map = HashMap<String, String>.deserialize(dms.get("map"))
        return result
    }

    override public func save(filePath: String): Unit {
        try (file = File(filePath, OpenOption.CreateOrTruncate(false))) {
            let bytes: Array<Byte> = this.serialize().toJson().toString().toArray()
            file.write(bytes)
        }
    }

    redef public static func load(filePath: String): SimpleIndexMap {
        let bytes: Array<Byte> = File.readFrom(filePath)
        let jsonStr: String = String.fromUtf8(bytes)
        let jv = JsonValue.fromStr(jsonStr)
        let dm = DataModelStruct.fromJson(jv)
        return SimpleIndexMap.deserialize(dm)
    }
}