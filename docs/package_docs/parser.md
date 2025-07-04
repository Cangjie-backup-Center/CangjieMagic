## Package parser
- [Package parser](#package-parser)
  - [struct OutputParserUtils](#struct-outputparserutils)
    - [func extractFirstCode](#func-extractfirstcode)
    - [func extractLastCode](#func-extractlastcode)
    - [func parseToolRequest](#func-parsetoolrequest)
  - [class ParserException](#class-parserexception)
    - [func init](#func-init)
    - [let reason](#let-reason)

### struct OutputParserUtils
#### func extractFirstCode
```
public static func extractFirstCode(str: String, lang: String): Option<String>
```
- Description: Extracts the first code block from a string for a specified language.
- Parameters:
  - `str`: `String`, The input string containing the code blocks.
  - `lang`: `String`, The programming language of the code block to extract.

#### func extractLastCode
```
public static func extractLastCode(str: String, lang: String): Option<String>
```
- Description: Extracts the last code block from a string for a specified language.
- Parameters:
  - `str`: `String`, The input string containing the code blocks.
  - `lang`: `String`, The programming language of the code block to extract.

#### func parseToolRequest
```
public static func parseToolRequest(str: String): ToolRequest
```
- Description: Parses a tool request from a JSON string.
- Parameters:
  - `str`: `String`, The JSON string representing the tool request.


### class ParserException
#### func init
```
init(reason: String)
```
- Description: Initializes a new ParserException with the given reason
- Parameters:
  - `reason`: `String`, The reason for the parser exception

#### let reason
```
let reason: String
```
- Description: The reason for the parser exception


