## Package agent
- [Package agent](#package-agent)
  - [class BaseAgent](#class-baseagent)
    - [prop description](#prop-description)
    - [prop executor](#prop-executor)
    - [func init](#func-init)
    - [prop interceptor](#prop-interceptor)
    - [prop memory](#prop-memory)
    - [prop model](#prop-model)
    - [prop name](#prop-name)
    - [prop retriever](#prop-retriever)
    - [prop systemPrompt](#prop-systemprompt)
    - [prop temperature](#prop-temperature)
    - [prop toolManager](#prop-toolmanager)
  - [class ConversationAgent](#class-conversationagent)
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat)
    - [func init](#func-init-1)
  - [class DispatchAgent](#class-dispatchagent)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class GroupAsAgent](#class-groupasagent)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class HumanAgent](#class-humanagent)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class ToolAgent<T>](#class-toolagent<t>)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class ToolSelectAgent](#class-toolselectagent)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
    - [func select](#func-select)

### class BaseAgent
#### prop description
```
override public prop description: String
```
- 描述: 获取代理的描述

#### prop executor
```
override public mut prop executor: AgentExecutor
```
- 描述: 获取或设置代理执行器

#### func init
```
public init(model!: ChatModel, name!: String = "Base Agent", description!: String = "", temperature!: Option<Float64> = None, systemPrompt!: String = "", toolManager!: ToolManager = SimpleToolManager(), executor!: Option<AgentExecutor> = None, retriever!: Option<Retriever> = None, memory!: Option<Memory> = None, interceptor!: Option<Interceptor> = None)
```
- 描述: 构造函数，用于初始化BaseAgent类的实例
- 参数:
  - `model`: `ChatModel`, 聊天模型，用于处理对话
  - `name`: `String`, 代理的名称，默认为"Base Agent"
  - `description`: `String`, 代理的描述，默认为空字符串
  - `temperature`: `Option<Float64>`, 温度参数，控制生成文本的随机性，默认为None
  - `systemPrompt`: `String`, 系统提示，默认为空字符串
  - `toolManager`: `ToolManager`, 工具管理器，默认为SimpleToolManager
  - `executor`: `Option<AgentExecutor>`, 代理执行器，默认为None
  - `retriever`: `Option<Retriever>`, 检索器，默认为None
  - `memory`: `Option<Memory>`, 记忆模块，默认为None
  - `interceptor`: `Option<Interceptor>`, 拦截器，默认为None

#### prop interceptor
```
override public mut prop interceptor: Option<Interceptor>
```
- 描述: 获取或设置拦截器

#### prop memory
```
override public mut prop memory: Option<Memory>
```
- 描述: 获取或设置记忆模块

#### prop model
```
override public mut prop model: ChatModel
```
- 描述: 获取或设置聊天模型

#### prop name
```
override public prop name: String
```
- 描述: 获取代理的名称

#### prop retriever
```
override public mut prop retriever: Option<Retriever>
```
- 描述: 获取或设置检索器

#### prop systemPrompt
```
override public mut prop systemPrompt: String
```
- 描述: 获取或设置系统提示

#### prop temperature
```
override public mut prop temperature: Option<Float64>
```
- 描述: 获取或设置温度参数，控制生成文本的随机性

#### prop toolManager
```
override public prop toolManager: ToolManager
```
- 描述: 获取工具管理器


### class ConversationAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并保存聊天消息
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并保存聊天消息
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象

#### func init
```
init(agent: Agent)
```
- 描述: 初始化ConversationAgent，将给定的Agent包装为能够保存聊天消息的对话代理
- 参数:
  - `agent`: `Agent`, 被包装的基础Agent对象


### class DispatchAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理用户请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 用户请求

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理用户请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 用户请求

#### func init
```
init(model: String)
```
- 描述: 初始化DispatchAgent实例
- 参数:
  - `model`: `String`, 模型名称


### class GroupAsAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求
- 参数:
  - `request`: `AgentRequest`, 代理请求

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求
- 参数:
  - `request`: `AgentRequest`, 代理请求

#### func init
```
init(group: AgentGroup, description!: String)
```
- 描述: 初始化GroupAsAgent实例
- 参数:
  - `group`: `AgentGroup`, 代理组
  - `description`: `String`, 描述信息


### class HumanAgent
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象

#### func init
```
init(qaFunc!: Option<(String) -> String> = None)
```
- 描述: 初始化HumanAgent实例
- 参数:
  - `qaFunc`: `Option<(String) -> String>`, 可选参数，用于处理问题的函数，默认为None


### class ToolAgent<T>
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象

#### func init
```
init(fn!: (String) -> T)
```
- 描述: 初始化ToolAgent实例
- 参数:
  - `fn`: `(String) -> T`, 用于回答问题的函数


### class ToolSelectAgent
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理代理请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 代理请求

#### func init
```
init(model: ChatModel, tools: Array<Tool>)
```
- 描述: 初始化工具选择代理
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `tools`: `Array<Tool>`, 可用工具列表

#### func select
```
func select(question: String): Option<ToolRequest>
```
- 描述: 根据问题选择合适的工具
- 参数:
  - `question`: `String`, 需要解决的问题


