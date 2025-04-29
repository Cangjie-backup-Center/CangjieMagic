## Package rag
- [Package rag](#package-rag)
  - [struct RetrieverUtils](#struct-retrieverutils)
    - [func createRetriever](#func-createretriever)
    - [func createRetriever](#func-createretriever-1)

### struct RetrieverUtils
#### func createRetriever
```
public static func createRetriever(agent: Agent, source: String, mode: Option<RetrieverMode>, description: Option<String>): Retriever
```
- 描述: 根据不同的数据源创建检索器
- 参数:
  - `agent`: `Agent`, 代理对象，包含模型信息
  - `source`: `String`, 数据源路径，可以是SQLite数据库路径或Markdown文件路径
  - `mode`: `Option<RetrieverMode>`, 检索模式选项
  - `description`: `Option<String>`, 检索器描述信息

#### func createRetriever
```
public static func createRetriever(_agent: Agent, source: Retriever, mode: Option<RetrieverMode>, description: Option<String>): Retriever
```
- 描述: 创建检索器包装器
- 参数:
  - `_agent`: `Agent`, 代理对象，包含模型信息
  - `source`: `Retriever`, 已存在的检索器对象
  - `mode`: `Option<RetrieverMode>`, 检索模式选项
  - `description`: `Option<String>`, 检索器描述信息


