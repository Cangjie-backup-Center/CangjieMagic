## Package tokenizer
- [Package tokenizer](#package-tokenizer)
  - [class AbstractBPETokenizer](#class-abstractbpetokenizer)
    - [func decode](#func-decode)
    - [func encode](#func-encode)
  - [class BPETokenizer](#class-bpetokenizer)
    - [func init](#func-init)
  - [struct BPETokenizerConfig](#struct-bpetokenizerconfig)
    - [func deserialize](#func-deserialize)
  - [class Cl100kTokenizer](#class-cl100ktokenizer)
    - [func init](#func-init-1)
  - [interface JsonDeserializable<T>](#interface-jsondeserializable<t>)
    - [func fromJson](#func-fromjson)
    - [func serialize](#func-serialize)
  - [class Pair<T>](#class-pair<t>)
    - [func !=](#func-!=)
    - [func ==](#func-==)
    - [func hashCode](#func-hashcode)
    - [func init](#func-init-1)
    - [prop left](#prop-left)
    - [prop right](#prop-right)
  - [struct TokenizerJson](#struct-tokenizerjson)
    - [func deserialize](#func-deserialize-1)
  - [class TokenizerLoader](#class-tokenizerloader)
    - [func load](#func-load)

### class AbstractBPETokenizer
#### func decode
```
public func decode(tokens: Array<UInt32>): String
```
- 描述: 将token数组解码为字符串
- 参数:
  - `tokens`: `Array<UInt32>`, 要解码的token数组

#### func encode
```
public func encode(input: String): Array<UInt32>
```
- 描述: 将字符串编码为token数组
- 参数:
  - `input`: `String`, 要编码的字符串


### class BPETokenizer
#### func init
```
init(modelPath: String)
```
- 描述: 初始化BPETokenizer，加载tokenizer配置
- 参数:
  - `modelPath`: `String`, 模型路径，用于加载tokenizer配置


### struct BPETokenizerConfig
#### func deserialize
```
static func deserialize(dm: DataModel): BPETokenizerConfig
```
- 描述: 从DataModel反序列化BPETokenizerConfig对象
- 参数:
  - `dm`: `DataModel`, 包含BPETokenizerConfig数据的DataModel


### class Cl100kTokenizer
#### func init
```
init(path: String)
```
- 描述: 初始化Cl100kTokenizer实例
- 参数:
  - `path`: `String`, 配置文件的路径


### interface JsonDeserializable<T>
#### func fromJson
```
static func fromJson(str: String)
```
- 描述: 从JSON字符串反序列化对象
- 参数:
  - `str`: `String`, JSON格式的字符串

#### func serialize
```
func serialize(): DataModel
```
- 描述: 将对象序列化为DataModel


### class Pair<T>
#### func operator !=
```
public operator func !=(other: Pair<T>): Bool
```
- 描述: 比较两个Pair是否不相等
- 参数:
  - `other`: `Pair<T>`, 要比较的另一个Pair

#### func operator ==
```
public operator func ==(other: Pair<T>): Bool
```
- 描述: 比较两个Pair是否相等
- 参数:
  - `other`: `Pair<T>`, 要比较的另一个Pair

#### func hashCode
```
public func hashCode(): Int64
```
- 描述: 计算Pair的哈希值

#### func init
```
public init(left: T, right: T)
```
- 描述: 初始化Pair对象
- 参数:
  - `left`: `T`, Pair的左值
  - `right`: `T`, Pair的右值

#### prop left
```
public prop left: T
```
- 描述: 获取Pair的左值

#### prop right
```
public prop right: T
```
- 描述: 获取Pair的右值


### struct TokenizerJson
#### func deserialize
```
static func deserialize(dm: DataModel): TokenizerJson
```
- 描述: 从DataModel反序列化TokenizerJson对象
- 参数:
  - `dm`: `DataModel`, 包含TokenizerJson数据的DataModel


### class TokenizerLoader
#### func load
```
public static func load(modelNameOrPath: String): Tokenizer
```
- 描述: 加载指定模型名称或路径的分词器
- 参数:
  - `modelNameOrPath`: `String`, 模型名称或路径


