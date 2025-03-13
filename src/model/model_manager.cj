/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.model

import magic.core.agent.Agent
import magic.core.message.*
import magic.core.model.*
import magic.log.LogUtils
import magic.utils.getEnv
import magic.model.openai.{OpenAIChatModel, OpenAIEmbeddingModel, OpenAIImageModel}
import magic.model.ollama.{OllamaChatModel, OllamaEmbeddingModel}
import magic.model.dashscope.DashscopeEmbeddingModel
import magic.model.llamacpp.LlamacppEmbeddingModel
import magic.instrumentor.Instrumentor

import std.collection.HashMap
import std.collection.{filter, collectArray}

//====================================================================================
private struct ServiceConfig {
    ServiceConfig(
        let urlEnvVar: String,
        let urlEnvValue: String,
        let keyEnvVar: String
    ) { }
}

private let DEFAULT_SERVICE_MAP = HashMap<String, ServiceConfig>([
    ("openai", ServiceConfig("OPENAI_BASE_URL",
                             "https://api.openai.com/v1",
                             "OPENAI_API_KEY")),
    ("dashscope", ServiceConfig("DASHSCOPE_BASE_URL", // openai-compatible
                                "https://dashscope.aliyuncs.com/compatible-mode/v1",
                                "DASHSCOPE_API_KEY")),
    ("ark",       ServiceConfig("ARK_BASE_URL",       // openai-compatible
                                "https://ark.cn-beijing.volces.com/api/v3",
                                "ARK_API_KEY")),
    ("deepseek",  ServiceConfig("DEEPSEEK_BASE_URL",  // openai-compatible
                                "https://api.deepseek.com",
                                "DEEPSEEK_API_KEY")),
    ("siliconflow", ServiceConfig("SILICONFLOW_BASE_URL", // openai-compatible
                                  "https://api.siliconflow.cn/v1",
                                  "SILICONFLOW_API_KEY")),
    ("zhipuai",   ServiceConfig("ZHIPU_BASE_URL", // openai-compatible
                                "https://open.bigmodel.cn/api/paas/v4",
                                "ZHIPU_API_KEY")),
    ("ollama",    ServiceConfig("OLLAMA_BASE_URL",
                                "http://localhost:11434",
                                "")),
    ("llamacpp",  ServiceConfig("LLAMACPP_BASE_URL",
                                "http://localhost:8080",
                                ""))
])

private func getAllServiceNames(): Array<String> {
    return DEFAULT_SERVICE_MAP.keys().toArray()
}

func checkService(service: String): Bool {
    for (s in DEFAULT_SERVICE_MAP.keys()) {
        if (s == service) {
            return true
        }
    }
    return false
}

private func getDefaultBaseURL(service: String, kind: String): String {
    let config = DEFAULT_SERVICE_MAP[service]
    let envVarName = config.urlEnvVar
    var envVarValue = config.urlEnvValue
    // Specical case
    if (kind == "embedding" && service == "dashscope") {
        envVarValue = "https://dashscope.aliyuncs.com/api/v1"
    }
    let defaultValue = envVarValue
    return getEnv(envVarName) ?? defaultValue
}

func getDefaultApiKey(service: String): String {
    let config = DEFAULT_SERVICE_MAP[service]
    let envVarName = config.keyEnvVar
    if (envVarName == "") {
        return ""
    }
    match (getEnv(envVarName)) {
        case Some(v) => return v
        case None =>
            LogUtils.error("Get env variable ${envVarName} error.")
            throw Exception("Get env variable ${envVarName} error.")
    }
}

public class ModelConfig {
    let service: String // Model service, like "openai"
    let kind: String    // "chat", "embedding", or "image"
    let name: String    // Model name, like "gpt-4o", "text-embedding-ada-002"
    let apiKey: String
    let baseURL: String

    /**
     * If apiKey is not specified, XX_API_KEY will be used.
     * If baseURL is not specified, XX_BASE_URL will be used.
     */
    public init(service!: String, kind!: String, name!: String, apiKey!: String = "", baseURL!: String = "") {
        if (!checkService(service)) {
            LogUtils.error("Only ${getAllServiceNames()} are supported now.")
        }
        this.service = service
        this.kind = kind
        this.name = name
        if (apiKey == "") {
            this.apiKey = getDefaultApiKey(service)
        } else {
            this.apiKey = apiKey
        }
        if (baseURL == "") {
            this.baseURL = getDefaultBaseURL(service, kind)
        } else {
            this.baseURL = baseURL
        }
    }
}

