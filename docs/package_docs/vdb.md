## Package vdb
- [Package vdb](#package-vdb)
  - [class FaissVectorDatabase](#class-faissvectordatabase)
    - [func addVector](#func-addvector)
    - [func close](#func-close)
    - [func init](#func-init)
    - [func load](#func-load)
    - [func save](#func-save)
    - [func search](#func-search)
  - [class InMemoryVectorDatabase](#class-inmemoryvectordatabase)
    - [func addVector](#func-addvector-1)
    - [func load](#func-load-1)
    - [func save](#func-save-1)
    - [func search](#func-search-1)
    - [func setVector](#func-setvector)
  - [interface IndexMap<Self, T>](#interface-indexmap<self,-t>)
    - [func add](#func-add)
    - [func get](#func-get)
    - [func load](#func-load-1)
    - [func save](#func-save-1)
  - [class JsonlIndexMap](#class-jsonlindexmap)
    - [func add](#func-add-1)
    - [func get](#func-get-1)
    - [func init](#func-init-1)
    - [func load](#func-load-1)
    - [func save](#func-save-1)
  - [struct SearchResult](#struct-searchresult)
    - [let dist](#let-dist)
    - [let index](#let-index)
    - [func init](#func-init-1)
  - [class SemanticMap](#class-semanticmap)
    - [func asRetriever](#func-asretriever)
    - [prop embeddingModel](#prop-embeddingmodel)
    - [let indexMap](#let-indexmap)
    - [func init](#func-init-1)
    - [func load](#func-load-1)
    - [func put](#func-put)
    - [func save](#func-save-1)
    - [func search](#func-search-1)
    - [let vectorDB](#let-vectordb)
  - [class SemanticSet](#class-semanticset)
    - [func asRetriever](#func-asretriever-1)
    - [prop embeddingModel](#prop-embeddingmodel-1)
    - [func init](#func-init-1)
    - [func load](#func-load-1)
    - [func put](#func-put-1)
    - [func save](#func-save-1)
    - [func search](#func-search-1)
  - [class SimpleIndexMap](#class-simpleindexmap)
    - [func add](#func-add-1)
    - [func deserialize](#func-deserialize)
    - [func get](#func-get-1)
    - [func load](#func-load-1)
    - [func save](#func-save-1)
    - [func serialize](#func-serialize)
    - [func set](#func-set)
  - [class Vector](#class-vector)
    - [func init](#func-init-1)
    - [let vector](#let-vector)
  - [class VectorBuilder](#class-vectorbuilder)
    - [func createEmbeddingVector](#func-createembeddingvector)
  - [interface VectorDatabase](#interface-vectordatabase)
    - [func addVector](#func-addvector-1)
    - [func load](#func-load-1)
    - [func save](#func-save-1)
    - [func search](#func-search-1)

### class FaissVectorDatabase
#### func addVector
```
addVector(vector: Vector): Unit
```
- 描述: 向Faiss向量数据库中添加一个向量
- 参数:
  - `vector`: `Vector`, 要添加到数据库的向量

#### func close
```
close(): Unit
```
- 描述: 关闭Faiss向量数据库并释放资源

#### func init
```
init(dimension: Int64 = 1536)
```
- 描述: 初始化Faiss向量数据库
- 参数:
  - `dimension`: `Int64`, 向量的维度，默认为1536

#### func load
```
load(filePath: String): FaissVectorDatabase
```
- 描述: 从指定文件路径加载Faiss向量数据库
- 参数:
  - `filePath`: `String`, 加载数据库的文件路径

#### func save
```
save(filePath: String): Unit
```
- 描述: 将Faiss向量数据库保存到指定文件路径
- 参数:
  - `filePath`: `String`, 保存数据库的文件路径

#### func search
```
search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<SearchResult>
```
- 描述: 在Faiss向量数据库中搜索与查询向量最相似的向量
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number`: `Int64`, 返回的最相似向量的数量，默认为5
  - `minDistance`: `Float64`, 最小距离阈值，默认为0.6


### class InMemoryVectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- 描述: 添加向量到数据库
- 参数:
  - `vector`: `Vector`, 要添加的向量

#### func load
```
static func load(filePath: String): InMemoryVectorDatabase
```
- 描述: 从文件加载数据库
- 参数:
  - `filePath`: `String`, 文件路径

#### func save
```
func save(filePath: String): Unit
```
- 描述: 保存数据库到文件
- 参数:
  - `filePath`: `String`, 文件路径

#### func search
```
func search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<SearchResult>
```
- 描述: 搜索与查询向量最相似的向量
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number`: `Int64`, 返回的最相似向量的数量
  - `minDistance`: `Float64`, 最小相似度阈值

#### func setVector
```
func setVector(index: Int64, vector: Vector): Unit
```
- 描述: 设置指定索引处的向量
- 参数:
  - `index`: `Int64`, 向量的索引
  - `vector`: `Vector`, 要设置的向量


### interface IndexMap<Self, T>
#### func add
```
func add(content: T): Unit
```
- 描述: 根据添加顺序确定索引
- 参数:
  - `content`: `T`, 要添加的内容

#### func get
```
func get(index: Int64): T
```
- 描述: 根据索引获取内容
- 参数:
  - `index`: `Int64`, 内容的索引

#### func load
```
static func load(filePath: String): Self
```
- 描述: 从文件加载内容
- 参数:
  - `filePath`: `String`, 文件路径

#### func save
```
func save(filePath: String): Unit
```
- 描述: 保存内容到文件
- 参数:
  - `filePath`: `String`, 文件路径


### class JsonlIndexMap
#### func add
```
override public func add(content: T): Unit
```
- 描述: 向索引映射中添加内容
- 参数:
  - `content`: `T`, 要添加的内容，必须实现Jsonable和ToPrompt接口

#### func get
```
override public func get(index: Int64): T
```
- 描述: 根据索引获取内容
- 参数:
  - `index`: `Int64`, 要获取内容的索引位置

#### func init
```
public init()
```
- 描述: 初始化一个空的JsonlIndexMap

#### func load
```
redef public static func load(filePath: String): JsonlIndexMap<T>
```
- 描述: 从文件加载索引映射
- 参数:
  - `filePath`: `String`, 要加载的文件路径

#### func save
```
override public func save(filePath: String): Unit
```
- 描述: 将索引映射保存到文件
- 参数:
  - `filePath`: `String`, 文件保存路径


### struct SearchResult
#### let dist
```
let dist: Float64
```
- 描述: 距离值

#### let index
```
let index: Int64
```
- 描述: 索引值

#### func init
```
init(index: Int64, dist: Float64)
```
- 描述: 初始化SearchResult
- 参数:
  - `index`: `Int64`, 索引值
  - `dist`: `Float64`, 距离值


### class SemanticMap
#### func asRetriever
```
public func asRetriever(): Retriever
```
- 描述: 将SemanticMap转换为检索器

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- 描述: 获取或设置嵌入模型

#### let indexMap
```
public let indexMap: IMAP
```
- 描述: 索引映射实例

#### func init
```
public init(vectorDB!: VDB, indexMap!: IMAP, embeddingModel!: Option<EmbeddingModel> = None)
```
- 描述: 初始化SemanticMap实例
- 参数:
  - `vectorDB`: `VDB`, 向量数据库实例
  - `indexMap`: `IMAP`, 索引映射实例
  - `embeddingModel`: `Option<EmbeddingModel>`, 嵌入模型选项

#### func load
```
public static func load(dirPath: String): SemanticMap<VDB, IMAP, T>
```
- 描述: 从指定目录加载SemanticMap
- 参数:
  - `dirPath`: `String`, 目录路径

#### func put
```
public func put(key: String, value: T): Unit
```
- 描述: 将键值对存入语义映射
- 参数:
  - `key`: `String`, 键
  - `value`: `T`, 值

#### func save
```
public func save(dirPath: String): Unit
```
- 描述: 保存SemanticMap到指定目录
- 参数:
  - `dirPath`: `String`, 目录路径

#### func search
```
public func search(query: String, number!: Int64 = 5, minDistance!: Float64 = 0.3): Array<T>
```
- 描述: 查找相似数据
- 参数:
  - `query`: `String`, 查询字符串
  - `number`: `Int64`, 返回结果数量
  - `minDistance`: `Float64`, 最小距离阈值

#### let vectorDB
```
public let vectorDB: VDB
```
- 描述: 向量数据库实例


### class SemanticSet
#### func asRetriever
```
public func asRetriever(): Retriever
```
- 描述: 将SemanticSet转换为Retriever实例

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- 描述: 获取或设置嵌入模型

#### func init
```
public init(vectorDB!: VDB, indexMap!: IMAP, embeddingModel!: Option<EmbeddingModel> = None)
```
- 描述: 初始化SemanticSet实例
- 参数:
  - `vectorDB`: `VDB`, 向量数据库实例
  - `indexMap`: `IMAP`, 索引映射实例
  - `embeddingModel`: `Option<EmbeddingModel>`, 嵌入模型实例，可选参数

#### func load
```
public static func load(dirPath: String): SemanticSet<VDB, IMAP, T>
```
- 描述: 从指定目录加载SemanticSet实例
- 参数:
  - `dirPath`: `String`, 加载目录路径

#### func put
```
public func put(value: T): Unit
```
- 描述: 将值存入SemanticSet
- 参数:
  - `value`: `T`, 要存入的值

#### func save
```
public func save(dirPath: String): Unit
```
- 描述: 将SemanticSet保存到指定目录
- 参数:
  - `dirPath`: `String`, 保存目录路径

#### func search
```
public func search(query: String, number!: Int64 = 5, minDistance!: Float64 = 0.3): Array<T>
```
- 描述: 根据查询字符串搜索相关内容
- 参数:
  - `query`: `String`, 查询字符串
  - `number`: `Int64`, 返回结果的最大数量，默认为5
  - `minDistance`: `Float64`, 最小距离阈值，默认为0.3


### class SimpleIndexMap
#### func add
```
func add(content: String): Unit
```
- 描述: 在末尾添加内容
- 参数:
  - `content`: `String`, 要添加的内容

#### func deserialize
```
static func deserialize(dm: DataModel): SimpleIndexMap
```
- 描述: 从数据模型反序列化为SimpleIndexMap对象
- 参数:
  - `dm`: `DataModel`, 要反序列化的数据模型

#### func get
```
func get(index: Int64): String
```
- 描述: 获取指定索引的内容
- 参数:
  - `index`: `Int64`, 要获取的索引

#### func load
```
static func load(filePath: String): SimpleIndexMap
```
- 描述: 从指定文件路径加载SimpleIndexMap对象
- 参数:
  - `filePath`: `String`, 要加载的文件路径

#### func save
```
func save(filePath: String): Unit
```
- 描述: 将当前对象保存到指定文件路径
- 参数:
  - `filePath`: `String`, 要保存的文件路径

#### func serialize
```
func serialize(): DataModel
```
- 描述: 将当前对象序列化为数据模型

#### func set
```
func set(index: Int64, content: String): Unit
```
- 描述: 设置指定索引的内容
- 参数:
  - `index`: `Int64`, 要设置的索引
  - `content`: `String`, 要设置的内容


### class Vector
#### func init
```
init(vec: Array<Float64>)
```
- 描述: 初始化向量对象
- 参数:
  - `vec`: `Array<Float64>`, 用于初始化向量的浮点数数组

#### let vector
```
let vector: Array<Float64>
```
- 描述: 存储向量数据的数组


### class VectorBuilder
#### func createEmbeddingVector
```
func createEmbeddingVector(content: String): Vector
```
- 描述: 根据输入的内容创建嵌入向量
- 参数:
  - `content`: `String`, 需要创建嵌入向量的文本内容


### interface VectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- 描述: 将向量添加到数据库中
- 参数:
  - `vector`: `Vector`, 要添加的向量

#### func load
```
static func load(filePath: String): Self
```
- 描述: 从文件加载
- 参数:
  - `filePath`: `String`, 文件路径

#### func save
```
func save(filePath: String): Unit
```
- 描述: 保存到文件
- 参数:
  - `filePath`: `String`, 文件路径

#### func search
```
func search(queryVec: Vector, number!: Int64, minDistance!: Float64): Array<SearchResult>
```
- 描述: 查询数据库并找到相似数据的索引
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number!`: `Int64`, 返回结果的数量
  - `minDistance!`: `Float64`, 最小距离阈值


