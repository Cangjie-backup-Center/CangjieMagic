/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.compactor

import magic.core.message.{Conversation, MessageList}

/**
 * Compact the conversation
 */
public interface ConversationCompactor {
    /**
     * Compact the conversation a list of messages
     */
    func compact(conversation: Conversation): MessageList
}