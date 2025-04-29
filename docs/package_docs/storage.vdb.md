## Package storage.vdb
- [Package storage.vdb](#package-storage.vdb)
  - [class FaissVectorStorage](#class-faissvectorstorage)
    - [func add](#func-add)
    - [func close](#func-close)
    - [prop collection](#prop-collection)
    - [func commit](#func-commit)
    - [prop embeddingModel](#prop-embeddingmodel)
    - [func init](#func-init)
    - [func query](#func-query)
    - [func reset](#func-reset)
    - [prop workspace](#prop-workspace)
  - [class JsonMemroyVectorStorage](#class-jsonmemroyvectorstorage)
    - [func add](#func-add-1)
    - [func close](#func-close-1)
    - [prop collection](#prop-collection-1)
    - [func commit](#func-commit-1)
    - [prop embeddingModel](#prop-embeddingmodel-1)
    - [func init](#func-init-1)
    - [func query](#func-query-1)
    - [func queryWithScore](#func-querywithscore)
    - [func reset](#func-reset-1)
    - [prop workspace](#prop-workspace-1)
  - [class LocalVectorStorage](#class-localvectorstorage)
  - [interface VectorStorage](#interface-vectorstorage)
    - [func add](#func-add-1)
    - [prop embeddingModel](#prop-embeddingmodel-1)
    - [func query](#func-query-1)
    - [func queryWithScore](#func-querywithscore-1)

### class FaissVectorStorage
#### func add
```
func add(doc: Document): Unit
```
- 描述: 添加文档到存储
- 参数:
  - `doc`: `Document`, 文档对象

#### func close
```
func close(): Unit
```
- 描述: 关闭存储

#### prop collection
```
prop collection: String
```
- 描述: 获取集合名称

#### func commit
```
func commit(): Unit
```
- 描述: 提交更改到存储

#### prop embeddingModel
```
prop embeddingModel: EmbeddingModel
```
- 描述: 获取嵌入模型

#### func init
```
init(embeddingModel: EmbeddingModel, workspace!: String = ".storage", collection!: String = "default")
```
- 描述: 初始化Faiss向量存储
- 参数:
  - `embeddingModel`: `EmbeddingModel`, 嵌入模型
  - `workspace`: `String`, 工作区路径
  - `collection`: `String`, 集合名称

#### func query
```
func query(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<Document>
```
- 描述: 查询文档
- 参数:
  - `query`: `String`, 查询字符串
  - `topK`: `Int64`, 返回结果数量
  - `threshold`: `Float64`, 相似度阈值

#### func reset
```
func reset(): Unit
```
- 描述: 重置存储

#### prop workspace
```
prop workspace: String
```
- 描述: 获取工作区路径


### class JsonMemroyVectorStorage
#### func add
```
public func add(doc: Document): Unit
```
- 描述: 添加或更新文档到存储中
- 参数:
  - `doc`: `Document`, 要添加或更新的文档

#### func close
```
public func close(): Unit
```
- 描述: 关闭存储并释放资源

#### prop collection
```
public prop collection: String
```
- 描述: 获取集合名称

#### func commit
```
public func commit(): Unit
```
- 描述: 提交所有未保存的更改

#### prop embeddingModel
```
public prop embeddingModel: EmbeddingModel
```
- 描述: 获取用于生成嵌入向量的模型

#### func init
```
public init(embeddingModel: EmbeddingModel, workspace!: String = ".storage", collection!: String = "default")
```
- 描述: 初始化JsonMemroyVectorStorage实例
- 参数:
  - `embeddingModel`: `EmbeddingModel`, 用于生成嵌入向量的模型
  - `workspace`: `String`, 存储向量数据的目录路径，默认为".storage"
  - `collection`: `String`, 集合名称，默认为"default"

#### func query
```
public func query(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<Document>
```
- 描述: 查询与输入字符串最相关的文档
- 参数:
  - `query`: `String`, 查询字符串
  - `topK`: `Int64`, 返回的最相关文档数量
  - `threshold`: `Float64`, 相似度阈值，默认为0.6

#### func queryWithScore
```
public func queryWithScore(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<(Document, Float64)>
```
- 描述: 查询与输入字符串最相关的文档及其相似度分数
- 参数:
  - `query`: `String`, 查询字符串
  - `topK`: `Int64`, 返回的最相关文档数量
  - `threshold`: `Float64`, 相似度阈值，默认为0.6

#### func reset
```
public func reset(): Unit
```
- 描述: 重置存储，清除所有数据

#### prop workspace
```
public prop workspace: String
```
- 描述: 获取存储向量数据的目录路径


### class LocalVectorStorage

### interface VectorStorage
#### func add
```
func add(doc: Document): Unit
```
- 描述: 向存储中添加一个新文档
- 参数:
  - `doc`: `Document`, 要添加的文档

#### prop embeddingModel
```
prop embeddingModel: EmbeddingModel
```
- 描述: 获取或设置嵌入模型

#### func query
```
func query(query: String, topK: Int64, threshold!: Float64): Array<Document>
```
- 描述: 查询与输入字符串最相关的文档
- 参数:
  - `query`: `String`, 查询字符串
  - `topK`: `Int64`, 返回的文档数量上限
  - `threshold!`: `Float64`, 相似度阈值，低于此值的文档将被过滤

#### func queryWithScore
```
func queryWithScore(query: String, topK: Int64, threshold!: Float64): Array<(Document, Float64)>
```
- 描述: 查询与输入字符串最相关的文档，并返回相似度分数
- 参数:
  - `query`: `String`, 查询字符串
  - `topK`: `Int64`, 返回的文档数量上限
  - `threshold!`: `Float64`, 相似度阈值，低于此值的文档将被过滤


