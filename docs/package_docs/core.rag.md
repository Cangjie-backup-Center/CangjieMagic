## Package core.rag
- [Package core.rag](#package-core.rag)
  - [class Document](#class-document)
    - [func !=](#func-!=)
    - [func ==](#func-==)
    - [let content](#let-content)
    - [func deserialize](#func-deserialize)
    - [func fromJsonValue](#func-fromjsonvalue)
    - [func getTypeSchema](#func-gettypeschema)
    - [let id](#let-id)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [let metadata](#let-metadata)
    - [func serialize](#func-serialize)
    - [func toJsonString](#func-tojsonstring)
    - [func toJsonValue](#func-tojsonvalue)
    - [func toPrompt](#func-toprompt)
    - [func toString](#func-tostring)
  - [interface Retrieval](#interface-retrieval)
    - [prop sources](#prop-sources)
  - [struct RetrievalInfo](#struct-retrievalinfo)
  - [interface Retriever](#interface-retriever)
    - [prop description](#prop-description)
    - [prop mode](#prop-mode)
    - [func search](#func-search)
  - [class RetrieverException](#class-retrieverexception)
    - [func init](#func-init-1)
  - [enum RetrieverMode](#enum-retrievermode)
    - [func !=](#func-!=-1)
    - [func ==](#func-==-1)
    - [enumeration Dynamic](#enumeration-dynamic)
    - [enumeration Static](#enumeration-static)

### class Document
#### func operator !=
```
public operator func !=(other: Document):Bool
```
- 描述: 比较两个文档是否不相等
- 参数:
  - `other`: `Document`, 另一个文档

#### func operator ==
```
public operator func ==(other: Document):Bool
```
- 描述: 比较两个文档是否相等
- 参数:
  - `other`: `Document`, 另一个文档

#### let content
```
public let content: String
```
- 描述: 文档的内容

#### func deserialize
```
public static func deserialize(dm: DataModel)
```
- 描述: 从数据模型反序列化为文档
- 参数:
  - `dm`: `DataModel`, 数据模型

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): Document
```
- 描述: 从JSON值反序列化为文档
- 参数:
  - `json`: `JsonValue`, JSON值

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- 描述: 获取文档的类型模式

#### let id
```
public let id: String
```
- 描述: 文档的唯一标识符

#### func init
```
public init(content: String, metadata!: HashMap<String, String> = HashMap())
```
- 描述: 根据内容和元数据初始化文档
- 参数:
  - `content`: `String`, 文档的内容
  - `metadata`: `HashMap<String, String>`, 文档的元数据，默认为空

#### func init
```
public init(id: String, content: String, metadata!: HashMap<String, String>)
```
- 描述: 根据ID、内容和元数据初始化文档
- 参数:
  - `id`: `String`, 文档的唯一标识符
  - `content`: `String`, 文档的内容
  - `metadata`: `HashMap<String, String>`, 文档的元数据

#### let metadata
```
public let metadata: HashMap<String, String>
```
- 描述: 文档的元数据，存储为键值对

#### func serialize
```
public func serialize(): DataModel
```
- 描述: 将文档序列化为数据模型

#### func toJsonString
```
public func toJsonString(): String
```
- 描述: 将文档转换为JSON字符串

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- 描述: 将文档序列化为JSON值

#### func toPrompt
```
public override func toPrompt(): String
```
- 描述: 将文档转换为提示字符串

#### func toString
```
public override func toString(): String
```
- 描述: 将文档转换为字符串表示


### interface Retrieval
#### prop sources
```
prop sources: Array<Document>
```
- 描述: 检索器的结果来源


### struct RetrievalInfo

### interface Retriever
#### prop description
```
prop description: String
```
- 描述: 描述检索器将搜索的内容。在动态模式下使用。

#### prop mode
```
mut prop mode: RetrieverMode
```
- 描述: 检索器的模式。

#### func search
```
func search(query: String): Retrieval
```
- 描述: 根据查询字符串执行搜索操作。
- 参数:
  - `query`: `String`, 搜索查询字符串。


### class RetrieverException
#### func init
```
init(msg: String)
```
- 描述: 构造函数，用于创建RetrieverException实例
- 参数:
  - `msg`: `String`, 异常消息


### enum RetrieverMode
#### func operator !=
```
operator func !=(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否不相等
- 参数:
  - `other`: `RetrieverMode`, 要比较的另一个RetrieverMode实例

#### func operator ==
```
operator func ==(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否相等
- 参数:
  - `other`: `RetrieverMode`, 要比较的另一个RetrieverMode实例

####  Dynamic
```
Dynamic
```
- 描述: 检索器将在代理解决问题过程中使用

####  Static
```
Static
```
- 描述: 检索器将在代理回答问题前用于搜索相关内容


