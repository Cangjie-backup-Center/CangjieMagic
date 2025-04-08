## Package mcp
- [Package mcp](#package-mcp)
  - [interface MCPClient](#interface-mcpclient)
    - [func callTool](#func-calltool)
    - [func getTools](#func-gettools)
  - [class MCPServer](#class-mcpserver)
    - [func init](#func-init)
    - [func start](#func-start)
    - [func startWith](#func-startwith)
    - [func startWith](#func-startwith-1)
  - [class SseMCPClient](#class-ssemcpclient)
    - [func init](#func-init-1)
  - [class StdioMCPClient](#class-stdiomcpclient)
    - [func init](#func-init-1)
  - [enum ToolCallContent](#enum-toolcallcontent)
    - [enumeration Image](#enumeration-image)
    - [enumeration Text](#enumeration-text)
    - [func fromJsonValue](#func-fromjsonvalue)
    - [func getTypeSchema](#func-gettypeschema)
    - [func getValue](#func-getvalue)
    - [func toJsonValue](#func-tojsonvalue)

### interface MCPClient
#### func callTool
```
func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse
```
- 描述: 调用指定的工具并传入参数
- 参数:
  - `name`: `String`, 工具名称
  - `args`: `Array<(String, ToJsonValue)>`, 工具参数列表，每个参数是一个键值对

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取所有可用的工具列表


### class MCPServer
#### func init
```
init(tools: Array<Tool>)
```
- 描述: 初始化MCPServer实例
- 参数:
  - `tools`: `Array<Tool>`, 工具数组，用于初始化服务器

#### func start
```
func start(): Unit
```
- 描述: 启动服务器

#### func startWith
```
static func startWith(agents: Array<Agent>): Unit
```
- 描述: 合并每个代理的所有工具，并为这些工具启动一个MCP服务器
- 参数:
  - `agents`: `Array<Agent>`, 代理数组，用于获取工具并启动服务器

#### func startWith
```
static func startWith(tools: Array<Tool>): Unit
```
- 描述: 为工具启动一个MCP服务器
- 参数:
  - `tools`: `Array<Tool>`, 工具数组，用于启动服务器


### class SseMCPClient
#### func init
```
init(url: String)
```
- 描述: 初始化SSE MCP客户端
- 参数:
  - `url`: `String`, SSE连接的URL地址


### class StdioMCPClient
#### func init
```
init(command: String, args: Array<String>, env: Array<(String, String)> = [])
```
- 描述: 初始化StdioMCPClient实例
- 参数:
  - `command`: `String`, 启动MCP服务器的命令
  - `args`: `Array<String>`, 传递给MCP服务器的参数列表
  - `env`: `Array<(String, String)>`, 环境变量键值对数组，默认为空


### enum ToolCallContent
####  Image
```
Image(ImageContent)
```
- 描述: 表示图像类型的工具调用内容

####  Text
```
Text(TextContent)
```
- 描述: 表示文本类型的工具调用内容

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): ToolCallContent
```
- 描述: 从JSON值转换为ToolCallContent对象
- 参数:
  - `json`: `JsonValue`, 输入的JSON值

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- 描述: 获取类型模式，当前不支持此方法

#### func getValue
```
public func getValue(): String
```
- 描述: 获取工具调用内容的值

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- 描述: 将ToolCallContent对象转换为JSON值


