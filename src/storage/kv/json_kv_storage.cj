package magic.storage.kv

import magic.storage.LocalStorage
import magic.utils.{readLines, writeLines, move, removeIfExists, exists, directoryOf}
import serialization.serialization.*
import std.fs.{Path, File, Directory}
import std.sync.*
import std.collection.*
import std.collection.concurrent.*
import encoding.json.*

public class JsonKVStorage<T> <: LocalKVStorage<T> where T <: Serializable<T> {
    private let _workspace: String
    private let _collection: String
    private let _storage_path: Path
    private let _lock = ReentrantReadWriteMutex()
    private var _data = HashMap<String, T>()

    public init(workspace!: String = ".storage", collection!: String = "default") {
        this._workspace = workspace
        this._collection = collection.toAsciiLower()
        this._storage_path = Path(this._workspace).join("${this._collection}_kv.jsonl")
        this.load()
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

    public func get(id: String): Option<T> {
        try {
            _lock.readMutex.lock()
            _data.get(id)
        } finally {
            _lock.readMutex.unlock()
        }
    }
    public func remove(id: String): Option<T> {
        try {
            _lock.writeMutex.lock()
            _data.remove(id)
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    /**
    使用自增的ID插入
     */
    public func insertInc(value: T): String {
        try {
            _lock.writeMutex.lock()
            let id = _data.size.toString()
            _data.put(id, value)
            return id
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func upsert(id: String, value: T): Unit {
        try {
            _lock.writeMutex.lock()
            _data.put(id, value)
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func commit(): Unit {
        try {
            _lock.writeMutex.lock()
            this._commit()
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    private func _commit(): Unit {
        let backup = directoryOf(_storage_path).join("${_collection}_kv.back")
        try {
            move(_storage_path, backup, true)
            File.create(_storage_path)
            var lines = _data |> map(
                    {
                        item =>
                        let dm = DataModelStruct()
                        dm.add(field<String>("id", item[0]))
                        dm.add(field<T>("data", item[1]))
                        return dm.toJson().toString()
                    }
                ) |>collectArray
            writeLines(_storage_path, lines)
        } catch (e: Exception) {
            removeIfExists(_storage_path)
            move(backup, _storage_path, true)
            throw Exception("Commit Failed!")
        } finally {
            removeIfExists(backup)
        }
    }

    private func load(): Unit {
        if (!exists(this._workspace)) {
            Directory.create(this._workspace, recursive: true)
        }
        if (!exists(this._storage_path)) {
            File.create(this._storage_path)
        }
        var lines = readLines(_storage_path)
        for (line in lines) {
            if (line.isEmpty()) {
                continue
            }
            let jsonValue = JsonValue.fromStr(line)
            let id = jsonValue.asObject().get("id").getOrThrow().asString().getValue()
            let dataModel = DataModel.fromJson(jsonValue.asObject().get("data").getOrThrow())
            let data = T.deserialize(dataModel)
            _data.put(id, data)
        }
    }

    public func reset(): Unit {
        try {
            _lock.writeMutex.lock()
            _data.clear()
            this._commit()
        } finally {
            _lock.writeMutex.unlock()
        }
    }

    public func close(): Unit {
        // TODO - ADD FILE LOCK
    }
}