/**
 * The model contains a service name and a model name, splitted by a ':'
 */
private func parseModel(model: String, kind!: String): ModelConfig {
    let items = model.split(":", 2)
    if (items.size == 1) {
        if (items[0] == "llamacpp") {
            return ModelConfig(service: "llamacpp", kind: kind, name: "unknown")
        }
    } else if (items.size == 2) {
        let service = items[0].trimAscii()
        let modelName = items[1].trimAscii()
        if (!checkService(service)) {
            throw ModelException("${model} is invalid. Only ${getAllServiceNames()} are supported now.")
        }
        return ModelConfig(service: service, kind: kind, name: modelName)
    }
    throw ModelException("${model} is invalid. Only ${getAllServiceNames()} are supported now.")
}

public struct ModelManager {
    private static let CHAT_MODEL_BUILD_FN_MAP = HashMap<String, () -> ChatModel>()

    public static func registerChatModel(modelName: String,
                                         buildFn: () -> ChatModel): Unit {
        CHAT_MODEL_BUILD_FN_MAP.put(modelName, buildFn)
    }

    public static func createChatModel(modelName: String, temperature!: Option<Float64> = None): ChatModel {
        if (let Some(fn) <- CHAT_MODEL_BUILD_FN_MAP.get(modelName)) {
            return fn()
        }
        let modelConfig = parseModel(modelName, kind: "chat")
        return ModelManager.createChatModel(modelConfig, temperature: temperature)
    }

    public static func createChatModel(modelConfig: ModelConfig, temperature!: Option<Float64> = None): ChatModel {
        match (modelConfig.service) {
            case "openai" | "dashscope" | "ark" | "deepseek" | "siliconflow" | "zhipuai" =>
                return OpenAIChatModel(modelConfig.name, apiKey: modelConfig.apiKey, baseURL: modelConfig.baseURL, temperature: temperature)
            case "ollama" =>
                return OllamaChatModel(modelConfig.name, baseURL: modelConfig.baseURL, temperature: temperature)
            case _ =>
                throw UnsupportedException("Unreachable")
        }
    }

    private static let EMBEDDING_MODEL_BUILD_FN_MAP = HashMap<String, () -> EmbeddingModel>()

    public static func registerEmbeddingModel(modelName: String,
                                              buildFn: () -> EmbeddingModel): Unit {
        EMBEDDING_MODEL_BUILD_FN_MAP.put(modelName, buildFn)
    }

    public static func createEmbeddingModel(modelName: String): EmbeddingModel {
        if (let Some(fn) <- EMBEDDING_MODEL_BUILD_FN_MAP.get(modelName)) {
            return fn()
        }
        let modelConfig = parseModel(modelName, kind: "embedding")
        return ModelManager.createEmbeddingModel(modelConfig)
    }

    public static func createEmbeddingModel(modelConfig: ModelConfig): EmbeddingModel {
        match (modelConfig.service) {
            case "openai" | "siliconflow" =>
                return OpenAIEmbeddingModel(modelConfig.name, apiKey: modelConfig.apiKey, baseURL: modelConfig.baseURL)
            case "dashscope" =>
                return DashscopeEmbeddingModel(modelConfig.name, apiKey: modelConfig.apiKey, baseURL: modelConfig.baseURL)
            case "ollama" =>
                return OllamaEmbeddingModel(modelConfig.name, baseURL: modelConfig.baseURL)
            case "llamacpp" =>
                return LlamacppEmbeddingModel(baseURL: modelConfig.baseURL)
            case _ =>
                throw UnsupportedException("Unreachable")
        }
    }

    private static let IMAGE_MODEL_BUILD_FN_MAP = HashMap<String, () -> ImageModel>()

    public static func registerImageModel(modelName: String,
                                          buildFn: () -> ImageModel): Unit {
        IMAGE_MODEL_BUILD_FN_MAP.put(modelName, buildFn)
    }

    public static func createImageModel(modelName: String): ImageModel {
        if (let Some(fn) <- IMAGE_MODEL_BUILD_FN_MAP.get(modelName)) {
            return fn()
        }
        let modelConfig = parseModel(modelName, kind: "image")
        return ModelManager.createImageModel(modelConfig)
    }

    public static func createImageModel(modelConfig: ModelConfig): ImageModel {
        match (modelConfig.service) {
            case "openai" =>
                return OpenAIImageModel(modelConfig.name, apiKey: modelConfig.apiKey, baseURL: modelConfig.baseURL)
            case _ =>
                throw UnsupportedException("Unreachable")
        }
    }
}
