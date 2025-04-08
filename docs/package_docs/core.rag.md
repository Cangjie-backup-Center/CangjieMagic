## Package core.rag
- [Package core.rag](#package-core.rag)
  - [class Document](#class-document)
    - [let content](#let-content)
    - [func fromJsonValue](#func-fromjsonvalue)
    - [func getTypeSchema](#func-gettypeschema)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [let metadata](#let-metadata)
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
    - [func !=](#func-!=)
    - [func ==](#func-==)
    - [enumeration Dynamic](#enumeration-dynamic)
    - [enumeration Static](#enumeration-static)

### class Document
#### let content
```
let content: String
```
- 描述: 文档内容

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): Document
```
- 描述: 从JSON值创建文档对象
- 参数:
  - `json`: `JsonValue`, 输入的JSON值

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- 描述: 获取文档的类型模式

#### func init
```
public init(content: String)
```
- 描述: 初始化文档对象
- 参数:
  - `content`: `String`, 文档内容

#### func init
```
public init(content: String, metadata!: HashMap<String, String>)
```
- 描述: 初始化文档对象，包含元数据
- 参数:
  - `content`: `String`, 文档内容
  - `metadata`: `HashMap<String, String>`, 文档元数据

#### let metadata
```
let metadata: HashMap<String, String>
```
- 描述: 文档元数据

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- 描述: 将文档对象转换为JSON值

#### func toPrompt
```
override public func toPrompt(): String
```
- 描述: 将文档转换为提示字符串

#### func toString
```
override public func toString(): String
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
  - `msg`: `String`, 异常消息内容


### enum RetrieverMode
#### func operator !=
```
operator func !=(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否不相等
- 参数:
  - `other`: `RetrieverMode`, 要比较的另一个RetrieverMode

#### func operator ==
```
operator func ==(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否相等
- 参数:
  - `other`: `RetrieverMode`, 要比较的另一个RetrieverMode

####  Dynamic
```
Dynamic
```
- 描述: 检索器将在代理解决问题过程中使用

####  Static
```
Static
```
- 描述: 检索器将在代理回答问题之前用于搜索相关内容


