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
    - [func makeChat](#func-makechat)
    - [func makeChat](#func-makechat-1)
    - [func makeChatGet](#func-makechatget)

### class ModelConfig
#### func init
```
public init(provider: String, kind: String, name: String, apiKey: String = "", baseURL: String = "", contextLength: ?Int64 = None)
```
- Description: Initializes a new ModelConfig instance with the specified parameters. If apiKey or baseURL are not provided, default values will be used.
- Parameters:
  - `provider`: `String`, The provider name for the model.
  - `kind`: `String`, The kind of the model.
  - `name`: `String`, The name of the model.
  - `apiKey`: `String`, The API key for the model. If not specified, a default key will be used.
  - `baseURL`: `String`, The base URL for the model. If not specified, a default URL will be used.
  - `contextLength`: `?Int64`, The context length for the model. If not specified, a default length will be used.


### struct ModelManager
#### func createChatModel
```
public static func createChatModel(modelName: String, temperature: Option<Float64> = None): ChatModel
```
- Description: Creates a chat model with the specified name and optional temperature.
- Parameters:
  - `modelName`: `String`, The name of the chat model to create.
  - `temperature`: `Option<Float64>`, The temperature parameter for the chat model. If not specified, a default value will be used.

#### func createChatModel
```
public static func createChatModel(modelConfig: ModelConfig, temperature: Option<Float64> = None): ChatModel
```
- Description: Creates a chat model with the specified model configuration and optional temperature.
- Parameters:
  - `modelConfig`: `ModelConfig`, The configuration for the chat model.
  - `temperature`: `Option<Float64>`, The temperature parameter for the chat model. If not specified, a default value will be used.

#### func createEmbeddingModel
```
public static func createEmbeddingModel(modelName: String): EmbeddingModel
```
- Description: Creates an embedding model with the specified name.
- Parameters:
  - `modelName`: `String`, The name of the embedding model to create.

#### func createEmbeddingModel
```
public static func createEmbeddingModel(modelConfig: ModelConfig): EmbeddingModel
```
- Description: Creates an embedding model with the specified model configuration.
- Parameters:
  - `modelConfig`: `ModelConfig`, The configuration for the embedding model.

#### func createImageModel
```
public static func createImageModel(modelName: String): ImageModel
```
- Description: Creates an image model with the specified name.
- Parameters:
  - `modelName`: `String`, The name of the image model to create.

#### func createImageModel
```
public static func createImageModel(modelConfig: ModelConfig): ImageModel
```
- Description: Creates an image model with the specified model configuration.
- Parameters:
  - `modelConfig`: `ModelConfig`, The configuration for the image model.

#### func registerChatModel
```
public static func registerChatModel(modelName: String, buildFn: () -> ChatModel): Unit
```
- Description: Registers a chat model with the specified name and build function.
- Parameters:
  - `modelName`: `String`, The name of the chat model to register.
  - `buildFn`: `() -> ChatModel`, A function that builds the chat model.

#### func registerEmbeddingModel
```
public static func registerEmbeddingModel(modelName: String, buildFn: () -> EmbeddingModel): Unit
```
- Description: Registers an embedding model with the specified name and build function.
- Parameters:
  - `modelName`: `String`, The name of the embedding model to register.
  - `buildFn`: `() -> EmbeddingModel`, A function that builds the embedding model.

#### func registerImageModel
```
public static func registerImageModel(modelName: String, buildFn: () -> ImageModel): Unit
```
- Description: Registers an image model with the specified name and build function.
- Parameters:
  - `modelName`: `String`, The name of the image model to register.
  - `buildFn`: `() -> ImageModel`, A function that builds the image model.

### struct ModelUtils

#### func makeChat
```
public static func makeChat(model: ChatModel, messageList: MessageList, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<Message>
```
- Description: Creates a chat message using a chat model and message list with optional temperature and stop parameters.
- Parameters:
  - `model`: `ChatModel`, The chat model to use for generating the message.
  - `messageList`: `MessageList`, The list of messages to use as context.
  - `temperature`: `Option<Float64>`, Optional parameter to control the randomness of the output.
  - `stop`: `Option<Array<String>>`, Optional parameter to specify stop sequences for the chat.

#### func makeChat
```
public static func makeChat(name: String, model: ChatModel, messageList: MessageList, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<Message>
```
- Description: Creates a chat message with a specified name using a chat model and message list with optional temperature and stop parameters.
- Parameters:
  - `name`: `String`, The name associated with the chat.
  - `model`: `ChatModel`, The chat model to use for generating the message.
  - `messageList`: `MessageList`, The list of messages to use as context.
  - `temperature`: `Option<Float64>`, Optional parameter to control the randomness of the output.
  - `stop`: `Option<Array<String>>`, Optional parameter to specify stop sequences for the chat.

#### func makeChat
```
public static func makeChat(name: String, model: ChatModel, messages: Array<Message>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<Message>
```
- Description: Creates a chat message with a specified name using a chat model and array of messages with optional temperature and stop parameters.
- Parameters:
  - `name`: `String`, The name associated with the chat.
  - `model`: `ChatModel`, The chat model to use for generating the message.
  - `messages`: `Array<Message>`, The array of messages to use as context.
  - `temperature`: `Option<Float64>`, Optional parameter to control the randomness of the output.
  - `stop`: `Option<Array<String>>`, Optional parameter to specify stop sequences for the chat.

#### func makeChatGet
```
public static func makeChatGet<T>(name: String, model: ChatModel, messages: Array<Message>, getFn!: (Message) -> Option<T>): Option<T>
```
- Description: Creates a chat message and applies a get function to the result, returning an optional value of type T.
- Parameters:
  - `name`: `String`, The name associated with the chat.
  - `model`: `ChatModel`, The chat model to use for generating the message.
  - `messages`: `Array<Message>`, The array of messages to use as context.
  - `getFn`: `(Message) -> Option<T>`, The function to apply to the generated message.


