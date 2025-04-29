## Package storage.kv
- [Package storage.kv](#package-storage.kv)
  - [class JsonKVStorage<T>](#class-jsonkvstorage<t>)
    - [func close](#func-close)
    - [prop collection](#prop-collection)
    - [func commit](#func-commit)
    - [func get](#func-get)
    - [func init](#func-init)
    - [func insertInc](#func-insertinc)
    - [func remove](#func-remove)
    - [func reset](#func-reset)
    - [func upsert](#func-upsert)
    - [prop workspace](#prop-workspace)
  - [interface KVStorage<T>](#interface-kvstorage<t>)
    - [func get](#func-get-1)
    - [func remove](#func-remove-1)
    - [func upsert](#func-upsert-1)
  - [interface LocalKVStorage<T>](#interface-localkvstorage<t>)

### class JsonKVStorage<T>
#### func close
```
public func close(): Unit
```
- 描述: 关闭存储

#### prop collection
```
public prop collection: String
```
- 描述: 获取当前存储的集合名称

#### func commit
```
public func commit(): Unit
```
- 描述: 提交当前的所有更改

#### func get
```
public func get(id: String): Option<T>
```
- 描述: 根据ID获取存储的值
- 参数:
  - `id`: `String`, 要获取的值的ID

#### func init
```
public init(workspace!: String = ".storage", collection!: String = "default")
```
- 描述: 初始化JsonKVStorage实例
- 参数:
  - `workspace`: `String`, 存储的工作目录，默认为".storage"
  - `collection`: `String`, 存储的集合名称，默认为"default"

#### func insertInc
```
public func insertInc(value: T): String
```
- 描述: 使用自增的ID插入值
- 参数:
  - `value`: `T`, 要插入的值

#### func remove
```
public func remove(id: String): Option<T>
```
- 描述: 根据ID移除存储的值
- 参数:
  - `id`: `String`, 要移除的值的ID

#### func reset
```
public func reset(): Unit
```
- 描述: 重置存储，清空所有数据

#### func upsert
```
public func upsert(id: String, value: T): Unit
```
- 描述: 更新或插入值
- 参数:
  - `id`: `String`, 要更新或插入的值的ID
  - `value`: `T`, 要更新或插入的值

#### prop workspace
```
public prop workspace: String
```
- 描述: 获取当前存储的工作目录


### interface KVStorage<T>
#### func get
```
func get(id: String): Option<T>
```
- 描述: 根据给定的ID获取存储的值
- 参数:
  - `id`: `String`, 要获取的值的唯一标识符

#### func remove
```
func remove(id: String): Option<T>
```
- 描述: 根据给定的ID移除存储的值
- 参数:
  - `id`: `String`, 要移除的值的唯一标识符

#### func upsert
```
func upsert(id: String, value: T): Unit
```
- 描述: 插入或更新存储的值
- 参数:
  - `id`: `String`, 要插入或更新的值的唯一标识符
  - `value`: `T`, 要存储的值


### interface LocalKVStorage<T>

