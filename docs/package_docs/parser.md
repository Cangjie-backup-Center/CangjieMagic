## Package parser
- [Package parser](#package-parser)
  - [struct OutputParserUtils](#struct-outputparserutils)
    - [func extractFirstCode](#func-extractfirstcode)
    - [func extractLastCode](#func-extractlastcode)
    - [func extractLastSection](#func-extractlastsection)
    - [func parseToolRequest](#func-parsetoolrequest)
  - [class ParserException](#class-parserexception)
    - [func init](#func-init)
    - [let reason](#let-reason)

### struct OutputParserUtils
#### func extractFirstCode
```
public static func extractFirstCode(str: String, lang: String): Option<String>
```
- 描述: 从字符串中提取第一段指定语言的代码
- 参数:
  - `str`: `String`, 需要解析的字符串
  - `lang`: `String`, 目标代码的语言

#### func extractLastCode
```
public static func extractLastCode(str: String, lang: String): Option<String>
```
- 描述: 从字符串中提取最后一段指定语言的代码
- 参数:
  - `str`: `String`, 需要解析的字符串
  - `lang`: `String`, 目标代码的语言

#### func extractLastSection
```
public static func extractLastSection(str: String, section: String): Option<String>
```
- 描述: 从字符串中提取最后一个指定标记的段落内容
- 参数:
  - `str`: `String`, 需要解析的字符串
  - `section`: `String`, 段落标记名称

#### func parseToolRequest
```
public static func parseToolRequest(str: String): ToolRequest
```
- 描述: 解析工具请求字符串并返回ToolRequest对象
- 参数:
  - `str`: `String`, 需要解析的工具请求字符串


### class ParserException
#### func init
```
init(reason: String)
```
- 描述: 初始化解析异常
- 参数:
  - `reason`: `String`, 解析异常的原因

#### let reason
```
let reason: String
```
- 描述: 解析异常的原因


