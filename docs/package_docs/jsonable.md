## Package jsonable
- [Package jsonable](#package-jsonable)
  - [struct FieldSchema](#struct-fieldschema)
  - [struct JsonUtils](#struct-jsonutils)
    - [func appendJsonObject](#func-appendjsonobject)
    - [func asJsonArray](#func-asjsonarray)
    - [func asJsonObject](#func-asjsonobject)
    - [func buildJsonArray](#func-buildjsonarray)
    - [func buildJsonObject](#func-buildjsonobject)
    - [func buildJsonObject](#func-buildjsonobject-1)
    - [func buildJsonObject](#func-buildjsonobject-1)
    - [func getBool](#func-getbool)
    - [func getFloat](#func-getfloat)
    - [func getInt](#func-getint)
    - [func getJsonArray](#func-getjsonarray)
    - [func getJsonObject](#func-getjsonobject)
    - [func getJsonValue](#func-getjsonvalue)
    - [func getString](#func-getstring)
    - [func toBool](#func-tobool)
    - [func toFloat](#func-tofloat)
    - [func toFloatArray](#func-tofloatarray)
    - [func toInt](#func-toint)
    - [func toString](#func-tostring)
  - [interface Jsonable<T>](#interface-jsonable<t>)
    - [func fromJsonValue](#func-fromjsonvalue)
    - [func getTypeSchema](#func-gettypeschema)
  - [class JsonableException](#class-jsonableexception)
    - [func init](#func-init)
  - [interface ToJsonValue](#interface-tojsonvalue)
    - [func toJsonValue](#func-tojsonvalue)
  - [enum TypeSchema](#enum-typeschema)
    - [enumeration Arr](#enumeration-arr)
    - [enumeration Boolean](#enumeration-boolean)
    - [enumeration Float](#enumeration-float)
    - [enumeration Int](#enumeration-int)
    - [enumeration Obj](#enumeration-obj)
    - [enumeration Str](#enumeration-str)
    - [func toJsonValue](#func-tojsonvalue-1)
    - [func toString](#func-tostring-1)

### struct FieldSchema

### struct JsonUtils
#### func appendJsonObject
```
public static func appendJsonObject(obj: JsonObject, items: Array<(String, String)>): JsonObject
```
- 描述: 向现有的JsonObject对象中添加键值对
- 参数:
  - `obj`: `JsonObject`, 目标JsonObject对象
  - `items`: `Array<(String, String)>`, 要添加的键值对数组

#### func asJsonArray
```
public static func asJsonArray(j: JsonValue): Option<JsonArray>
```
- 描述: 将JsonValue转换为JsonArray对象
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue

#### func asJsonObject
```
public static func asJsonObject(j: JsonValue): Option<JsonObject>
```
- 描述: 将JsonValue转换为JsonObject对象
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue

#### func buildJsonArray
```
public static func buildJsonArray(items: Array<String>): JsonArray
```
- 描述: 根据给定的字符串数组构建一个JsonArray对象
- 参数:
  - `items`: `Array<String>`, 字符串数组

#### func buildJsonObject
```
public static func buildJsonObject(key: String, value: String): JsonObject
```
- 描述: 根据给定的键值对构建一个JsonObject对象
- 参数:
  - `key`: `String`, 键名
  - `value`: `String`, 键值

#### func buildJsonObject
```
public static func buildJsonObject(items: Array<(String, String)>): JsonObject
```
- 描述: 根据给定的键值对数组构建一个JsonObject对象
- 参数:
  - `items`: `Array<(String, String)>`, 键值对数组

#### func buildJsonObject
```
public static func buildJsonObject(items: Array<(String, JsonValue)>): JsonObject
```
- 描述: 根据给定的键和JsonValue数组构建一个JsonObject对象
- 参数:
  - `items`: `Array<(String, JsonValue)>`, 键和JsonValue的数组

#### func getBool
```
public static func getBool(j: JsonValue, key: String): Option<Bool>
```
- 描述: 从JsonValue中获取指定键的布尔值
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func getFloat
```
public static func getFloat(j: JsonValue, key: String): Option<Float64>
```
- 描述: 从JsonValue中获取指定键的浮点数值
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func getInt
```
public static func getInt(key: String, j: JsonValue): Option<Int64>
```
- 描述: 从JsonValue中获取指定键的整数值
- 参数:
  - `key`: `String`, 键名
  - `j`: `JsonValue`, 源JsonValue

#### func getJsonArray
```
public static func getJsonArray(j: JsonValue, key: String): Option<JsonArray>
```
- 描述: 从JsonValue中获取指定键的JsonArray对象
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func getJsonObject
```
public static func getJsonObject(j: JsonValue, key: String): Option<JsonObject>
```
- 描述: 从JsonValue中获取指定键的JsonObject对象
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func getJsonValue
```
public static func getJsonValue(j: JsonValue, key: String): Option<JsonValue>
```
- 描述: 从JsonValue中获取指定键的值
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func getString
```
public static func getString(j: JsonValue, key: String): Option<String>
```
- 描述: 从JsonValue中获取指定键的字符串值
- 参数:
  - `j`: `JsonValue`, 源JsonValue
  - `key`: `String`, 键名

#### func toBool
```
public static func toBool(j: JsonValue): Option<Bool>
```
- 描述: 将JsonValue转换为布尔值
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue

#### func toFloat
```
public static func toFloat(j: JsonValue): Option<Float64>
```
- 描述: 将JsonValue转换为浮点数
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue

#### func toFloatArray
```
public static func toFloatArray(j: JsonArray): Array<Float64>
```
- 描述: 将JsonArray转换为浮点数数组
- 参数:
  - `j`: `JsonArray`, 要转换的JsonArray

#### func toInt
```
public static func toInt(j: JsonValue): Option<Int64>
```
- 描述: 将JsonValue转换为整数
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue

#### func toString
```
public static func toString(j: JsonValue): Option<String>
```
- 描述: 将JsonValue转换为字符串
- 参数:
  - `j`: `JsonValue`, 要转换的JsonValue


### interface Jsonable<T>
#### func fromJsonValue
```
static func fromJsonValue(json: JsonValue): T
```
- 描述: 从JsonValue反序列化为类型T的对象
- 参数:
  - `json`: `JsonValue`, 输入的Json值

#### func getTypeSchema
```
static func getTypeSchema(): TypeSchema
```
- 描述: 获取类型T的模式


### class JsonableException
#### func init
```
public init(msg: String)
```
- 描述: 构造一个Jsonable异常
- 参数:
  - `msg`: `String`, 异常信息


### interface ToJsonValue
#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- 描述: 将对象转换为JsonValue类型


### enum TypeSchema
####  Arr
```
Arr(TypeSchema)
```
- 描述: 数组类型
- 参数:
  - `ts`: `TypeSchema`, 数组元素的类型

####  Boolean
```
Boolean
```
- 描述: 布尔类型

####  Float
```
Float
```
- 描述: 浮点数类型

####  Int
```
Int
```
- 描述: 整数类型

####  Obj
```
Obj(Array<FieldSchema>)
```
- 描述: 对象类型
- 参数:
  - `fields`: `Array<FieldSchema>`, 对象的字段列表

####  Str
```
Str
```
- 描述: 字符串类型

#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- 描述: 将类型模式转换为JSON值

#### func toString
```
func toString(): String
```
- 描述: 将类型模式转换为字符串表示


