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
    - [func queryWithScore](#func-querywithscore)
    - [func reset](#func-reset)
    - [prop workspace](#prop-workspace)
  - [class JsonMemoryVectorStorage](#class-jsonmemoryvectorstorage)
    - [func add](#func-add-1)
    - [func close](#func-close-1)
    - [prop collection](#prop-collection-1)
    - [func commit](#func-commit-1)
    - [prop embeddingModel](#prop-embeddingmodel-1)
    - [func init](#func-init-1)
    - [func query](#func-query-1)
    - [func queryWithScore](#func-querywithscore-1)
    - [func reset](#func-reset-1)
    - [prop workspace](#prop-workspace-1)
  - [interface LocalVectorStorage](#interface-localvectorstorage)
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
- Description: Adds a document to the vector database.
- Parameters:
  - `doc`: `Document`, The document to add.

#### func close
```
func close(): Unit
```
- Description: Closes the vector database.

#### prop collection
```
prop collection: String
```
- Description: Gets the collection name.

#### func commit
```
func commit(): Unit
```
- Description: Commits changes to the vector database and index.

#### prop embeddingModel
```
prop embeddingModel: EmbeddingModel
```
- Description: Gets the embedding model.

#### func init
```
init(embeddingModel: EmbeddingModel, workspace: String = ".storage", collection: String = "default")
```
- Description: Initializes the FaissVectorStorage with the given embedding model, workspace path, and collection name.
- Parameters:
  - `embeddingModel`: `EmbeddingModel`, The embedding model to be used for vector creation.
  - `workspace`: `String`, The path to the workspace directory. Defaults to ".storage".
  - `collection`: `String`, The name of the collection. Defaults to "default".

#### func query
```
func query(query: String, topK: Int64, threshold: Float64 = 0.6): Array<Document>
```
- Description: Queries the vector database for documents similar to the given query string.
- Parameters:
  - `query`: `String`, The query string to search for.
  - `topK`: `Int64`, The number of top results to return.
  - `threshold`: `Float64`, The minimum similarity threshold for results. Defaults to 0.6.

#### func queryWithScore
```
func queryWithScore(query: String, topK: Int64, threshold: Float64 = 0.6): Array<(Document, Float64)>
```
- Description: Queries the vector database for documents similar to the given query string, including similarity scores.
- Parameters:
  - `query`: `String`, The query string to search for.
  - `topK`: `Int64`, The number of top results to return.
  - `threshold`: `Float64`, The minimum similarity threshold for results. Defaults to 0.6.

#### func reset
```
func reset(): Unit
```
- Description: Resets the vector database and index.

#### prop workspace
```
prop workspace: String
```
- Description: Gets the workspace path.


### class JsonMemoryVectorStorage
#### func add
```
public func add(doc: Document): Unit
```
- Description: Adds a document to the storage.
- Parameters:
  - `doc`: `Document`, The document to add.

#### func close
```
public func close(): Unit
```
- Description: Closes the storage.

#### prop collection
```
public prop collection: String
```
- Description: Gets the collection name.

#### func commit
```
public func commit(): Unit
```
- Description: Commits changes to the storage.

#### prop embeddingModel
```
public prop embeddingModel: EmbeddingModel
```
- Description: Gets the embedding model.

#### func init
```
public init(embeddingModel: EmbeddingModel, workspace!: String = ".storage", collection!: String = "default")
```
- Description: Initializes the JsonMemoryVectorStorage with the given embedding model, workspace, and collection.
- Parameters:
  - `embeddingModel`: `EmbeddingModel`, The embedding model to use for vector creation.
  - `workspace`: `String`, The workspace directory for storage. Defaults to '.storage'.
  - `collection`: `String`, The collection name. Defaults to 'default'.

#### func query
```
public func query(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<Document>
```
- Description: Queries the storage for documents matching the query string.
- Parameters:
  - `query`: `String`, The query string.
  - `topK`: `Int64`, The maximum number of documents to return.
  - `threshold`: `Float64`, The minimum similarity threshold. Defaults to 0.6.

#### func queryWithScore
```
public func queryWithScore(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<(Document, Float64)>
```
- Description: Queries the storage for documents matching the query string and returns them with their similarity scores.
- Parameters:
  - `query`: `String`, The query string.
  - `topK`: `Int64`, The maximum number of documents to return.
  - `threshold`: `Float64`, The minimum similarity threshold. Defaults to 0.6.

#### func reset
```
public func reset(): Unit
```
- Description: Resets the storage to its initial state.

#### prop workspace
```
public prop workspace: String
```
- Description: Gets the workspace directory.


### interface LocalVectorStorage

### interface VectorStorage
#### func add
```
func add(doc: Document): Unit
```
- Description: Adds a document to the vector storage
- Parameters:
  - `doc`: `Document`, The document to add to the storage

#### prop embeddingModel
```
prop embeddingModel: EmbeddingModel
```
- Description: The embedding model used for vector storage

#### func query
```
func query(query: String, topK: Int64, threshold!: Float64): Array<Document>
```
- Description: Queries the vector storage with a given query string and returns top K documents above the threshold
- Parameters:
  - `query`: `String`, The query string to search for
  - `topK`: `Int64`, The number of top documents to return
  - `threshold!`: `Float64`, The minimum similarity score threshold for documents to be returned

#### func queryWithScore
```
func queryWithScore(query: String, topK: Int64, threshold!: Float64): Array<(Document, Float64)>
```
- Description: Queries the vector storage with a given query string and returns top K documents with their scores above the threshold
- Parameters:
  - `query`: `String`, The query string to search for
  - `topK`: `Int64`, The number of top documents to return
  - `threshold!`: `Float64`, The minimum similarity score threshold for documents to be returned


