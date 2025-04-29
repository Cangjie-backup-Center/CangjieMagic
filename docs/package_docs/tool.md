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
    - [prop enableFilter](#prop-enablesearch)
    - [func findTool](#func-findtool)
    - [func getTools](#func-gettools)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [func filterTool](#func-filtertool)

### class NativeFuncTool
#### func addExamples
```
public func addExamples(examples: Array<String>): Unit
```
- 描述: 添加工具的使用示例
- 参数:
  - `examples`: `Array<String>`, 要添加的使用示例

#### prop description
```
public prop description: String
```
- 描述: 获取工具的描述

#### prop examples
```
public prop examples: Array<String>
```
- 描述: 获取工具的使用示例

#### func init
```
public init(name: String, description: String, parameters: Array<(String, String, TypeSchema)>, retType: TypeSchema, examples: Array<String>, execFn: Option<ExecFn>)
```
- 描述: 初始化NativeFuncTool实例
- 参数:
  - `name`: `String`, 工具的名称
  - `description`: `String`, 工具的描述
  - `parameters`: `Array<(String, String, TypeSchema)>`, 工具的参数列表，每个参数包含名称、描述和类型
  - `retType`: `TypeSchema`, 工具的返回类型
  - `examples`: `Array<String>`, 工具的使用示例
  - `execFn`: `Option<ExecFn>`, 工具的执行函数

#### func invoke
```
public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 调用工具的执行函数
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 以Json字符串形式表示的参数

#### prop name
```
public prop name: String
```
- 描述: 获取工具的名称

#### prop parameters
```
public prop parameters: Array<ToolParameter>
```
- 描述: 获取工具的参数列表

#### prop retType
```
public prop retType: TypeSchema
```
- 描述: 获取工具的返回类型


### class RetrieverTool
#### prop description
```
prop description: String
```
- 描述: 获取工具描述

#### prop examples
```
prop examples: Array<String>
```
- 描述: 获取示例列表

#### func init
```
init(retriever: Retriever)
```
- 描述: 构造函数，初始化RetrieverTool
- 参数:
  - `retriever`: `Retriever`, 检索器实例

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 调用检索器工具进行搜索
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 参数映射，包含查询字符串

#### prop name
```
prop name: String
```
- 描述: 获取工具名称

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- 描述: 获取工具参数列表

#### prop retType
```
prop retType: TypeSchema
```
- 描述: 获取返回类型


### class SimpleToolManager
#### func addTool
```
func addTool(tool: Tool): Unit
```
- 描述: 添加一个工具到管理器
- 参数:
  - `tool`: `Tool`, 要添加的工具

#### func addTools
```
func addTools(tools: Array<Tool>): Unit
```
- 描述: 批量添加工具到管理器
- 参数:
  - `tools`: `Array<Tool>`, 要添加的工具数组

#### func clear
```
func clear(): Unit
```
- 描述: 清空管理器中的所有工具

#### func delTool
```
func delTool(tool: Tool): Unit
```
- 描述: 从管理器中删除一个工具
- 参数:
  - `tool`: `Tool`, 要删除的工具

#### prop enableFilter
```
prop enableFilter: Bool
```
- 描述: 获取是否启用了工具搜索功能

#### func findTool
```
func findTool(name: String): Option<Tool>
```
- 描述: 根据名称查找工具
- 参数:
  - `name`: `String`, 工具名称

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取管理器中的所有工具

#### func init
```
init()
```
- 描述: 初始化SimpleToolManager实例，默认禁用工具搜索功能

#### func init
```
init(tools: Collection<Tool>, enableFilter: Bool = false)
```
- 描述: 使用给定的工具集合和工具搜索启用标志初始化SimpleToolManager实例
- 参数:
  - `tools`: `Collection<Tool>`, 工具集合
  - `enableFilter`: `Bool`, 是否启用工具搜索功能

#### func filterTool
```
func filterTool(question: String, number: Int64 = 5): Array<Tool>
```
- 描述: 根据问题搜索相关工具
- 参数:
  - `question`: `String`, 搜索问题
  - `number`: `Int64`, 返回结果的最大数量


