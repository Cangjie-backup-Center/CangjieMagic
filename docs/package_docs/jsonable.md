## Package jsonable
- [Package jsonable](#package-jsonable)
  - [struct FieldSchema](#struct-fieldschema)
  - [interface Jsonable](#interface-jsonable)
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
    - [func toString](#func-tostring)

### struct FieldSchema

### interface Jsonable
#### func fromJsonValue
```
static func fromJsonValue(json: JsonValue): T
```
- Description: Deserializes an object of type T from a JsonValue.
- Parameters:
  - `json`: `JsonValue`, The JsonValue to deserialize from.

#### func getTypeSchema
```
static func getTypeSchema(): TypeSchema
```
- Description: Retrieves the type schema of the generic type T.


### class JsonableException
#### func init
```
public init(msg: String)
```
- Description: Constructs a JsonableException with the specified error message.
- Parameters:
  - `msg`: `String`, The error message describing the exception.


### interface ToJsonValue
#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- Description: Converts the implementing object to a JsonValue.


### enum TypeSchema
####  Arr
```
Arr(TypeSchema)
```
- Description: Represents an array type with elements of the specified TypeSchema.
- Parameters:
  - `TypeSchema`: `TypeSchema`, The type schema of the array elements.

####  Boolean
```
Boolean
```
- Description: Represents a boolean type.

####  Float
```
Float
```
- Description: Represents a floating-point type.

####  Int
```
Int
```
- Description: Represents an integer type.

####  Obj
```
Obj(Array<FieldSchema>)
```
- Description: Represents an object type with fields specified by an array of FieldSchema.
- Parameters:
  - `Array<FieldSchema>`: `Array<FieldSchema>`, An array of FieldSchema defining the object's fields.

####  Str
```
Str
```
- Description: Represents a string type.

#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- Description: Converts the TypeSchema to a JsonValue representation.

#### func toString
```
func toString(): String
```
- Description: Converts the TypeSchema to a string representation.


