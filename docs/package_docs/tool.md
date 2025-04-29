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
func addExamples(examples: Array<String>): Unit
```
- 描述: 添加示例
- 参数:
  - `examples`: `Array<String>`, 要添加的示例列表

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
init(name: String, description: String, parameters: Array<(String, String, TypeSchema)>, retType: TypeSchema, examples: Array<String>, filterable: Bool, execFn: Option<ExecFn>)
```
- 描述: 构造函数，初始化NativeFuncTool实例
- 参数:
  - `name`: `String`, 工具名称
  - `description`: `String`, 工具描述
  - `parameters`: `Array<(String, String, TypeSchema)>`, 工具参数列表
  - `retType`: `TypeSchema`, 返回类型
  - `examples`: `Array<String>`, 示例列表
  - `filterable`: `Bool`, 是否可过滤
  - `execFn`: `Option<ExecFn>`, 执行函数

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 调用工具函数
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 参数键值对

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


### class RetrieverTool
#### prop description
```
public prop description: String
```
- 描述: 获取工具描述

#### prop examples
```
public prop examples: Array<String>
```
- 描述: 获取示例列表

#### func init
```
public init(retriever: Retriever)
```
- 描述: 初始化RetrieverTool实例
- 参数:
  - `retriever`: `Retriever`, 检索器实例

#### func invoke
```
public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 执行检索操作
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 参数映射表

#### prop name
```
public prop name: String
```
- 描述: 获取工具名称

#### prop parameters
```
public prop parameters: Array<ToolParameter>
```
- 描述: 获取工具参数列表

#### prop retType
```
public prop retType: TypeSchema
```
- 描述: 获取返回类型


### class SimpleToolManager
#### func addTool
```
override public func addTool(tool: Tool): Unit
```
- 描述: 添加单个工具到管理器中
- 参数:
  - `tool`: `Tool`, 要添加的工具实例

#### func addTools
```
override public func addTools(tools: Array<Tool>): Unit
```
- 描述: 批量添加多个工具到管理器中
- 参数:
  - `tools`: `Array<Tool>`, 要添加的工具数组

#### func clear
```
override public func clear(): Unit
```
- 描述: 清空管理器中的所有工具

#### func delTool
```
override public func delTool(tool: Tool): Unit
```
- 描述: 从管理器中删除指定的工具
- 参数:
  - `tool`: `Tool`, 要删除的工具实例

#### prop enableFilter
```
override public prop enableFilter: Bool
```
- 描述: 获取当前是否启用了工具过滤器

#### func filterTool
```
override public func filterTool(question: String, config: ToolSearchConfig): Array<Tool>
```
- 描述: 根据问题和配置过滤工具
- 参数:
  - `question`: `String`, 用于过滤工具的问题文本
  - `config`: `ToolSearchConfig`, 工具搜索配置参数

#### func findTool
```
override public func findTool(name: String): Option<Tool>
```
- 描述: 根据名称查找工具
- 参数:
  - `name`: `String`, 要查找的工具名称

#### func getTools
```
override public func getTools(): Array<Tool>
```
- 描述: 获取管理器中的所有工具列表

#### func init
```
public init()
```
- 描述: 初始化SimpleToolManager实例，默认禁用过滤器

#### func init
```
public init(tools: Collection<Tool>, enableFilter!: Bool = false)
```
- 描述: 使用指定的工具集合和过滤器设置初始化SimpleToolManager实例
- 参数:
  - `tools`: `Collection<Tool>`, 工具集合，将被添加到管理器中
  - `enableFilter`: `Bool`, 是否启用工具过滤器，默认为false


