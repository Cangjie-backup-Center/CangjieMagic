/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.message

public enum ChatMessageRole <: ToString {
    | System
    | User
    | Assistant
    | Unknown

    public func toString(): String {
        match (this) {
            case ChatMessageRole.System => "system"
            case ChatMessageRole.User => "user"
            case ChatMessageRole.Assistant => "assistant"
            case ChatMessageRole.Unknown => "unknown"
        }
    }

    public static func fromStr(str: String): ChatMessageRole {
        if (str == "system") {
            return ChatMessageRole.System
        } else if (str == "user") {
            return ChatMessageRole.User
        } else if (str == "assistant") {
            return ChatMessageRole.Assistant
        } else {
            return ChatMessageRole.Unknown
        }
    }

    public operator func ==(other: ChatMessageRole): Bool {
        match ((this, other)) {
            case (ChatMessageRole.System, ChatMessageRole.System) => true
            case (ChatMessageRole.User, ChatMessageRole.User) => true
            case (ChatMessageRole.Assistant, ChatMessageRole.Assistant) => true
            case (ChatMessageRole.Unknown, ChatMessageRole.Unknown) => false
            case _ => false
        }
    }
    public operator func !=(other: ChatMessageRole): Bool {
        return !(this == other)
    }
}

public class ChatMessage <: ToString {
    public let name: String // name of the sender
    public let role: ChatMessageRole // role of the sender
    public let content: String
    public let image: Option<String> // url or base64
    public let reasoningContent: Option<String> // A reply message from a reason model, like deepseek-r1

    public init(
        role: ChatMessageRole, content: String,
        name!: String = "",
        image!: Option<String> = None,
        reasoningContent!: Option<String> = None) {
        this.name = name
        this.role = role
        this.content = content
        this.image = image
        this.reasoningContent = reasoningContent
    }

    public func toString(): String {
        let reason = if (let Some(rc) <- this.reasoningContent) {
            "**reasoning**: `${rc}`;"
        } else {
            ""
        }
        return "${role}: ${reason}**content**: `${content}`"
    }

    public func toLogString(): String {
        let reason = if (let Some(rc) <- this.reasoningContent) {
            ". Reasoning content: ${rc}"
        } else {
            ""
        }
        "ChatMessage<${role}>: ${content}${reason}"
    }

    public static func system(content: String): ChatMessage {
        ChatMessage(ChatMessageRole.System, content, name: "System")
    }

    public static func assistant(content: String, name!: String = ""): ChatMessage {
        ChatMessage(ChatMessageRole.Assistant, content, name: name)
    }

    public static func user(content: String, image!: Option<String> = None): ChatMessage {
        ChatMessage(ChatMessageRole.User, content, name: "User", image: image)
    }
}