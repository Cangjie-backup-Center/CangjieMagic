## Package agent_group
- [Package agent_group](#package-agent_group)
  - [interface AgentCollaboration](#interface-agentcollaboration)
  - [class FreeGroup](#class-freegroup)
    - [func chat](#func-chat)
    - [func chat](#func-chat-1)
    - [func discuss](#func-discuss)
    - [func init](#func-init)
    - [func operator []](#func-operator-[])
    - [func operator |](#func-operator-|)
  - [enum FreeGroupMode](#enum-freegroupmode)
    - [enumeration Auto](#enumeration-auto)
    - [enumeration RoundRobin](#enumeration-roundrobin)
  - [class LeaderGroup](#class-leadergroup)
    - [func []](#func-[])
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat-1)
    - [func chat](#func-chat-1)
  - [class LinearGroup](#class-lineargroup)
    - [func []](#func-[]-1)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func chat](#func-chat-1)

### interface AgentCollaboration

### class FreeGroup
#### func chat
```
chat(request: AgentRequest): AgentResponse
```
- 描述: 处理Agent请求，返回Agent响应
- 参数:
  - `request`: `AgentRequest`, Agent请求

#### func chat
```
chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理Agent请求，指定最大轮数，返回Agent响应
- 参数:
  - `request`: `AgentRequest`, Agent请求
  - `maxRound`: `Int64`, 最大讨论轮数

#### func discuss
```
discuss(topic: String, initiator: String, speech: String, mode: FreeGroupMode = FreeGroupMode.Auto, maxRound: Int64 = DISCUSSION_MAX_ROUND): String
```
- 描述: 根据指定模式和参数进行讨论，返回讨论结果
- 参数:
  - `topic`: `String`, 讨论主题
  - `initiator`: `String`, 发起者
  - `speech`: `String`, 发言内容
  - `mode`: `FreeGroupMode`, 讨论模式，默认为自动选择
  - `maxRound`: `Int64`, 最大讨论轮数，默认为DISCUSSION_MAX_ROUND

#### func init
```
init(a: Agent, b: Agent)
```
- 描述: 初始化FreeGroup，添加两个Agent成员
- 参数:
  - `a`: `Agent`, 第一个Agent成员
  - `b`: `Agent`, 第二个Agent成员

#### func operator operator []
```
operator [](memberName: String): Agent
```
- 描述: 通过成员名称访问Agent
- 参数:
  - `memberName`: `String`, 成员名称

#### func operator operator |
```
operator |(member: Agent): FreeGroup
```
- 描述: 添加Agent成员并返回FreeGroup
- 参数:
  - `member`: `Agent`, 要添加的Agent成员


### enum FreeGroupMode
####  Auto
```
Auto
```
- 描述: 由LLM自动选择发言者

####  RoundRobin
```
RoundRobin
```
- 描述: 轮询模式


### class LeaderGroup
#### func operator []
```
operator func [](memberName: String): Agent
```
- 描述: 通过成员名称获取对应的Agent对象
- 参数:
  - `memberName`: `String`, 成员名称

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理聊天请求并返回响应，可指定最大轮次
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象
  - `maxRound`: `Int64`, 最大聊天轮次


### class LinearGroup
#### func operator []
```
operator func [](memberName: String): Agent
```
- 描述: 获取指定名称的成员代理
- 参数:
  - `memberName`: `String`, 成员名称

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理聊天请求并返回响应，可指定最大轮数
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象
  - `maxRound`: `Int64`, 最大聊天轮数


