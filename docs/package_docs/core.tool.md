## Package core.tool
- [Package core.tool](#package-core.tool)
  - [interface Tool](#interface-tool)
    - [prop description](#prop-description)
    - [prop examples](#prop-examples)
    - [prop extra](#prop-extra)
    - [func invoke](#func-invoke)
    - [prop name](#prop-name)
    - [prop parameters](#prop-parameters)
    - [prop retType](#prop-rettype)
  - [class ToolException](#class-toolexception)
    - [func init](#func-init)
    - [let reason](#let-reason)
  - [interface ToolManager](#interface-toolmanager)
    - [func addTool](#func-addtool)
    - [func addTools](#func-addtools)
    - [func clear](#func-clear)
    - [func delTool](#func-deltool)
    - [prop enableFilter](#prop-enablefilter)
    - [func filterTool](#func-filtertool)
    - [func findTool](#func-findtool)
    - [func getTools](#func-gettools)
  - [struct ToolParameter](#struct-toolparameter)
    - [let description](#let-description)
    - [func init](#func-init-1)
    - [let name](#let-name)
    - [let typeSchema](#let-typeschema)
  - [struct ToolRequest](#struct-toolrequest)
    - [func toString](#func-tostring)
  - [struct ToolResponse](#struct-toolresponse)
    - [let content](#let-content)
    - [func init](#func-init-1)
    - [let isError](#let-iserror)
  - [struct ToolSearchConfig](#struct-toolsearchconfig)

### interface Tool
#### prop description
```
prop description: String
```
- 描述: 工具的描述，LLM将根据描述选择工具

#### prop examples
```
prop examples: Array<String>
```
- 描述: 工具调用的示例，可选

#### prop extra
```
prop extra: HashMap<String, String>
```
- 描述: 额外的自定义属性

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 参数及其值分组在哈希表中
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 参数及其值的哈希表

#### prop name
```
prop name: String
```
- 描述: 工具的唯一标识符

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- 描述: 工具输入的类型模式

#### prop retType
```
prop retType: TypeSchema
```
- 描述: 工具的返回类型，目前未使用


### class ToolException
#### func init
```
init(reason: String)
```
- 描述: 初始化ToolException实例
- 参数:
  - `reason`: `String`, 异常原因描述

#### let reason
```
let reason: String
```
- 描述: 异常原因描述


### interface ToolManager
#### func addTool
```
func addTool(tool: Tool): Unit
```
- 描述: 添加一个新工具
- 参数:
  - `tool`: `Tool`, 要添加的工具

#### func addTools
```
func addTools(tools: Array<Tool>): Unit
```
- 描述: 添加多个新工具
- 参数:
  - `tools`: `Array<Tool>`, 要添加的工具列表

#### func clear
```
func clear(): Unit
```
- 描述: 删除所有工具

#### func delTool
```
func delTool(tool: Tool): Unit
```
- 描述: 删除一个工具（如果存在）
- 参数:
  - `tool`: `Tool`, 要删除的工具

#### prop enableFilter
```
prop enableFilter: Bool
```
- 描述: 是否启用工具语义搜索

#### func filterTool
```
func filterTool(question: String, config: ToolSearchConfig): Array<Tool>
```
- 描述: 根据问题搜索相关工具
- 参数:
  - `question`: `String`, 用户问题
  - `config`: `ToolSearchConfig`, 搜索配置

#### func findTool
```
func findTool(name: String): Option<Tool>
```
- 描述: 根据名称查找工具
- 参数:
  - `name`: `String`, 要查找的工具名称

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取所有工具


### struct ToolParameter
#### let description
```
let description: String
```
- 描述: 参数的描述

#### func init
```
public init(name: String, description: String, typeSchema: TypeSchema)
```
- 描述: 初始化ToolParameter
- 参数:
  - `name`: `String`, 参数的名称
  - `description`: `String`, 参数的描述
  - `typeSchema`: `TypeSchema`, 参数的类型模式

#### let name
```
let name: String
```
- 描述: 参数的名称

#### let typeSchema
```
let typeSchema: TypeSchema
```
- 描述: 参数的类型模式


### struct ToolRequest
#### func toString
```
override public func toString(): String
```
- 描述: 将ToolRequest对象转换为字符串表示形式


### struct ToolResponse
#### let content
```
let content: String
```
- 描述: 工具调用的结果内容

#### func init
```
init(content: String, isError: Bool = false)
```
- 描述: 初始化工具响应
- 参数:
  - `content`: `String`, 工具调用的结果内容
  - `isError`: `Bool`, 指示工具调用是否出错，默认为false

#### let isError
```
let isError: Bool
```
- 描述: 指示工具调用是否出错


### struct ToolSearchConfig

