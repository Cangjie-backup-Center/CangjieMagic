## Package parser
- [Package parser](#package-parser)
  - [struct OutputParserUtils](#struct-outputparserutils)
    - [func extractLastCode](#func-extractlastcode)
    - [func extractLastSection](#func-extractlastsection)
    - [func parseToolRequest](#func-parsetoolrequest)
  - [class ParserException](#class-parserexception)
    - [func init](#func-init)
    - [let reason](#let-reason)

### struct OutputParserUtils
#### func extractLastCode
```
public static func extractLastCode(str: String, lang: String): Option<String>
```
- 描述: 从字符串中提取最后一段指定语言的代码块
- 参数:
  - `str`: `String`, 输入的字符串
  - `lang`: `String`, 目标代码块的语言

#### func extractLastSection
```
public static func extractLastSection(str: String, section: String): ?String
```
- 描述: 从字符串中提取最后一个指定标记的段落
- 参数:
  - `str`: `String`, 输入的字符串
  - `section`: `String`, 目标段落的标记

#### func parseToolRequest
```
public static func parseToolRequest(str: String): ToolRequest
```
- 描述: 解析工具请求字符串为ToolRequest对象
- 参数:
  - `str`: `String`, 输入的JSON格式字符串


### class ParserException
#### func init
```
init(reason: String)
```
- 描述: 初始化解析异常
- 参数:
  - `reason`: `String`, 解析失败的原因

#### let reason
```
let reason: String
```
- 描述: 解析失败的原因


