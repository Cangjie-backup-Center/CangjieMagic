## Package storage
- [Package storage](#package-storage)
  - [interface LocalStorage](#interface-localstorage)
    - [func close](#func-close)
    - [prop collection](#prop-collection)
    - [func commit](#func-commit)
    - [func reset](#func-reset)
    - [prop workspace](#prop-workspace)

### interface LocalStorage
#### func close
```
func close(): Unit
```
- 描述: 关闭当前存储连接

#### prop collection
```
prop collection: String
```
- 描述: 获取当前存储集合的名称

#### func commit
```
func commit(): Unit
```
- 描述: 提交所有未保存的更改

#### func reset
```
func reset(): Unit
```
- 描述: 重置存储状态

#### prop workspace
```
prop workspace: String
```
- 描述: 获取当前工作空间的路径


