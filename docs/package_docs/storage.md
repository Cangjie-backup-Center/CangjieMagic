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
- Description: Closes the storage connection

#### prop collection
```
prop collection: String
```
- Description: Represents the collection name

#### func commit
```
func commit(): Unit
```
- Description: Commits changes to the storage

#### func reset
```
func reset(): Unit
```
- Description: Resets the storage to its initial state

#### prop workspace
```
prop workspace: String
```
- Description: Represents the workspace path


