package magic.storage.vdb

@When[faiss == "enable"]
import magic.vdb.FaissVectorDatabase
import magic.vdb.{SimpleIndexMap, VectorBuilder}
import magic.core.model.EmbeddingModel
import magic.storage.kv.*
import magic.storage.LocalStorage
import magic.core.rag.Document
import std.sync.*
import std.fs.*
import std.collection.*
import encoding.json.*

@When[faiss == "enable"]
public class FaissVectorStorage <: LocalVectorStorage {
    private let _workspace: String
    private let _collection: String
    private let _vdb_path: String
    private let _index_path: String
    private let _vector_builder: VectorBuilder
    private let _lock: ReentrantReadWriteMutex = ReentrantReadWriteMutex()
    private let _embed_model: EmbeddingModel
    private let _index: SimpleIndexMap
    private let _vdb: FaissVectorDatabase

    public init(embeddingModel: EmbeddingModel, workspace!: String = ".storage", collection!: String = "default") {
        this._workspace = workspace
        this._collection = collection.toAsciiLower()
        this._vdb_path = Path(this._workspace).join("${this._collection}_vector.db").toString()
        this._index_path = Path(this._workspace).join("${this._collection}_vector.index").toString()
        this._vector_builder = VectorBuilder(model: embeddingModel)
        this._embed_model = embeddingModel
        // load
        if (!exists(this._workspace)) {
            Directory.create(this._workspace, recursive: true)
        }
        if (!exists(this._index_path)) {
            SimpleIndexMap().save(this._index_path)
        }
        if (!exists(this._vdb_path)) {
            FaissVectorDatabase().save(this._vdb_path)
        }
        this._vdb = FaissVectorDatabase.load(this._vdb_path)
        this._index = SimpleIndexMap.load(this._index_path)
    }

    public prop workspace: String {
        get() {
            this._workspace
        }
    }

    public prop collection: String {
        get() {
            this.collection
        }
    }

    public prop embeddingModel: EmbeddingModel {
        get() {
            this._embed_model
        }
    }

    public func commit(): Unit {
        try {
            _lock.writeMutex.lock()
            this._vdb.save(this._vdb_path)
            this._index.save(this._index_path)
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func close(): Unit {
        try {
            _lock.writeMutex.lock()
            this._vdb.close()
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func reset(): Unit {
        try {
            _lock.writeMutex.lock()
            removeIfExists(this._index_path)
            SimpleIndexMap().save(this._index_path)
            removeIfExists(this._vdb_path)
            FaissVectorDatabase().save(this._vdb_path)
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func query(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<Document> {
        try {
            _lock.readMutex.lock()
            let vec = this._vector_builder.createEmbeddingVector(query)
            let offsets = this._vdb.search(vec, number: topK, minDistance: threshold)
            collectArray(
                offsets |> map({idx => this._index.get(idx)}) |> map(
                {str => Document.fromJsonValue(JsonValue.fromStr(str))}))
        } finally {
            _lock.readMutex.unlock()
        }
    }

    public func add(doc: Document): Unit {
        try {
            _lock.writeMutex.lock()
            let vec = this._vector_builder.createEmbeddingVector(doc.content)
            this._vdb.addVector(vec)
            this._index.add(doc.toJsonValue().toString())
        } finally {
            _lock.writeMutex.unlock()
        }
    }
}
