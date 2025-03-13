/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.jsonable

import std.collection.{HashMap, map, collectArray, ArrayList}
import encoding.json.{JsonValue, JsonObject, JsonString}
import encoding.json.JsonArray

public struct FieldSchema {
    public FieldSchema (
        public let name: String,
        public let description: String,
        public let typeSchema: TypeSchema,
        public let required!: Bool = true
    ) { }
}

public enum TypeSchema <: ToString {
    | Str
    | Int
    | Float
    | Boolean
    | Arr(TypeSchema)
    | Obj(Array<FieldSchema>)

    public func toJsonValue(): JsonValue {
        let jo = JsonObject()
        match (this) {
            case Str => jo.put("type", JsonString("string"))
            case Int => jo.put("type", JsonString("integer"))
            case Float => jo.put("type", JsonString("integer"))
            case Boolean => jo.put("type", JsonString("boolean"))
            case Arr(ts) =>
                jo.put("type", JsonString("array"))
                jo.put("arrayItem", ts.toJsonValue())
            case Obj(fields) =>
                jo.put("type", JsonString("object"))
                let propertiesJo = JsonObject()
                let required = ArrayList<JsonValue>()
                for (field in fields) {
                    if (field.description == "") {
                        propertiesJo.put(field.name, field.typeSchema.toJsonValue())
                    } else {
                        let tsJo = field.typeSchema.toJsonValue().asObject()
                        tsJo.put("description", JsonString(field.description))
                        propertiesJo.put(field.name, tsJo)
                    }
                    if (field.required) {
                        required.append(JsonString(field.name))
                    }
                }
                jo.put("properties", propertiesJo)
                jo.put("required", JsonArray(required))
        }
        return jo
    }

    // Change it as `toJsonValue().toStirng()` later
    public func toString(): String {
        return this.toJsonValue().toJsonString()

        match (this) {
            case Str => return "type: string"
            case Int => return "type: integer"
            case Float => return "type: integer"
            case Boolean => return "type: boolean"
            case Arr(ts) => return "type: array, arrayItem: { ${ts} }"
            case Obj(fields) =>
                let propertyStr = String.join(
                    fields.iterator() |>
                        map { field: FieldSchema =>
                            if (field.description == "") {
                                return "${field.name}: { ${field.typeSchema} }"
                            } else {
                                return "${field.name}: { description: ${field.description}, ${field.typeSchema} }"
                            }
                        } |>
                        collectArray,
                    delimiter: ",\n"
                )
                let required = ArrayList<String>()
                for (field in fields) {
                    if (field.required) {
                        required.append(field.name)
                    }
                }
                let requiredStr = String.join(
                    required.toArray(),
                    delimiter: ","
                )
                return "type: object,\nproperties: { ${propertyStr} }\nrequired: [${requiredStr}]"
        }
    }
}
