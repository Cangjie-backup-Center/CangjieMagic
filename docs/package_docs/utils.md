## Package utils
- [Package utils](#package-utils)
  - [struct SqliteUtils](#struct-sqliteutils)
    - [let SQLITE_DONE](#let-sqlite_done)
    - [let SQLITE_ROW](#let-sqlite_row)
    - [func sqlBindDouble](#func-sqlbinddouble)
    - [func sqlBindInt](#func-sqlbindint)
    - [func sqlBindInt64](#func-sqlbindint64)
    - [func sqlBindNull](#func-sqlbindnull)
    - [func sqlBindParameterCount](#func-sqlbindparametercount)
    - [func sqlBindText](#func-sqlbindtext)
    - [func sqlBusyTimeout](#func-sqlbusytimeout)
    - [func sqlChanges](#func-sqlchanges)
    - [func sqlClearBindings](#func-sqlclearbindings)
    - [func sqlClose](#func-sqlclose)
    - [func sqlColumnBlob](#func-sqlcolumnblob)
    - [func sqlColumnBytes](#func-sqlcolumnbytes)
    - [func sqlColumnCount](#func-sqlcolumncount)
    - [func sqlColumnDecltype](#func-sqlcolumndecltype)
    - [func sqlColumnDouble](#func-sqlcolumndouble)
    - [func sqlColumnInt64](#func-sqlcolumnint64)
    - [func sqlColumnName](#func-sqlcolumnname)
    - [func sqlColumnText](#func-sqlcolumntext)
    - [func sqlColumnType](#func-sqlcolumntype)
    - [func sqlExec](#func-sqlexec)
    - [func sqlFinalize](#func-sqlfinalize)
    - [func sqlLastInsertRowid](#func-sqllastinsertrowid)
    - [func sqlOpen](#func-sqlopen)
    - [func sqlPrepare](#func-sqlprepare)
    - [func sqlReset](#func-sqlreset)
    - [func sqlSoftHeapLimit](#func-sqlsoftheaplimit)
    - [func sqlStep](#func-sqlstep)

### struct SqliteUtils
#### let SQLITE_DONE
```
static let SQLITE_DONE: Int32 = 101
```
- 描述: sqlite3_step() 已执行完成

#### let SQLITE_ROW
```
static let SQLITE_ROW: Int32 = 100
```
- 描述: sqlite3_step() 还未完成执行

#### func sqlBindDouble
```
static func sqlBindDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32, rValue: Float64): Int32
```
- 描述: 绑定Float64值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 参数索引
  - `rValue`: `Float64`, 要绑定的Float64值

#### func sqlBindInt
```
static func sqlBindInt(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int32): Int32
```
- 描述: 绑定Int32值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 参数索引
  - `iValue`: `Int32`, 要绑定的Int32值

#### func sqlBindInt64
```
static func sqlBindInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int64): Int32
```
- 描述: 绑定Int64值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 参数索引
  - `iValue`: `Int64`, 要绑定的Int64值

#### func sqlBindNull
```
static func sqlBindNull(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 绑定空值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 参数索引

#### func sqlBindParameterCount
```
static func sqlBindParameterCount(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取sql语句绑定参数数量
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针

#### func sqlBindText
```
static func sqlBindText(ppStmt: CPointer<CPointer<Unit>>, i: Int32, data: String)
```
- 描述: 绑定文本值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 参数索引
  - `data`: `String`, 要绑定的文本值

#### func sqlBusyTimeout
```
static func sqlBusyTimeout(ppDb: CPointer<CPointer<Unit>>, ms: Int32): Int32
```
- 描述: 设置超时毫秒数
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `ms`: `Int32`, 超时毫秒数

#### func sqlChanges
```
static func sqlChanges(ppDb: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取最近执行的sql语句的修改数量
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlClearBindings
```
static func sqlClearBindings(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 解除sql语句绑定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针

#### func sqlClose
```
static func sqlClose(ppDb: CPointer<CPointer<Unit>>): Int32
```
- 描述: 关闭数据库连接
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlColumnBlob
```
static func sqlColumnBlob(ppStmt: CPointer<CPointer<Unit>>, i: Int32): CPointer<Unit>
```
- 描述: 获取sql结果blob类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnBytes
```
static func sqlColumnBytes(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 获取sql结果指定列值的字节数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnCount
```
static func sqlColumnCount(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取sql结果列数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针

#### func sqlColumnDecltype
```
static func sqlColumnDecltype(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String
```
- 描述: 获取sql结果指定列声明的数据类型
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnDouble
```
static func sqlColumnDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Float64
```
- 描述: 获取sql结果指定Float64类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnInt64
```
static func sqlColumnInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int64
```
- 描述: 获取sql结果指定Int64类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnName
```
static func sqlColumnName(ppStmt: CPointer<CPointer<Unit>>, n: Int32): String
```
- 描述: 获取sql结果指定列名
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `n`: `Int32`, 列索引

#### func sqlColumnText
```
static func sqlColumnText(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String
```
- 描述: 获取sql结果指定文本类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlColumnType
```
static func sqlColumnType(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 获取sql结果指定列的数据类型
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针
  - `i`: `Int32`, 列索引

#### func sqlExec
```
static func sqlExec(ppDb: CPointer<CPointer<Unit>>, sql: String)
```
- 描述: 指定数据库执行sql命令
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `sql`: `String`, 要执行的SQL语句

#### func sqlFinalize
```
static func sqlFinalize(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 销毁sql语句对象，释放内存
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针

#### func sqlLastInsertRowid
```
static func sqlLastInsertRowid(ppDb: CPointer<CPointer<Unit>>): Int64
```
- 描述: 获取最近插入行的ID
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlOpen
```
static func sqlOpen(path: String): CPointer<CPointer<Unit>>
```
- 描述: 打开数据库db文件
- 参数:
  - `path`: `String`, 数据库文件路径

#### func sqlPrepare
```
static func sqlPrepare(ppDb: CPointer<CPointer<Unit>>, sql: String): CPointer<CPointer<Unit>>
```
- 描述: 预处理sql语句
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `sql`: `String`, 要预处理的SQL语句

#### func sqlReset
```
static func sqlReset(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 重置sql语句
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针

#### func sqlSoftHeapLimit
```
static func sqlSoftHeapLimit(n: Int32): Unit
```
- 描述: 设置堆内存上限
- 参数:
  - `n`: `Int32`, 堆内存上限值

#### func sqlStep
```
static func sqlStep(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 执行sql语句
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, 预处理语句指针


