## Package core.model
- [Package core.model](#package-core.model)
  - [struct AsyncChatChunk](#struct-asyncchatchunk)
    - [func toString](#func-tostring)
  - [class AsyncChatResponse](#class-asyncchatresponse)
    - [let chunks](#let-chunks)
    - [func iter](#func-iter)
    - [prop messageList](#prop-messagelist)
    - [let model](#let-model)
    - [func toString](#func-tostring-1)
    - [prop usage](#prop-usage)
  - [interface ChatModel](#interface-chatmodel)
    - [func asyncCreate](#func-asynccreate)
    - [prop contextLength](#prop-contextlength)
    - [func create](#func-create)
  - [class ChatRequest](#class-chatrequest)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [let messageList](#let-messagelist)
    - [let stop](#let-stop)
    - [let temperature](#let-temperature)
    - [func toString](#func-tostring-1)
  - [struct ChatResponse](#struct-chatresponse)
    - [func init](#func-init-1)
    - [let messageList](#let-messagelist-1)
    - [let model](#let-model-1)
    - [func toString](#func-tostring-1)
    - [let usage](#let-usage)
  - [class ChatUsage](#class-chatusage)
    - [let completionTokens](#let-completiontokens)
    - [func init](#func-init-1)
    - [let promptTokens](#let-prompttokens)
    - [let timeCost](#let-timecost)
    - [func toString](#func-tostring-1)
    - [let totalTokens](#let-totaltokens)
  - [interface EmbeddingModel](#interface-embeddingmodel)
    - [func create](#func-create-1)
  - [struct EmbeddingRequest](#struct-embeddingrequest)
    - [let dimensions](#let-dimensions)
    - [func init](#func-init-1)
    - [let prompt](#let-prompt)
  - [struct EmbeddingResponse](#struct-embeddingresponse)
    - [let data](#let-data)
    - [func init](#func-init-1)
    - [func toString](#func-tostring-1)
  - [interface ImageModel](#interface-imagemodel)
    - [func create](#func-create-1)
  - [struct ImageRequest](#struct-imagerequest)
  - [struct ImageResponse](#struct-imageresponse)
  - [interface Model](#interface-model)
    - [prop name](#prop-name)
    - [prop service](#prop-service)
  - [class ModelException](#class-modelexception)
    - [func init](#func-init-1)

### struct AsyncChatChunk
#### func toString
```
override public func toString(): String
```
- Description: Converts the AsyncChatChunk object to a string representation.


### class AsyncChatResponse
#### let chunks
```
public let chunks: Iterator<AsyncChatChunk>
```
- Description: An iterator over the chunks of the chat response.

#### func iter
```
public func iter(withReason!: Bool = true): Iterator<String>
```
- Description: Returns an iterator over the chat response strings, optionally including the reason.
- Parameters:
  - `withReason`: `Bool`, Whether to include the reason in the iterator.

#### prop messageList
```
public prop messageList: MessageList
```
- Description: Gets the list of messages from the chat response, waiting for completion if necessary.

#### let model
```
public let model: String
```
- Description: The model used for the chat response.

#### func toString
```
public func toString(): String
```
- Description: Converts the AsyncChatResponse object to a string representation.

#### prop usage
```
public prop usage: Option<ChatUsage>
```
- Description: Gets the usage information of the chat response if it has finished.


### interface ChatModel
#### func asyncCreate
```
func asyncCreate(request: ChatRequest): AsyncChatResponse
```
- Description: Asynchronous API of the chat model
- Parameters:
  - `request`: `ChatRequest`, The chat request

#### prop contextLength
```
prop contextLength: Int64
```
- Description: The context length of the chat model

#### func create
```
func create(request: ChatRequest): ChatResponse
```
- Description: Synchronous API of the chat model
- Parameters:
  - `request`: `ChatRequest`, The chat request


### class ChatRequest
#### func init
```
init(message: String)
```
- Description: Constructor that initializes the chat request with a single user message
- Parameters:
  - `message`: `String`, The user message to initialize the chat request

#### func init
```
init(messages: Array<Message>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- Description: Constructor that initializes the chat request with an array of messages and optional parameters
- Parameters:
  - `messages`: `Array<Message>`, Array of messages to initialize the chat request
  - `temperature`: `Option<Float64>`, Optional temperature setting for the chat request
  - `stop`: `Option<Array<String>>`, Optional stop conditions for the chat request

#### func init
```
init(messageList: MessageList, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- Description: Constructor that initializes the chat request with a MessageList and optional parameters
- Parameters:
  - `messageList`: `MessageList`, MessageList to initialize the chat request
  - `temperature`: `Option<Float64>`, Optional temperature setting for the chat request
  - `stop`: `Option<Array<String>>`, Optional stop conditions for the chat request

#### let messageList
```
let messageList: MessageList
```
- Description: List of messages in the chat request

#### let stop
```
let stop: Option<Array<String>>
```
- Description: Optional stop conditions for the chat request

#### let temperature
```
let temperature: Option<Float64>
```
- Description: Optional temperature setting for the chat request

#### func toString
```
func toString(): String
```
- Description: Converts the chat request to a string representation


### struct ChatResponse
#### func init
```
init(messageList: MessageList, model: String, usage: Option<ChatUsage> = None)
```
- Description: Initializes a new ChatResponse with the given message list, model, and optional usage statistics.
- Parameters:
  - `messageList`: `MessageList`, List of messages to include in the response.
  - `model`: `String`, The model used for generating the response.
  - `usage`: `Option<ChatUsage>`, Optional usage statistics for the response.

#### let messageList
```
let messageList: MessageList
```
- Description: List of messages in the chat response.

#### let model
```
let model: String
```
- Description: The model used for generating the chat response.

#### func toString
```
func toString(): String
```
- Description: Converts the ChatResponse to a string representation.

#### let usage
```
let usage: Option<ChatUsage>
```
- Description: Usage statistics of the chat response.


### class ChatUsage
#### let completionTokens
```
let completionTokens: Int64
```
- Description: Number of tokens used in the completion

#### func init
```
init(promptTokens: Int64, completionTokens: Int64, totalTokens: Int64, timeCost: Option<Duration>)
```
- Description: Constructor for ChatUsage
- Parameters:
  - `promptTokens`: `Int64`, Number of tokens used in the prompt
  - `completionTokens`: `Int64`, Number of tokens used in the completion
  - `totalTokens`: `Int64`, Total number of tokens used
  - `timeCost`: `Option<Duration>`, Time cost of the operation

#### let promptTokens
```
let promptTokens: Int64
```
- Description: Number of tokens used in the prompt

#### let timeCost
```
let timeCost: Option<Duration>
```
- Description: Time cost of the operation

#### func toString
```
func toString(): String
```
- Description: Converts the ChatUsage object to a string representation

#### let totalTokens
```
let totalTokens: Int64
```
- Description: Total number of tokens used


### interface EmbeddingModel
#### func create
```
func create(request: EmbeddingRequest): EmbeddingResponse
```
- Description: Creates an embedding based on the provided request.
- Parameters:
  - `request`: `EmbeddingRequest`, The request containing the data needed to create an embedding.


### struct EmbeddingRequest
#### let dimensions
```
let dimensions: Option<Int64>
```
- Description: Optional dimensions for the embedding output

#### func init
```
init(prompt: String, dimensions!: Option<Int> = None)
```
- Description: Initializes an EmbeddingRequest with the given prompt and optional dimensions
- Parameters:
  - `prompt`: `String`, The input prompt for generating embeddings
  - `dimensions`: `Option<Int>`, Optional dimensions for the embedding output

#### let prompt
```
let prompt: String
```
- Description: The input prompt for generating embeddings


### struct EmbeddingResponse
#### let data
```
let data: Array<Float64>
```
- Description: An array of floating-point numbers representing the embedding data

#### func init
```
init(data: Array<Float64>)
```
- Description: Initializes the EmbeddingResponse with the given data
- Parameters:
  - `data`: `Array<Float64>`, An array of floating-point numbers representing the embedding data

#### func toString
```
func toString(): String
```
- Description: Converts the embedding data to a string representation


### interface ImageModel
#### func create
```
func create(request: ImageRequest): ImageResponse
```
- Description: Creates an image based on the provided request.
- Parameters:
  - `request`: `ImageRequest`, The request containing details for image creation.


### struct ImageRequest

### struct ImageResponse

### interface Model
#### prop name
```
prop name: String
```
- Description: The model name, e.g., gpt-4o

#### prop service
```
prop service: String
```
- Description: The service name of the model, e.g., openai


### class ModelException
#### func init
```
init(msg: String)
```
- Description: Constructor for ModelException
- Parameters:
  - `msg`: `String`, The error message for the exception


