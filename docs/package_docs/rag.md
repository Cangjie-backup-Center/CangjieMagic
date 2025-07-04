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
- Description: Creates a retriever based on the specified source and parameters.
- Parameters:
  - `agent`: `Agent`, The agent to be used for the retriever.
  - `source`: `String`, The source of the retriever. Can be a SQLite path, SQLite path with table name, or a Markdown path.
  - `mode`: `Option<RetrieverMode>`, The mode of the retriever. If not specified, defaults to Static.
  - `description`: `Option<String>`, The description of the retriever. If not specified, a default description is used.

#### func createRetriever
```
public static func createRetriever(_agent: Agent, source: Retriever, mode: Option<RetrieverMode>, description: Option<String>): Retriever
```
- Description: Creates a retriever wrapper around an existing retriever.
- Parameters:
  - `_agent`: `Agent`, The agent to be used for the retriever.
  - `source`: `Retriever`, The existing retriever to be wrapped.
  - `mode`: `Option<RetrieverMode>`, The mode of the retriever. If not specified, defaults to Static.
  - `description`: `Option<String>`, The description of the retriever. If not specified, a default description is used.


