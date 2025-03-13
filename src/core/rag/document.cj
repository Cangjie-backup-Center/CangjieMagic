/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.rag

import magic.jsonable.*
import magic.prompt.ToPrompt

import std.collection.HashMap
import std.collection.ArrayList
import encoding.json.*

public class Document <: Jsonable<Document> & ToString & ToPrompt {
    public let content: String
    public let metadata: HashMap<String, String>

    public init(content: String) {
        this.content = content
        this.metadata = HashMap<String, String>()
    }

    public init(content: String, metadata!: HashMap<String, String>) {
        this.content = content
        this.metadata = metadata
    }

    override public func toString(): String {
        let strBuilder = StringBuilder()
        strBuilder.append("Metadata:")
        strBuilder.append(metadata.toString())
        strBuilder.append("\n")
        strBuilder.append("Content: ${content}")
        return strBuilder.toString()
    }

    override public func toPrompt(): String {
        return content
    }

    public static func getTypeSchema(): TypeSchema {
        return TypeSchema.Obj([
            FieldSchema("content", "", String.getTypeSchema(), required: true),
            FieldSchema("metadata", "", HashMap <String, String>.getTypeSchema(), required: true)
        ])
    }

    public static func fromJsonValue(json: JsonValue): Document {
        let jo: JsonObject = match(json.kind()) {
            case JsonKind.JsObject => json.asObject()
            case _ => throw JsonableException("Get JSON object error.")
        }
        return Document(
            String.fromJsonValue(jo.get("content") ?? JsonString("")),
            metadata: HashMap<String, String>.fromJsonValue(jo.get("metadata") ?? JsonObject() )
        )
    }

    public func toJsonValue(): JsonValue {
        let map = HashMap <String, JsonValue>()
        map.put("content", content.toJsonValue())
        map.put("metadata", metadata.toJsonValue())
        return JsonObject(map)
    }
}