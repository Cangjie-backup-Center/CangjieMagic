/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.ui.html

import std.collection.{HashMap, ArrayList}

public class TemplateMetadata {
    let thumbnail: String
    let title: String
    let desc: String
    let category: String
    let name: String

    init(thumbnail: String, title: String, desc: String, category: String, name: String) {
        this.thumbnail = thumbnail
        this.category = category
        this.name = name
        this.title = title
        this.desc = desc
    }
}

public interface Template {
    static prop metadata: TemplateMetadata
    prop html: String
}

class TemplateManager {
    static let metadataMap = HashMap<String, ArrayList<TemplateMetadata>>()
    static func register(metadata: TemplateMetadata): Unit {
        if (metadataMap.contains(metadata.category)) {
            let arr = metadataMap[metadata.category]
            arr.add(metadata)
            metadataMap[metadata.category] = arr
        } else {
            let arr = ArrayList<TemplateMetadata>()
            arr.add(metadata)
            metadataMap[metadata.category] = arr
        }
    }
    static func get(category: String): Array<TemplateMetadata> {
        if (metadataMap.contains(category)) {
            return metadataMap[category].toArray()
        }
        return Array<TemplateMetadata>()
    }
}