/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.message

public class Message <: ToString {
    public let name: String      // name of the sender
    public let role: MessageRole // role of the sender
    public let content: String
    public let image: Option<String> // url or base64
    // The reasoning content
    // A reason model, like deepseek-r1, may generate reasoning content or regular content
    public let reason: Option<String>

    public init(
        role: MessageRole,
        content: String,
        name!: String = "",
        image!: Option<String> = None,
        reason!: Option<String> = None) {
        this.name = name
        this.role = role
        this.content = content
        this.image = image
        this.reason = reason
    }

    public func toString(): String {
        let reason = if (let Some(r) <- this.reason) {
            ">${r}<; "
        } else {
            ""
        }
        return "${role}: ${reason}${content}"
    }

    public func toLogString(): String {
        let reason = if (let Some(r) <- this.reason) {
            ". Reasoning content: ${r}"
        } else {
            ""
        }
        "Message<${role}>: ${content}${reason}"
    }

    public static func system(content: String): Message {
        Message(MessageRole.System, content, name: "System")
    }

    public static func assistant(content: String, name!: String = ""): Message {
        Message(MessageRole.Assistant, content, name: name)
    }

    public static func user(content: String, image!: Option<String> = None): Message {
        Message(MessageRole.User, content, name: "User", image: image)
    }
}