## Package model
- [Package model](#package-model)
  - [class ModelConfig](#class-modelconfig)
    - [func init](#func-init)
  - [struct ModelManager](#struct-modelmanager)
    - [func createChatModel](#func-createchatmodel)
    - [func createChatModel](#func-createchatmodel-1)
    - [func createEmbeddingModel](#func-createembeddingmodel)
    - [func createEmbeddingModel](#func-createembeddingmodel-1)
    - [func createImageModel](#func-createimagemodel)
    - [func createImageModel](#func-createimagemodel-1)
    - [func registerChatModel](#func-registerchatmodel)
    - [func registerEmbeddingModel](#func-registerembeddingmodel)
    - [func registerImageModel](#func-registerimagemodel)
  - [struct ModelUtils](#struct-modelutils)
    - [func agentMakeChat](#func-agentmakechat)
    - [func agentMakeChatGet](#func-agentmakechatget)
    - [func makeChat](#func-makechat)
    - [func makeChat](#func-makechat-1)
    - [func makeChat](#func-makechat-1)
    - [func makeChat](#func-makechat-1)
    - [func makeChatGet](#func-makechatget)

### class ModelConfig
#### func init
```
init(service!: String, kind!: String, name!: String, apiKey!: String = "", baseURL!: String = "")
```
- 描述: 初始化模型配置。如果未指定apiKey，将使用XX_API_KEY；如果未指定baseURL，将使用XX_BASE_URL。
- 参数:
  - `service`: `String`, 服务名称
  - `kind`: `String`, 模型类型
  - `name`: `String`, 模型名称
  - `apiKey`: `String`, API密钥，默认为空字符串
  - `baseURL`: `String`, 基础URL，默认为空字符串


### struct ModelManager
#### func createChatModel
```
static func createChatModel(modelName: String, temperature!: Option<Float64> = None): ChatModel
```
- 描述: 创建聊天模型。如果模型名称已注册，则使用注册的构建函数；否则解析模型配置并创建模型。
- 参数:
  - `modelName`: `String`, 模型名称
  - `temperature`: `Option<Float64>`, 温度参数，控制生成文本的随机性，默认为None

#### func createChatModel
```
static func createChatModel(modelConfig: ModelConfig, temperature!: Option<Float64> = None): ChatModel
```
- 描述: 根据模型配置创建聊天模型。支持多种服务提供商。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置
  - `temperature`: `Option<Float64>`, 温度参数，控制生成文本的随机性，默认为None

#### func createEmbeddingModel
```
static func createEmbeddingModel(modelName: String): EmbeddingModel
```
- 描述: 创建嵌入模型。如果模型名称已注册，则使用注册的构建函数；否则解析模型配置并创建模型。
- 参数:
  - `modelName`: `String`, 模型名称

#### func createEmbeddingModel
```
static func createEmbeddingModel(modelConfig: ModelConfig): EmbeddingModel
```
- 描述: 根据模型配置创建嵌入模型。支持多种服务提供商。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置

#### func createImageModel
```
static func createImageModel(modelName: String): ImageModel
```
- 描述: 创建图像模型。如果模型名称已注册，则使用注册的构建函数；否则解析模型配置并创建模型。
- 参数:
  - `modelName`: `String`, 模型名称

#### func createImageModel
```
static func createImageModel(modelConfig: ModelConfig): ImageModel
```
- 描述: 根据模型配置创建图像模型。目前仅支持OpenAI服务。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置

#### func registerChatModel
```
static func registerChatModel(modelName: String, buildFn: () -> ChatModel): Unit
```
- 描述: 注册聊天模型构建函数。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> ChatModel`, 构建聊天模型的函数

#### func registerEmbeddingModel
```
static func registerEmbeddingModel(modelName: String, buildFn: () -> EmbeddingModel): Unit
```
- 描述: 注册嵌入模型构建函数。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> EmbeddingModel`, 构建嵌入模型的函数

#### func registerImageModel
```
static func registerImageModel(modelName: String, buildFn: () -> ImageModel): Unit
```
- 描述: 注册图像模型构建函数。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> ImageModel`, 构建图像模型的函数


### struct ModelUtils
#### func agentMakeChat
```
public static func agentMakeChat(agent: Agent, messages: Array<ChatMessage>): Option<ChatMessage>
```
- 描述: 根据给定的代理和消息列表，生成聊天消息
- 参数:
  - `agent`: `Agent`, 代理
  - `messages`: `Array<ChatMessage>`, 消息列表

#### func agentMakeChatGet
```
public static func agentMakeChatGet<T>(agent: Agent, messages: Array<ChatMessage>, getFn!: (ChatMessage) -> Option<T>): Option<T>
```
- 描述: 根据给定的代理和消息列表，生成聊天消息并应用转换函数
- 参数:
  - `agent`: `Agent`, 代理
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `getFn`: `(ChatMessage) -> Option<T>`, 转换函数，用于处理生成的聊天消息

#### func makeChat
```
public static func makeChat(model: ChatModel, dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的聊天模型和对话内容，生成聊天消息
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `dialog`: `Dialog`, 对话内容
  - `temperature`: `Option<Float64>`, 温度参数，控制生成消息的随机性
  - `stop`: `Option<Array<String>>`, 停止词列表，用于控制生成消息的终止条件

#### func makeChat
```
public static func makeChat(model: ChatModel, messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的聊天模型和消息列表，生成聊天消息
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `temperature`: `Option<Float64>`, 温度参数，控制生成消息的随机性
  - `stop`: `Option<Array<String>>`, 停止词列表，用于控制生成消息的终止条件

#### func makeChat
```
public static func makeChat(name: String, model: ChatModel, dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的名称、聊天模型和对话内容，生成聊天消息
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `dialog`: `Dialog`, 对话内容
  - `temperature`: `Option<Float64>`, 温度参数，控制生成消息的随机性
  - `stop`: `Option<Array<String>>`, 停止词列表，用于控制生成消息的终止条件

#### func makeChat
```
public static func makeChat(name: String, model: ChatModel, messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的名称、聊天模型和消息列表，生成聊天消息
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `temperature`: `Option<Float64>`, 温度参数，控制生成消息的随机性
  - `stop`: `Option<Array<String>>`, 停止词列表，用于控制生成消息的终止条件

#### func makeChatGet
```
public static func makeChatGet<T>(name: String, model: ChatModel, messages: Array<ChatMessage>, getFn!: (ChatMessage) -> Option<T>): Option<T>
```
- 描述: 根据给定的名称、聊天模型和消息列表，生成聊天消息并应用转换函数
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `getFn`: `(ChatMessage) -> Option<T>`, 转换函数，用于处理生成的聊天消息


