## Package core.agent
- [Package core.agent](#package-core.agent)
  - [interface Agent](#interface-agent)
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat)
    - [prop description](#prop-description)
    - [prop executor](#prop-executor)
    - [prop interceptor](#prop-interceptor)
    - [prop memory](#prop-memory)
    - [prop model](#prop-model)
    - [prop name](#prop-name)
    - [prop retriever](#prop-retriever)
    - [prop systemPrompt](#prop-systemprompt)
    - [prop temperature](#prop-temperature)
    - [prop toolManager](#prop-toolmanager)
  - [class AgentExecutionException](#class-agentexecutionexception)
    - [func init](#func-init)
  - [class AgentExecutionInfo](#class-agentexecutioninfo)
    - [let dialog](#let-dialog)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [let retrievalInfo](#let-retrievalinfo)
    - [prop verboseInfo](#prop-verboseinfo)
  - [interface AgentExecutor](#interface-agentexecutor)
    - [func asyncRun](#func-asyncrun)
    - [func run](#func-run)
  - [struct AgentRequest](#struct-agentrequest)
    - [let dialog](#let-dialog-1)
    - [func init](#func-init-1)
    - [let question](#let-question)
    - [let verbose](#let-verbose)
  - [struct AgentResponse](#struct-agentresponse)
    - [let content](#let-content)
    - [let execInfo](#let-execinfo)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
  - [class AsyncAgentResponse](#class-asyncagentresponse)
    - [prop content](#prop-content)
    - [let execInfo](#let-execinfo-1)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [func next](#func-next)
  - [class Interceptor](#class-interceptor)
    - [func init](#func-init-1)
  - [enum InterceptorMode](#enum-interceptormode)
    - [enumeration Always](#enumeration-always)
    - [enumeration Conditional](#enumeration-conditional)
    - [enumeration Periodic](#enumeration-periodic)

### interface Agent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 查询代理并获取答案，以流的形式返回代理回复
- 参数:
  - `request`: `AgentRequest`, 代理请求对象

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 查询代理并获取答案，可能会抛出AgentExecutionException异常
- 参数:
  - `request`: `AgentRequest`, 代理请求对象

#### prop description
```
prop description: String
```
- 描述: 代理的功能描述

#### prop executor
```
mut prop executor: AgentExecutor
```
- 描述: 底层的代理执行器

#### prop interceptor
```
mut prop interceptor: Option<Interceptor>
```
- 描述: 设置代理拦截器

#### prop memory
```
mut prop memory: Option<Memory>
```
- 描述: 代理将使用的内存

#### prop model
```
mut prop model: ChatModel
```
- 描述: 代理将使用的聊天模型

#### prop name
```
prop name: String
```
- 描述: 代理的名称

#### prop retriever
```
mut prop retriever: Option<Retriever>
```
- 描述: 代理可以使用的检索器

#### prop systemPrompt
```
mut prop systemPrompt: String
```
- 描述: 代理的系统提示

#### prop temperature
```
mut prop temperature: Option<Float64>
```
- 描述: 代理传递给LLM的温度参数

#### prop toolManager
```
prop toolManager: ToolManager
```
- 描述: 代理可以使用的工具管理器


### class AgentExecutionException
#### func init
```
init(msg: String)
```
- 描述: 构造函数，用于创建AgentExecutionException实例
- 参数:
  - `msg`: `String`, 异常消息


### class AgentExecutionInfo
#### let dialog
```
let dialog: Dialog
```
- 描述: 代理执行过程中与LLM的内部对话历史

#### func init
```
public init()
```
- 描述: 初始化AgentExecutionInfo实例

#### func init
```
public init(dialog: Dialog)
```
- 描述: 使用指定的对话历史初始化AgentExecutionInfo实例
- 参数:
  - `dialog`: `Dialog`, 初始对话历史

#### let retrievalInfo
```
let retrievalInfo: ArrayList<RetrievalInfo>
```
- 描述: 执行过程中检索到的文档信息

#### prop verboseInfo
```
prop verboseInfo: Iterator<String>
```
- 描述: 仅在AgentRequest中设置verbose: true时访问此字段


### interface AgentExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步执行代理的运行方法
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理的运行方法
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求


### struct AgentRequest
#### let dialog
```
let dialog: Option<Dialog>
```
- 描述: 用户与代理之间的历史聊天记录

#### func init
```
public init(question: String, dialog!: Option<Dialog> = None, verbose!: Bool = false)
```
- 描述: 初始化AgentRequest结构体
- 参数:
  - `question`: `String`, 当前用户的问题
  - `dialog`: `Option<Dialog>`, 用户与代理之间的历史聊天记录，默认为None
  - `verbose`: `Bool`, 是否输出内部执行信息，默认为false

#### let question
```
let question: String
```
- 描述: 当前用户的问题

#### let verbose
```
let verbose: Bool
```
- 描述: 是否输出内部执行信息


### struct AgentResponse
#### let content
```
let content: String
```
- 描述: 执行结果

#### let execInfo
```
let execInfo: Option<AgentExecutionInfo>
```
- 描述: 执行过程中的内部信息

#### func init
```
public init(content: String)
```
- 描述: 初始化AgentResponse
- 参数:
  - `content`: `String`, 执行结果内容

#### func init
```
public init(content: String, execInfo!: AgentExecutionInfo)
```
- 描述: 初始化AgentResponse，包含执行信息
- 参数:
  - `content`: `String`, 执行结果内容
  - `execInfo`: `AgentExecutionInfo`, 执行过程中的内部信息


### class AsyncAgentResponse
#### prop content
```
public prop content: String
```
- 描述: 执行结果，这是一个同步方法，会等待执行器完成

#### let execInfo
```
let execInfo: Option<AgentExecutionInfo>
```
- 描述: 执行过程中的内部信息

#### func init
```
public init(chunks: Iterator<String>)
```
- 描述: 初始化AsyncAgentResponse
- 参数:
  - `chunks`: `Iterator<String>`, 字符串迭代器

#### func init
```
public init(chunks: Iterator<String>, execInfo!: Option<AgentExecutionInfo>)
```
- 描述: 初始化AsyncAgentResponse
- 参数:
  - `chunks`: `Iterator<String>`, 字符串迭代器
  - `execInfo`: `Option<AgentExecutionInfo>`, 执行信息

#### func next
```
override public func next(): Option<String>
```
- 描述: 获取下一个字符串块


### class Interceptor
#### func init
```
init(agent: Agent, mode!: InterceptorMode = InterceptorMode.Always)
```
- 描述: Interceptor的构造函数
- 参数:
  - `agent`: `Agent`, 拦截器关联的代理
  - `mode!`: `InterceptorMode`, 拦截器的模式，默认为InterceptorMode.Always


### enum InterceptorMode
####  Always
```
Always
```
- 描述: 总是拦截请求

####  Conditional
```
Conditional((AgentRequest) -> Bool)
```
- 描述: 当条件为真时拦截请求
- 参数:
  - `condition`: `(AgentRequest) -> Bool`, 拦截条件函数

####  Periodic
```
Periodic(Int64)
```
- 描述: 定期拦截请求
- 参数:
  - `interval`: `Int64`, 拦截间隔时间


