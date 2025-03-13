/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.core.model

/**
 * A model consist of
 * - a service name, e.g., openai
 * - a model name, e.g., gpt-4o
 * There are different models, e.g., chat model, image model, audio model, etc.
 */
public interface Model {
    prop service: String
    prop name: String
}
