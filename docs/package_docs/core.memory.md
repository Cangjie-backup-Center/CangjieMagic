## Package core.memory
- [Package core.memory](#package-core.memory)
  - [interface Memory](#interface-memory)
    - [func search](#func-search)
    - [func update](#func-update)

### interface Memory
#### func search
```
func search(question: String): Array<String>
```
- 描述: 根据用户问题，在内存中查找相关内容
- 参数:
  - `question`: `String`, 用户问题

#### func update
```
func update(segment: String): Unit
```
- 描述: 更新内存
- 参数:
  - `segment`: `String`, 内存段


