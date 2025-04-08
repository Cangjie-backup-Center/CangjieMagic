## Package core.model
- [Package core.model](#package-core.model)
  - [struct AsyncChatChunk](#struct-asyncchatchunk)
    - [func toString](#func-tostring)
  - [class AsyncChatResponse](#class-asyncchatresponse)
    - [let chunks](#let-chunks)
    - [prop contentIter](#prop-contentiter)
    - [prop dialog](#prop-dialog)
    - [let model](#let-model)
    - [func next](#func-next)
    - [func toString](#func-tostring-1)
    - [prop usage](#prop-usage)
  - [interface ChatModel](#interface-chatmodel)
    - [func asyncCreate](#func-asynccreate)
    - [func create](#func-create)
  - [class ChatRequest](#class-chatrequest)
    - [let dialog](#let-dialog)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [let stop](#let-stop)
    - [let temperature](#let-temperature)
    - [func toString](#func-tostring-1)
  - [struct ChatResponse](#struct-chatresponse)
    - [let dialog](#let-dialog-1)
    - [func init](#func-init-1)
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
    - [func init](#func-init-1)
    - [let prompt](#let-prompt-1)
    - [let quality](#let-quality)
    - [let responseFormat](#let-responseformat)
    - [let size](#let-size)
    - [let style](#let-style)
  - [struct ImageResponse](#struct-imageresponse)
    - [let b64Json](#let-b64json)
    - [func init](#func-init-1)
    - [let revisedPrompt](#let-revisedprompt)
    - [let url](#let-url)
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
- 描述: 将AsyncChatChunk对象转换为字符串表示形式


### class AsyncChatResponse
#### let chunks
```
public let chunks: Iterator<AsyncChatChunk>
```
- 描述: 异步聊天块的迭代器

#### prop contentIter
```
public prop contentIter: Iterator<String>
```
- 描述: 获取内容迭代器

#### prop dialog
```
public prop dialog: Dialog
```
- 描述: 同步获取聊天对话框

#### let model
```
public let model: String
```
- 描述: 模型名称

#### func next
```
override public func next(): Option<AsyncChatChunk>
```
- 描述: 获取下一个聊天块

#### func toString
```
public func toString(): String
```
- 描述: 将AsyncChatResponse对象转换为字符串表示形式

#### prop usage
```
public prop usage: Option<ChatUsage>
```
- 描述: 获取聊天使用情况


### interface ChatModel
#### func asyncCreate
```
func asyncCreate(request: ChatRequest): AsyncChatResponse
```
- 描述: 聊天模型的异步API
- 参数:
  - `request`: `ChatRequest`, 聊天请求参数

#### func create
```
func create(request: ChatRequest): ChatResponse
```
- 描述: 聊天模型的同步API
- 参数:
  - `request`: `ChatRequest`, 聊天请求参数


### class ChatRequest
#### let dialog
```
let dialog: Dialog
```
- 描述: 对话内容

#### func init
```
public init(message: String)
```
- 描述: 通过消息初始化ChatRequest
- 参数:
  - `message`: `String`, 用户消息

#### func init
```
public init(messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- 描述: 通过消息数组初始化ChatRequest
- 参数:
  - `messages`: `Array<ChatMessage>`, 聊天消息数组
  - `temperature`: `Option<Float64>`, 温度参数
  - `stop`: `Option<Array<String>>`, 停止条件

#### func init
```
public init(dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- 描述: 通过对话对象初始化ChatRequest
- 参数:
  - `dialog`: `Dialog`, 对话对象
  - `temperature`: `Option<Float64>`, 温度参数
  - `stop`: `Option<Array<String>>`, 停止条件

#### let stop
```
let stop: Option<Array<String>>
```
- 描述: 停止条件

#### let temperature
```
let temperature: Option<Float64>
```
- 描述: 温度参数

#### func toString
```
public func toString(): String
```
- 描述: 将ChatRequest对象转换为字符串表示


### struct ChatResponse
#### let dialog
```
public let dialog: Dialog
```
- 描述: 对话内容

#### func init
```
public init(dialog: Dialog, model: String, usage!: Option<ChatUsage> = None)
```
- 描述: 初始化ChatResponse
- 参数:
  - `dialog`: `Dialog`, 对话内容
  - `model`: `String`, 模型名称
  - `usage`: `Option<ChatUsage>`, 使用情况统计

#### let model
```
public let model: String
```
- 描述: 模型名称

#### func toString
```
public func toString(): String
```
- 描述: 将ChatResponse转换为字符串表示

#### let usage
```
public let usage: Option<ChatUsage>
```
- 描述: 使用情况统计


### class ChatUsage
#### let completionTokens
```
public let completionTokens: Int64
```
- 描述: 表示完成令牌的数量

#### func init
```
public init(promptTokens!: Int64, completionTokens!: Int64, totalTokens!: Int64, timeCost!: Option<Duration>)
```
- 描述: 初始化ChatUsage实例
- 参数:
  - `promptTokens`: `Int64`, 提示令牌的数量
  - `completionTokens`: `Int64`, 完成令牌的数量
  - `totalTokens`: `Int64`, 总令牌数量
  - `timeCost`: `Option<Duration>`, 时间消耗，可能为空

#### let promptTokens
```
public let promptTokens: Int64
```
- 描述: 表示提示令牌的数量

#### let timeCost
```
public let timeCost: Option<Duration>
```
- 描述: 表示时间消耗，可能为空

#### func toString
```
public func toString(): String
```
- 描述: 将ChatUsage实例转换为字符串表示

#### let totalTokens
```
public let totalTokens: Int64
```
- 描述: 表示总令牌数量


### interface EmbeddingModel
#### func create
```
func create(request: EmbeddingRequest): EmbeddingResponse
```
- 描述: 根据请求创建嵌入向量
- 参数:
  - `request`: `EmbeddingRequest`, 嵌入请求，包含需要嵌入的文本信息


### struct EmbeddingRequest
#### let dimensions
```
let dimensions: Option<Int64>
```
- 描述: 可选的嵌入维度

#### func init
```
public init(prompt: String, dimensions!: Option<Int> = None)
```
- 描述: 初始化EmbeddingRequest结构体
- 参数:
  - `prompt`: `String`, 输入的提示文本
  - `dimensions`: `Option<Int>`, 可选的嵌入维度

#### let prompt
```
let prompt: String
```
- 描述: 输入的提示文本


### struct EmbeddingResponse
#### let data
```
let data: Array<Float64>
```
- 描述: 存储嵌入向量的数组

#### func init
```
init(data: Array<Float64>)
```
- 描述: 初始化EmbeddingResponse实例
- 参数:
  - `data`: `Array<Float64>`, 嵌入向量数组

#### func toString
```
func toString(): String
```
- 描述: 将EmbeddingResponse转换为字符串表示


### interface ImageModel
#### func create
```
func create(request: ImageRequest): ImageResponse
```
- 描述: 根据图像请求创建图像响应
- 参数:
  - `request`: `ImageRequest`, 图像请求参数


### struct ImageRequest
#### func init
```
init(prompt: String, quality: String = "standard", responseFormat: String = "url", size: String = "512x512", style: String = "natural")
```
- 描述: 初始化ImageRequest结构体
- 参数:
  - `prompt`: `String`, 生成图片的提示文本
  - `quality`: `String`, 图片生成的质量标准，默认为standard
  - `responseFormat`: `String`, 响应格式，默认为url
  - `size`: `String`, 生成图片的尺寸，默认为512x512
  - `style`: `String`, 图片的风格，默认为natural

#### let prompt
```
let prompt: String
```
- 描述: 生成图片的提示文本

#### let quality
```
let quality: String
```
- 描述: 图片生成的质量标准

#### let responseFormat
```
let responseFormat: String
```
- 描述: 响应格式

#### let size
```
let size: String
```
- 描述: 生成图片的尺寸

#### let style
```
let style: String
```
- 描述: 图片的风格


### struct ImageResponse
#### let b64Json
```
let b64Json: String
```
- 描述: Base64编码的图片数据

#### func init
```
public init(b64Json!: String = "", url!: String = "", revisedPrompt!: String = "")
```
- 描述: 初始化ImageResponse结构体
- 参数:
  - `b64Json`: `String`, Base64编码的图片数据，默认为空字符串
  - `url`: `String`, 图片的URL地址，默认为空字符串
  - `revisedPrompt`: `String`, 修订后的提示文本，默认为空字符串

#### let revisedPrompt
```
let revisedPrompt: String
```
- 描述: 修订后的提示文本

#### let url
```
let url: String
```
- 描述: 图片的URL地址


### interface Model
#### prop name
```
prop name: String
```
- 描述: 模型名称，例如gpt-4o

#### prop service
```
prop service: String
```
- 描述: 服务名称，例如openai


### class ModelException
#### func init
```
init(msg: String)
```
- 描述: 初始化ModelException异常
- 参数:
  - `msg`: `String`, 异常消息


