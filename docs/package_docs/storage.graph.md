## Package storage.graph
- [Package storage.graph](#package-storage.graph)
  - [class BaseGraph<V, E>](#class-basegraph<v,-e>)
    - [func clear](#func-clear)
    - [func getAllNodes](#func-getallnodes)
    - [func getEdges](#func-getedges)
    - [func getIncomingEdgesOf](#func-getincomingedgesof)
    - [func getOutgoingEdgesOf](#func-getoutgoingedgesof)
    - [func getVertex](#func-getvertex)
    - [func getVertexTypes](#func-getvertextypes)
    - [func getVertices](#func-getvertices)
    - [func hasEdge](#func-hasedge)
    - [func hasVertex](#func-hasvertex)
    - [func removeEdge](#func-removeedge)
    - [func removeVertex](#func-removevertex)
    - [func upsertEdge](#func-upsertedge)
    - [func upsertVertex](#func-upsertvertex)
  - [class BaseLocalGraphStorage<V, E>](#class-baselocalgraphstorage<v,-e>)
    - [func close](#func-close)
    - [prop collection](#prop-collection)
    - [func commit](#func-commit)
    - [func getAllVertices](#func-getallvertices)
    - [func getEdge](#func-getedge)
    - [func getEdges](#func-getedges-1)
    - [func getIncomingEdgesOf](#func-getincomingedgesof-1)
    - [func getOutgoingEdgesOf](#func-getoutgoingedgesof-1)
    - [func getVertex](#func-getvertex-1)
    - [func getVertexTypes](#func-getvertextypes-1)
    - [func hasEdge](#func-hasedge-1)
    - [func hasVertex](#func-hasvertex-1)
    - [func init](#func-init)
    - [func removeEdge](#func-removeedge-1)
    - [func removeVertex](#func-removevertex-1)
    - [func reset](#func-reset)
    - [func upsertEdge](#func-upsertedge-1)
    - [func upsertVertex](#func-upsertvertex-1)
    - [prop workspace](#prop-workspace)
  - [class Edge<E>](#class-edge<e>)
    - [func !=](#func-!=)
    - [func ==](#func-==)
    - [prop data](#prop-data)
    - [func deserialize](#func-deserialize)
    - [prop eType](#prop-etype)
    - [func fromJson](#func-fromjson)
    - [func hashCode](#func-hashcode)
    - [func init](#func-init-1)
    - [func serialize](#func-serialize)
    - [prop srcId](#prop-srcid)
    - [prop tgtId](#prop-tgtid)
    - [func toJsonString](#func-tojsonstring)
    - [prop uniqueId](#prop-uniqueid)
    - [prop weight](#prop-weight)
  - [interface GraphStorage<V, E>](#interface-graphstorage<v,-e>)
    - [func getAllVertices](#func-getallvertices-1)
    - [func getEdge](#func-getedge-1)
    - [func getEdges](#func-getedges-1)
    - [func getIncomingEdgesOf](#func-getincomingedgesof-1)
    - [func getOutgoingEdgesOf](#func-getoutgoingedgesof-1)
    - [func getVertex](#func-getvertex-1)
    - [func getVertexTypes](#func-getvertextypes-1)
    - [func hasEdge](#func-hasedge-1)
    - [func hasVertex](#func-hasvertex-1)
    - [func removeEdge](#func-removeedge-1)
    - [func removeVertex](#func-removevertex-1)
    - [func upsertEdge](#func-upsertedge-1)
    - [func upsertVertex](#func-upsertvertex-1)
  - [class IllegalEdgeException](#class-illegaledgeexception)
    - [func init](#func-init-1)
  - [interface LocalGraphStorage<V, E>](#interface-localgraphstorage<v,-e>)
  - [class NodeContainer<V, E>](#class-nodecontainer<v,-e>)
    - [func addIncomingEdge](#func-addincomingedge)
    - [func addOutgoingEdge](#func-addoutgoingedge)
    - [prop incoming](#prop-incoming)
    - [prop outgoing](#prop-outgoing)
    - [func removeIncomingEdge](#func-removeincomingedge)
    - [func removeOutgoingEdge](#func-removeoutgoingedge)
    - [prop vertex](#prop-vertex)
  - [class Vertex<V>](#class-vertex<v>)
    - [func !=](#func-!=-1)
    - [func ==](#func-==-1)
    - [prop data](#prop-data-1)
    - [func deserialize](#func-deserialize-1)
    - [func fromJsonString](#func-fromjsonstring)
    - [func hashCode](#func-hashcode-1)
    - [prop id](#prop-id)
    - [func init](#func-init-1)
    - [func serialize](#func-serialize-1)
    - [func toJsonString](#func-tojsonstring-1)
    - [prop vType](#prop-vtype)

### class BaseGraph<V, E>
#### func clear
```
func clear(): Unit
```
- 描述: 清空图

#### func getAllNodes
```
func getAllNodes(): Array<NodeContainer<V, E>>
```
- 描述: 获取所有节点容器

#### func getEdges
```
func getEdges(srcId: String, tgtId: String): Array<Edge<E>>
```
- 描述: 获取边
- 参数:
  - `srcId`: `String`, 源顶点ID
  - `tgtId`: `String`, 目标顶点ID

#### func getIncomingEdgesOf
```
func getIncomingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取顶点的入边
- 参数:
  - `id`: `String`, 顶点ID

#### func getOutgoingEdgesOf
```
func getOutgoingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取顶点的出边
- 参数:
  - `id`: `String`, 顶点ID

#### func getVertex
```
func getVertex(id: String): ?Vertex<V>
```
- 描述: 根据ID获取顶点
- 参数:
  - `id`: `String`, 顶点ID

#### func getVertexTypes
```
func getVertexTypes(): Set<String>
```
- 描述: 获取所有顶点类型

#### func getVertices
```
func getVertices(): Array<Vertex<V>>
```
- 描述: 获取所有顶点

#### func hasEdge
```
func hasEdge(srcId: String, tgtId: String): Bool
```
- 描述: 判断是否存在边
- 参数:
  - `srcId`: `String`, 源顶点ID
  - `tgtId`: `String`, 目标顶点ID

#### func hasVertex
```
func hasVertex(id: String): Bool
```
- 描述: 判断是否存在顶点
- 参数:
  - `id`: `String`, 顶点ID

#### func removeEdge
```
func removeEdge(e: Edge<E>): Unit
```
- 描述: 移除边
- 参数:
  - `e`: `Edge<E>`, 边

#### func removeVertex
```
func removeVertex(id: String): Unit
```
- 描述: 移除顶点
- 参数:
  - `id`: `String`, 顶点ID

#### func upsertEdge
```
func upsertEdge(e: Edge<E>): Unit
```
- 描述: 更新或插入边
- 参数:
  - `e`: `Edge<E>`, 边

#### func upsertVertex
```
func upsertVertex(v: Vertex<V>): Unit
```
- 描述: 更新或插入顶点
- 参数:
  - `v`: `Vertex<V>`, 顶点


### class BaseLocalGraphStorage<V, E>
#### func close
```
public func close(): Unit
```
- 描述: 关闭图存储

#### prop collection
```
public prop collection: String
```
- 描述: 获取存储的集合名称

#### func commit
```
public func commit(): Unit
```
- 描述: 提交所有更改到存储

#### func getAllVertices
```
public func getAllVertices(): Array<Vertex<V>>
```
- 描述: 获取图中的所有顶点

#### func getEdge
```
public func getEdge(srcId: String, tgtId: String, eType: String): Option<Edge<E>>
```
- 描述: 获取指定源顶点、目标顶点和边类型的边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符
  - `eType`: `String`, 边的类型

#### func getEdges
```
public func getEdges(srcId: String, tgtId: String): Array<Edge<E>>
```
- 描述: 获取从源顶点到目标顶点的所有边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符

#### func getIncomingEdgesOf
```
public func getIncomingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取指向指定顶点的所有边
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getOutgoingEdgesOf
```
public func getOutgoingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取从指定顶点出发的所有边
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getVertex
```
public func getVertex(id: String): Option<Vertex<V>>
```
- 描述: 获取指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getVertexTypes
```
public func getVertexTypes(): Set<String>
```
- 描述: 获取图中所有顶点的类型

#### func hasEdge
```
public func hasEdge(srcId: String, tgtId: String): Bool
```
- 描述: 检查图中是否存在从源顶点到目标顶点的边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符

#### func hasVertex
```
public func hasVertex(id: String): Bool
```
- 描述: 检查图中是否存在指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func init
```
public init(workspace!: String = ".storage", collection!: String = "default")
```
- 描述: 初始化本地图存储
- 参数:
  - `workspace`: `String`, 存储的工作目录
  - `collection`: `String`, 存储的集合名称

#### func removeEdge
```
public func removeEdge(e: Edge<E>): Unit
```
- 描述: 移除指定的边
- 参数:
  - `e`: `Edge<E>`, 要移除的边

#### func removeVertex
```
public func removeVertex(id: String): Unit
```
- 描述: 移除指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func reset
```
public func reset(): Unit
```
- 描述: 重置图存储

#### func upsertEdge
```
public func upsertEdge(edge: Edge<E>): Unit
```
- 描述: 插入或更新边
- 参数:
  - `edge`: `Edge<E>`, 要插入或更新的边

#### func upsertVertex
```
public func upsertVertex(vertex: Vertex<V>): Unit
```
- 描述: 插入或更新顶点
- 参数:
  - `vertex`: `Vertex<V>`, 要插入或更新的顶点

#### prop workspace
```
public prop workspace: String
```
- 描述: 获取存储的工作目录


### class Edge<E>
#### func operator !=
```
operator func !=(other: Edge<E>): Bool
```
- 描述: 判断两条边是否不相等
- 参数:
  - `other`: `Edge<E>`, 另一条边

#### func operator ==
```
operator func ==(other: Edge<E>): Bool
```
- 描述: 判断两条边是否相等
- 参数:
  - `other`: `Edge<E>`, 另一条边

#### prop data
```
prop data: Option<E>
```
- 描述: 获取边数据

#### func deserialize
```
static func deserialize(dm: DataModel)
```
- 描述: 反序列化边
- 参数:
  - `dm`: `DataModel`, 数据模型

#### prop eType
```
prop eType: String
```
- 描述: 获取边类型

#### func fromJson
```
static func fromJson(str: String): Edge<E>
```
- 描述: 从JSON字符串中解析边
- 参数:
  - `str`: `String`, JSON字符串

#### func hashCode
```
func hashCode(): Int64
```
- 描述: 计算边的哈希值

#### func init
```
init(srcId: String, tgtId: String, eType!: String = "DEFAULT", weight!: Float64 = 1.0, data!: Option<E> = None)
```
- 描述: 构造函数，初始化边
- 参数:
  - `srcId`: `String`, 源顶点ID
  - `tgtId`: `String`, 目标顶点ID
  - `eType`: `String`, 边类型，默认为"DEFAULT"
  - `weight`: `Float64`, 边权重，默认为1.0
  - `data`: `Option<E>`, 边数据，默认为None

#### func serialize
```
func serialize(): DataModel
```
- 描述: 序列化边

#### prop srcId
```
prop srcId: String
```
- 描述: 获取源顶点ID

#### prop tgtId
```
prop tgtId: String
```
- 描述: 获取目标顶点ID

#### func toJsonString
```
func toJsonString(): String
```
- 描述: 将边转换为JSON字符串

#### prop uniqueId
```
prop uniqueId: String
```
- 描述: 获取边的唯一ID

#### prop weight
```
mut prop weight: Float64
```
- 描述: 获取或设置边权重


### interface GraphStorage<V, E>
#### func getAllVertices
```
func getAllVertices(): Array<Vertex<V>>
```
- 描述: 获取图中的所有顶点

#### func getEdge
```
func getEdge(srcId: String, tgtId: String, eType: String): Option<Edge<E>>
```
- 描述: 获取指定源顶点、目标顶点和边类型的边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符
  - `eType`: `String`, 边的类型

#### func getEdges
```
func getEdges(srcId: String, tgtId: String): Array<Edge<E>>
```
- 描述: 获取从源顶点到目标顶点的所有边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符

#### func getIncomingEdgesOf
```
func getIncomingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取指向指定顶点的所有边
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getOutgoingEdgesOf
```
func getOutgoingEdgesOf(id: String): Array<Edge<E>>
```
- 描述: 获取从指定顶点出发的所有边
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getVertex
```
func getVertex(id: String): Option<Vertex<V>>
```
- 描述: 获取指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func getVertexTypes
```
func getVertexTypes(): Set<String>
```
- 描述: 获取图中所有顶点的类型

#### func hasEdge
```
func hasEdge(srcId: String, tgtId: String): Bool
```
- 描述: 检查图中是否存在从源顶点到目标顶点的边
- 参数:
  - `srcId`: `String`, 源顶点的唯一标识符
  - `tgtId`: `String`, 目标顶点的唯一标识符

#### func hasVertex
```
func hasVertex(id: String): Bool
```
- 描述: 检查图中是否存在指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func removeEdge
```
func removeEdge(e: Edge<E>): Unit
```
- 描述: 移除指定的边
- 参数:
  - `e`: `Edge<E>`, 要移除的边

#### func removeVertex
```
func removeVertex(id: String): Unit
```
- 描述: 移除指定ID的顶点
- 参数:
  - `id`: `String`, 顶点的唯一标识符

#### func upsertEdge
```
func upsertEdge(edge: Edge<E>): Unit
```
- 描述: 插入或更新边
- 参数:
  - `edge`: `Edge<E>`, 要插入或更新的边

#### func upsertVertex
```
func upsertVertex(vertex: Vertex<V>): Unit
```
- 描述: 插入或更新顶点
- 参数:
  - `vertex`: `Vertex<V>`, 要插入或更新的顶点


### class IllegalEdgeException
#### func init
```
init(message: String)
```
- 描述: 构造函数，初始化异常信息
- 参数:
  - `message`: `String`, 异常信息


### interface LocalGraphStorage<V, E>

### class NodeContainer<V, E>
#### func addIncomingEdge
```
func addIncomingEdge(e: Edge<E>): Unit
```
- 描述: 添加入边
- 参数:
  - `e`: `Edge<E>`, 边

#### func addOutgoingEdge
```
func addOutgoingEdge(e: Edge<E>): Unit
```
- 描述: 添加出边
- 参数:
  - `e`: `Edge<E>`, 边

#### prop incoming
```
prop incoming: Set<Edge<E>>
```
- 描述: 获取入边集合

#### prop outgoing
```
prop outgoing: Set<Edge<E>>
```
- 描述: 获取出边集合

#### func removeIncomingEdge
```
func removeIncomingEdge(e: Edge<E>): Unit
```
- 描述: 移除入边
- 参数:
  - `e`: `Edge<E>`, 边

#### func removeOutgoingEdge
```
func removeOutgoingEdge(e: Edge<E>): Unit
```
- 描述: 移除出边
- 参数:
  - `e`: `Edge<E>`, 边

#### prop vertex
```
mut prop vertex: Vertex<V>
```
- 描述: 获取或设置顶点


### class Vertex<V>
#### func operator !=
```
operator func !=(other: Vertex<V>): Bool
```
- 描述: 判断两个顶点是否不相等
- 参数:
  - `other`: `Vertex<V>`, 另一个顶点

#### func operator ==
```
operator func ==(other: Vertex<V>): Bool
```
- 描述: 判断两个顶点是否相等
- 参数:
  - `other`: `Vertex<V>`, 另一个顶点

#### prop data
```
prop data: Option<V>
```
- 描述: 获取顶点数据

#### func deserialize
```
static func deserialize(dm: DataModel): Vertex<V>
```
- 描述: 反序列化顶点
- 参数:
  - `dm`: `DataModel`, 数据模型

#### func fromJsonString
```
static func fromJsonString(str: String): Vertex<V>
```
- 描述: 从JSON字符串中解析顶点
- 参数:
  - `str`: `String`, JSON字符串

#### func hashCode
```
func hashCode(): Int64
```
- 描述: 计算顶点的哈希值

#### prop id
```
prop id: String
```
- 描述: 获取顶点ID

#### func init
```
init(id: String, vType!: String = "DEFAULT", data!: Option<V> = None)
```
- 描述: 构造函数，初始化顶点
- 参数:
  - `id`: `String`, 顶点ID
  - `vType`: `String`, 顶点类型，默认为"DEFAULT"
  - `data`: `Option<V>`, 顶点数据，默认为None

#### func serialize
```
func serialize(): DataModel
```
- 描述: 序列化顶点

#### func toJsonString
```
func toJsonString(): String
```
- 描述: 将顶点转换为JSON字符串

#### prop vType
```
prop vType: String
```
- 描述: 获取顶点类型


