package magic.storage.vdb

import magic.vdb.{SimpleIndexMap, VectorBuilder, InMemoryVectorDatabase, Vector}
import magic.core.model.EmbeddingModel
import magic.storage.kv.*
import magic.storage.LocalStorage
import magic.core.rag.Document
import magic.utils.{exists, removeIfExists}
import std.sync.*
import std.fs.{Path, Directory}
import std.collection.*
import encoding.json.*
import std.convert.Parsable

public class JsonMemroyVectorStorage <: LocalVectorStorage {
    private let _workspace: String
    private let _collection: String
    private let _index_path: String
    private let _vector_builder: VectorBuilder
    private let _lock: ReentrantReadWriteMutex = ReentrantReadWriteMutex()
    private let _embed_model: EmbeddingModel
    private var _index: SimpleIndexMap
    private let _invert_index: HashMap<String, Int64> = HashMap()
    private var _vdb: InMemoryVectorDatabase
    private let _vdb_storage: JsonKVStorage<Array<Float64>>

    public init(embeddingModel: EmbeddingModel, workspace!: String = ".storage", collection!: String = "default") {
        this._workspace = workspace
        this._collection = collection.toAsciiLower()
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
        this._vdb = InMemoryVectorDatabase()
        this._index = SimpleIndexMap.load(this._index_path)
        this._vdb_storage = JsonKVStorage(workspace: this._workspace, collection: "${this._collection}_vector")
        var i = 0
        while (let Some(vec) <- this._vdb_storage.get(i.toString())) {
            this._vdb.addVector(Vector(vec))
            let doc = Document.fromJsonValue(JsonValue.fromStr(this._index.get(i)))
            this._invert_index.put(doc.id, i)
            i++
        }
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
            this._vdb_storage.commit()
            this._index.save(this._index_path)
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func close(): Unit {
        try {
            _lock.writeMutex.lock()
            this._vdb_storage.close()
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func reset(): Unit {
        try {
            _lock.writeMutex.lock()
            removeIfExists(this._index_path)
            this._index = SimpleIndexMap()
            this._index.save(this._index_path)
            this._invert_index.clear()
            this._vdb = InMemoryVectorDatabase()
            this._vdb_storage.reset()
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
                offsets |> map({sr => this._index.get(sr.index)}) |> map(
                    {str => Document.fromJsonValue(JsonValue.fromStr(str))}))
        } finally {
            _lock.readMutex.unlock()
        }
    }

    public func queryWithScore(query: String, topK: Int64, threshold!: Float64 = 0.6): Array<(Document, Float64)> {
        try {
            _lock.readMutex.lock()
            let vec = this._vector_builder.createEmbeddingVector(query)
            let offsets = this._vdb.search(vec, number: topK, minDistance: threshold)
            collectArray(
                offsets |> map({sr => (this._index.get(sr.index), sr.dist)}) |> map(
                    {tuple => (Document.fromJsonValue(JsonValue.fromStr(tuple[0])), tuple[1])}))
        } finally {
            _lock.readMutex.unlock()
        }
    }

    public func add(doc: Document): Unit {
        try {
            _lock.writeMutex.lock()
            if (let Some(offset) <- this._invert_index.get(doc.id)) {
                let docInDb = Document.fromJsonValue(JsonValue.fromStr(this._index.get(offset)))
                if (docInDb == doc) {
                    return
                }
                // doc changed, refresh doc value in index.
                this._index.set(offset, doc.toJsonValue().toString())
                if (docInDb.content == doc.content) {
                    return
                }
                let vec = this._vector_builder.createEmbeddingVector(doc.content)
                this._vdb.setVector(offset, vec)
                this._vdb_storage.upsert(offset.toString(), vec.vector)
            } else {
                let vec = this._vector_builder.createEmbeddingVector(doc.content)
                this._vdb.addVector(vec)
                this._index.add(doc.toJsonValue().toString())
                let offset = this._vdb_storage.insertInc(vec.vector)
                this._invert_index.put(doc.id, Int64.parse(offset))
            }
        } finally {
            _lock.writeMutex.unlock()
        }
    }
}
