## Package tool
- [Package tool](#package-tool)
  - [class NativeFuncTool](#class-nativefunctool)
    - [func addExamples](#func-addexamples)
    - [prop description](#prop-description)
    - [prop examples](#prop-examples)
    - [func init](#func-init)
    - [func invoke](#func-invoke)
    - [prop name](#prop-name)
    - [prop parameters](#prop-parameters)
    - [prop retType](#prop-rettype)
  - [class RetrieverTool](#class-retrievertool)
    - [prop description](#prop-description-1)
    - [prop examples](#prop-examples-1)
    - [func init](#func-init-1)
    - [func invoke](#func-invoke-1)
    - [prop name](#prop-name-1)
    - [prop parameters](#prop-parameters-1)
    - [prop retType](#prop-rettype-1)
  - [class SimpleToolManager](#class-simpletoolmanager)
    - [func addTool](#func-addtool)
    - [func addTools](#func-addtools)
    - [func clear](#func-clear)
    - [func delTool](#func-deltool)
    - [prop enableFilter](#prop-enablefilter)
    - [func filterTool](#func-filtertool)
    - [func findTool](#func-findtool)
    - [func getTools](#func-gettools)
    - [func init](#func-init-1)
    - [func init](#func-init-1)

### class NativeFuncTool
#### func addExamples
```
public func addExamples(examples: Array<String>): Unit
```
- Description: Adds examples to the tool.
- Parameters:
  - `examples`: `Array<String>`, An array of example strings to add.

#### prop description
```
public prop description: String
```
- Description: Gets the description of the tool.

#### prop examples
```
public prop examples: Array<String>
```
- Description: Gets the examples of the tool.

#### func init
```
public init(name!: String, description!: String, parameters!: Array<(String, String, TypeSchema)> = [], retType!: TypeSchema = TypeSchema.Str, examples!: Array<String> = [], filterable!: Bool = true, terminal!: Bool = false, execFn!: Option<ExecFn> = None)
```
- Description: Initializes a new instance of NativeFuncTool with the specified parameters.
- Parameters:
  - `name`: `String`, The name of the tool.
  - `description`: `String`, A description of the tool.
  - `parameters`: `Array<(String, String, TypeSchema)>`, An array of tuples representing the parameters of the tool.
  - `retType`: `TypeSchema`, The return type schema of the tool.
  - `examples`: `Array<String>`, An array of example strings.
  - `filterable`: `Bool`, Indicates whether the tool is filterable.
  - `terminal`: `Bool`, Indicates whether the tool is terminal.
  - `execFn`: `Option<ExecFn>`, An optional execution function.

#### func invoke
```
override public func invoke(args: HashMap<String, JsonValue>): ToolResponse
```
- Description: Invokes the native function with the specified arguments.
- Parameters:
  - `args`: `HashMap<String, JsonValue>`, A map of arguments represented as JSON values.

#### prop name
```
public prop name: String
```
- Description: Gets the name of the tool.

#### prop parameters
```
public prop parameters: Array<ToolParameter>
```
- Description: Gets the parameters of the tool.

#### prop retType
```
public prop retType: TypeSchema
```
- Description: Gets the return type schema of the tool.


### class RetrieverTool
#### prop description
```
prop description: String
```
- Description: Returns the description of the tool. If the retriever's description is empty, it returns a default description.

#### prop examples
```
prop examples: Array<String>
```
- Description: Returns examples of tool usage.

#### func init
```
init(retriever: Retriever)
```
- Description: Initializes the RetrieverTool with a retriever instance.
- Parameters:
  - `retriever`: `Retriever`, The retriever instance to be used for searching.

#### func invoke
```
func invoke(args: HashMap<String, JsonValue>): ToolResponse
```
- Description: Invokes the tool with the provided arguments and returns a response.
- Parameters:
  - `args`: `HashMap<String, JsonValue>`, The arguments for the tool, including the query to search.

#### prop name
```
prop name: String
```
- Description: Returns the name of the tool.

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- Description: Returns the parameters required by the tool.

#### prop retType
```
prop retType: TypeSchema
```
- Description: Returns the return type schema of the tool.


### class SimpleToolManager
#### func addTool
```
override public func addTool(tool: Tool): Unit
```
- Description: Adds a tool to the manager.
- Parameters:
  - `tool`: `Tool`, The tool to be added.

#### func addTools
```
override public func addTools(tools: Array<Tool>): Unit
```
- Description: Adds multiple tools to the manager.
- Parameters:
  - `tools`: `Array<Tool>`, An array of tools to be added.

#### func clear
```
override public func clear(): Unit
```
- Description: Clears all tools from the manager.

#### func delTool
```
override public func delTool(tool: Tool): Unit
```
- Description: Removes a tool from the manager.
- Parameters:
  - `tool`: `Tool`, The tool to be removed.

#### prop enableFilter
```
override public prop enableFilter: Bool
```
- Description: Gets the current filter status.

#### func filterTool
```
override public func filterTool(question: String, config: ToolSearchConfig): Array<Tool>
```
- Description: Filters tools based on a question and configuration.
- Parameters:
  - `question`: `String`, The question used for filtering tools.
  - `config`: `ToolSearchConfig`, The configuration for tool search.

#### func findTool
```
override public func findTool(name: String): Option<Tool>
```
- Description: Finds a tool by its name.
- Parameters:
  - `name`: `String`, The name of the tool to find.

#### func getTools
```
override public func getTools(): Array<Tool>
```
- Description: Retrieves all tools in the manager.

#### func init
```
public init()
```
- Description: Initializes a SimpleToolManager with filter disabled by default.

#### func init
```
public init(tools: Collection<Tool>, enableFilter: Bool = false)
```
- Description: Initializes a SimpleToolManager with a collection of tools and an optional filter setting.
- Parameters:
  - `tools`: `Collection<Tool>`, A collection of tools to be managed.
  - `enableFilter`: `Bool`, A boolean flag to enable or disable tool filtering.


