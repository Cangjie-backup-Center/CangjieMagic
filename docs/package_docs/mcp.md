## Package mcp
- [Package mcp](#package-mcp)
  - [interface MCPClient](#interface-mcpclient)
    - [func callTool](#func-calltool)
    - [func callTool](#func-calltool-1)
    - [func getTools](#func-gettools)
  - [class SseMCPClient](#class-ssemcpclient)
    - [func init](#func-init)
  - [class StdioMCPClient](#class-stdiomcpclient)
    - [func init](#func-init-1)
  - [class StdioMCPServer](#class-stdiomcpserver)
    - [func init](#func-init-1)
    - [func start](#func-start)
    - [func startWith](#func-startwith)
    - [func startWith](#func-startwith-1)
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
- Description: Calls a tool with the specified name and arguments.
- Parameters:
  - `name`: `String`, The name of the tool to call.
  - `args`: `Array<(String, ToJsonValue)>`, The arguments to pass to the tool.

#### func callTool
```
func callTool(name: String, args: Array<(String, JsonValue)>): ToolResponse
```
- Description: Calls a tool with the specified name and arguments.
- Parameters:
  - `name`: `String`, The name of the tool to call.
  - `args`: `Array<(String, JsonValue)>`, The arguments to pass to the tool.

#### func getTools
```
func getTools(): Array<Tool>
```
- Description: Retrieves a list of available tools.


### class SseMCPClient
#### func init
```
init(url: String)
```
- Description: Initializes the SSE MCP client with the provided URL
- Parameters:
  - `url`: `String`, The URL to initialize the client with


### class StdioMCPClient
#### func init
```
init(command: String, args: Array<String>, env: Array<(String, String)> = [])
```
- Description: Initializes the StdioMCPClient with the specified command, arguments, and environment variables.
- Parameters:
  - `command`: `String`, The command to start the MCP server process.
  - `args`: `Array<String>`, The arguments to pass to the MCP server process.
  - `env`: `Array<(String, String)>`, The environment variables for the MCP server process. Defaults to an empty array.


### class StdioMCPServer
#### func init
```
init(tools: Array<Tool>)
```
- Description: Initialize the StdioMCPServer with an array of tools.
- Parameters:
  - `tools`: `Array<Tool>`, An array of tools to initialize the server.

#### func start
```
func start(): Unit
```
- Description: Start the server by initializing it and entering the loop.

#### func startWith
```
static func startWith(agents: Array<Agent>): Unit
```
- Description: Merge all tools of each agent and start a MCP server for these tools.
- Parameters:
  - `agents`: `Array<Agent>`, An array of agents whose tools will be merged.

#### func startWith
```
static func startWith(tools: Array<Tool>): Unit
```
- Description: Start a MCP server for the provided tools.
- Parameters:
  - `tools`: `Array<Tool>`, An array of tools to start the server with.


### enum ToolCallContent
####  Image
```
Image(ImageContent)
```
- Description: Represents an image content in a tool call

####  Text
```
Text(TextContent)
```
- Description: Represents a text content in a tool call

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): ToolCallContent
```
- Description: Converts a JSON value to ToolCallContent
- Parameters:
  - `json`: `JsonValue`, The JSON value to convert

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- Description: Gets the type schema for ToolCallContent

#### func getValue
```
public func getValue(): String
```
- Description: Gets the string value of the tool call content

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- Description: Converts ToolCallContent to a JSON value


