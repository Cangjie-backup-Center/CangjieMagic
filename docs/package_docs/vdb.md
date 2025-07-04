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
  - [interface IndexMap](#interface-indexmap)
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
func addVector(vector: Vector): Unit
```
- Description: Adds a vector to the database.
- Parameters:
  - `vector`: `Vector`, The vector to be added to the database.

#### func close
```
func close(): Unit
```
- Description: Closes the database and releases all allocated resources.

#### func init
```
init(dimension: Int64 = 1536)
```
- Description: Initializes a new FaissVectorDatabase with the specified dimension.
- Parameters:
  - `dimension`: `Int64`, The dimension of the vectors to be stored in the database. Defaults to 1536.

#### func load
```
static func load(filePath: String): FaissVectorDatabase
```
- Description: Loads a FaissVectorDatabase from the specified file path.
- Parameters:
  - `filePath`: `String`, The path from which the database will be loaded.

#### func save
```
func save(filePath: String): Unit
```
- Description: Saves the database to the specified file path.
- Parameters:
  - `filePath`: `String`, The path where the database will be saved.

#### func search
```
func search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<SearchResult>
```
- Description: Searches the database for vectors similar to the query vector.
- Parameters:
  - `queryVec`: `Vector`, The query vector for which similar vectors are to be found.
  - `number`: `Int64`, The maximum number of results to return. Defaults to 5.
  - `minDistance`: `Float64`, The minimum distance threshold for results. Defaults to 0.6.


### class InMemoryVectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- Description: Adds a vector to the vector buffer and returns the index where it was stored.
- Parameters:
  - `vector`: `Vector`, The vector to be added.

#### func load
```
static func load(filePath: String): InMemoryVectorDatabase
```
- Description: Attempts to load the vector database from a file, but currently throws an UnsupportedException.
- Parameters:
  - `filePath`: `String`, The file path from which the vector database should be loaded.

#### func save
```
func save(filePath: String): Unit
```
- Description: Attempts to save the vector database to a file, but currently throws an UnsupportedException.
- Parameters:
  - `filePath`: `String`, The file path where the vector database should be saved.

#### func search
```
func search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<SearchResult>
```
- Description: Searches for the most similar vectors to the query vector based on cosine similarity.
- Parameters:
  - `queryVec`: `Vector`, The query vector for which similar vectors are to be found.
  - `number`: `Int64`, The number of most similar vectors to return.
  - `minDistance`: `Float64`, The minimum cosine similarity threshold for vectors to be considered similar.

#### func setVector
```
func setVector(index: Int64, vector: Vector): Unit
```
- Description: Sets a vector at the specified index in the vector buffer.
- Parameters:
  - `index`: `Int64`, The index where the vector will be stored.
  - `vector`: `Vector`, The vector to be stored.


### interface IndexMap
#### func add
```
func add(content: T): Unit
```
- Description: Adds content to the index map. The index is determined by the order in which it was added.
- Parameters:
  - `content`: `T`, The content to be added to the index map.

#### func get
```
func get(index: Int64): T
```
- Description: Retrieves the content at the specified index.
- Parameters:
  - `index`: `Int64`, The index of the content to retrieve.

#### func load
```
static func load(filePath: String): Self
```
- Description: Loads the index map from the specified file path.
- Parameters:
  - `filePath`: `String`, The file path from which the index map will be loaded.

#### func save
```
func save(filePath: String): Unit
```
- Description: Saves the index map to the specified file path.
- Parameters:
  - `filePath`: `String`, The file path where the index map will be saved.


### class JsonlIndexMap
#### func add
```
override public func add(content: T): Unit
```
- Description: Adds a content of type T to the JsonlIndexMap.
- Parameters:
  - `content`: `T`, The content to be added to the map.

#### func get
```
override public func get(index: Int64): T
```
- Description: Retrieves the content at the specified index.
- Parameters:
  - `index`: `Int64`, The index of the content to retrieve.

#### func init
```
public init()
```
- Description: Initializes a new JsonlIndexMap with an empty ArrayList.

#### func load
```
redef public static func load(filePath: String): JsonlIndexMap<T>
```
- Description: Loads a JsonlIndexMap from a file containing JSONL formatted data.
- Parameters:
  - `filePath`: `String`, The path of the file to load the JsonlIndexMap from.

#### func save
```
override public func save(filePath: String): Unit
```
- Description: Saves the contents of the JsonlIndexMap to a file in JSONL format.
- Parameters:
  - `filePath`: `String`, The path of the file where the contents will be saved.


### struct SearchResult
#### let dist
```
let dist: Float64
```
- Description: The distance of the search result

#### let index
```
let index: Int64
```
- Description: The index of the search result

#### func init
```
init(index: Int64, dist: Float64)
```
- Description: Initializes a new SearchResult with the given index and distance
- Parameters:
  - `index`: `Int64`, The index of the search result
  - `dist`: `Float64`, The distance of the search result


### class SemanticMap
#### func asRetriever
```
public func asRetriever(): Retriever
```
- Description: Converts the semantic map to a retriever

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- Description: Embedding model property with getter and setter

#### let indexMap
```
public let indexMap: IMAP
```
- Description: Index map instance

#### func init
```
public init(vectorDB: VDB, indexMap: IMAP, embeddingModel: Option<EmbeddingModel> = None)
```
- Description: Constructor for SemanticMap
- Parameters:
  - `vectorDB`: `VDB`, Vector database instance
  - `indexMap`: `IMAP`, Index map instance
  - `embeddingModel`: `Option<EmbeddingModel>`, Optional embedding model

#### func load
```
public static func load(dirPath: String): SemanticMap<VDB, IMAP, T>
```
- Description: Loads a semantic map from disk
- Parameters:
  - `dirPath`: `String`, Directory path to load from

#### func put
```
public func put(key: String, value: T): Unit
```
- Description: Adds a key-value pair to the semantic map
- Parameters:
  - `key`: `String`, Key string
  - `value`: `T`, Value to be stored

#### func save
```
public func save(dirPath: String): Unit
```
- Description: Saves the semantic map to disk
- Parameters:
  - `dirPath`: `String`, Directory path to save to

#### func search
```
public func search(query: String, number: Int64 = 5, minDistance: Float64 = 0.3): Array<T>
```
- Description: Find similar data
- Parameters:
  - `query`: `String`, Query string
  - `number`: `Int64`, Number of results to return
  - `minDistance`: `Float64`, Minimum distance threshold for results

#### let vectorDB
```
public let vectorDB: VDB
```
- Description: Vector database instance


### class SemanticSet
#### func asRetriever
```
public func asRetriever(): Retriever
```
- Description: Converts the SemanticSet into a Retriever.

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- Description: Gets or sets the embedding model used by the SemanticSet.

#### func init
```
public init(vectorDB!: VDB, indexMap!: IMAP, embeddingModel!: Option<EmbeddingModel> = None)
```
- Description: Initializes a new instance of SemanticSet with the specified vector database, index map, and optional embedding model.
- Parameters:
  - `vectorDB`: `VDB`, The vector database to be used.
  - `indexMap`: `IMAP`, The index map to be used.
  - `embeddingModel`: `Option<EmbeddingModel>`, The optional embedding model to be used.

#### func load
```
public static func load(dirPath: String): SemanticSet<VDB, IMAP, T>
```
- Description: Loads a SemanticSet from the specified directory.
- Parameters:
  - `dirPath`: `String`, The directory path from which the SemanticSet will be loaded.

#### func put
```
public func put(value: T): Unit
```
- Description: Adds a value to the SemanticSet.
- Parameters:
  - `value`: `T`, The value to be added.

#### func save
```
public func save(dirPath: String): Unit
```
- Description: Saves the SemanticSet to the specified directory.
- Parameters:
  - `dirPath`: `String`, The directory path where the SemanticSet will be saved.

#### func search
```
public func search(query: String, number!: Int64 = 5, minDistance!: Float64 = 0.3): Array<T>
```
- Description: Searches the SemanticSet for values matching the query.
- Parameters:
  - `query`: `String`, The query string to search for.
  - `number`: `Int64`, The maximum number of results to return.
  - `minDistance`: `Float64`, The minimum distance threshold for results.


### class SimpleIndexMap
#### func add
```
func add(content: String): Unit
```
- Description: Adds content to the next available index.
- Parameters:
  - `content`: `String`, The content to be added.

#### func deserialize
```
static func deserialize(dm: DataModel): SimpleIndexMap
```
- Description: Deserializes a DataModel into a SimpleIndexMap.
- Parameters:
  - `dm`: `DataModel`, The DataModel to be deserialized.

#### func get
```
func get(index: Int64): String
```
- Description: Retrieves the content at the specified index.
- Parameters:
  - `index`: `Int64`, The index from which the content will be retrieved.

#### func load
```
static func load(filePath: String): SimpleIndexMap
```
- Description: Loads a SimpleIndexMap from a file.
- Parameters:
  - `filePath`: `String`, The path of the file from which the SimpleIndexMap will be loaded.

#### func save
```
func save(filePath: String): Unit
```
- Description: Saves the SimpleIndexMap to a file.
- Parameters:
  - `filePath`: `String`, The path of the file where the SimpleIndexMap will be saved.

#### func serialize
```
func serialize(): DataModel
```
- Description: Serializes the SimpleIndexMap into a DataModel.

#### func set
```
func set(index: Int64, content: String): Unit
```
- Description: Sets the content at the specified index.
- Parameters:
  - `index`: `Int64`, The index where the content will be set.
  - `content`: `String`, The content to be set at the specified index.


### class Vector
#### func init
```
init(vec: Array<Float64>)
```
- Description: Initializes a new Vector instance with the given array of Float64 values
- Parameters:
  - `vec`: `Array<Float64>`, An array of Float64 values used to initialize the vector

#### let vector
```
let vector: Array<Float64>
```
- Description: A constant array of Float64 values representing the vector components


### class VectorBuilder
#### func createEmbeddingVector
```
func createEmbeddingVector(content: String): Vector
```
- Description: Creates an embedding vector from the given content.
- Parameters:
  - `content`: `String`, The input content to create the embedding vector from.


### interface VectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- Description: Add the vector to the database
- Parameters:
  - `vector`: `Vector`, The vector to be added to the database

#### func load
```
static func load(filePath: String): Self
```
- Description: Load from the file
- Parameters:
  - `filePath`: `String`, The file path to load the database from

#### func save
```
func save(filePath: String): Unit
```
- Description: Save to the file
- Parameters:
  - `filePath`: `String`, The file path to save the database

#### func search
```
func search(queryVec: Vector, number!: Int64, minDistance!: Float64): Array<SearchResult>
```
- Description: Query the database and find indexes of similar data
- Parameters:
  - `queryVec`: `Vector`, The query vector
  - `number!`: `Int64`, The number of results to return
  - `minDistance!`: `Float64`, The minimum distance threshold for results


