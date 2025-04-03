package magic.storage

public interface LocalStorage {
    prop workspace: String
    prop collection: String

    func commit(): Unit
    func close(): Unit
    func reset(): Unit
}