## Package instrumentor
- [Package instrumentor](#package-instrumentor)
  - [class Instrumentor](#class-instrumentor)
    - [var AFTER_AGENT_RUN_FN](#var-after_agent_run_fn)
    - [var AFTER_TOOL_CALL_FN](#var-after_tool_call_fn)
    - [var BEFORE_AGENT_RUN_FN](#var-before_agent_run_fn)
    - [var BEFORE_CHAT_MODEL_FN](#var-before_chat_model_fn)
    - [var BEFORE_CHAT_MODEL_FN2](#var-before_chat_model_fn2)
    - [var BEFORE_TOOL_CALL_FN](#var-before_tool_call_fn)
    - [func registerAfterAgentRun](#func-registerafteragentrun)
    - [func registerAfterToolCall](#func-registeraftertoolcall)
    - [func registerBeforeAgentRun](#func-registerbeforeagentrun)
    - [func registerBeforeChatModel](#func-registerbeforechatmodel)
    - [func registerBeforeChatModel](#func-registerbeforechatmodel-1)
    - [func registerBeforeToolCall](#func-registerbeforetoolcall)

### class Instrumentor
#### var AFTER_AGENT_RUN_FN
```
static var AFTER_AGENT_RUN_FN: Option<(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>>
```
- 描述: 静态变量，用于存储Agent执行后的回调函数

#### var AFTER_TOOL_CALL_FN
```
static var AFTER_TOOL_CALL_FN: Option<(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>>
```
- 描述: 静态变量，用于存储工具调用后的回调函数

#### var BEFORE_AGENT_RUN_FN
```
static var BEFORE_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Option<AgentResponse>>
```
- 描述: 静态变量，用于存储Agent执行前的回调函数

#### var BEFORE_CHAT_MODEL_FN
```
static var BEFORE_CHAT_MODEL_FN: Option<(ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 静态变量，用于存储ChatModel执行前的回调函数

#### var BEFORE_CHAT_MODEL_FN2
```
static var BEFORE_CHAT_MODEL_FN2: Option<(String, ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 静态变量，用于存储带额外字符串参数的ChatModel执行前的回调函数

#### var BEFORE_TOOL_CALL_FN
```
static var BEFORE_TOOL_CALL_FN: Option<(Agent, ToolRequest) -> Option<ToolResponse>>
```
- 描述: 静态变量，用于存储工具调用前的回调函数

#### func registerAfterAgentRun
```
static func registerAfterAgentRun(fn: (Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>)
```
- 描述: 注册Agent执行后的回调函数
- 参数:
  - `fn`: `(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>`, 回调函数，接收Agent、AgentRequest和AgentResponse参数，返回Option<AgentResponse>

#### func registerAfterToolCall
```
static func registerAfterToolCall(fn: (Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>)
```
- 描述: 注册工具调用后的回调函数
- 参数:
  - `fn`: `(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>`, 回调函数，接收Agent、ToolRequest和ToolResponse参数，返回Option<ToolResponse>

#### func registerBeforeAgentRun
```
static func registerBeforeAgentRun(fn: (Agent, AgentRequest) -> Option<AgentResponse>)
```
- 描述: 注册Agent执行前的回调函数
- 参数:
  - `fn`: `(Agent, AgentRequest) -> Option<AgentResponse>`, 回调函数，接收Agent和AgentRequest参数，返回Option<AgentResponse>

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册ChatModel执行前的回调函数
- 参数:
  - `fn`: `(ChatModel, ChatRequest) -> Option<ChatResponse>`, 回调函数，接收ChatModel和ChatRequest参数，返回Option<ChatResponse>

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (String, ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册带额外字符串参数的ChatModel执行前的回调函数
- 参数:
  - `fn`: `(String, ChatModel, ChatRequest) -> Option<ChatResponse>`, 回调函数，接收String、ChatModel和ChatRequest参数，返回Option<ChatResponse>

#### func registerBeforeToolCall
```
static func registerBeforeToolCall(fn: (Agent, ToolRequest) -> Option<ToolResponse>)
```
- 描述: 注册工具调用前的回调函数
- 参数:
  - `fn`: `(Agent, ToolRequest) -> Option<ToolResponse>`, 回调函数，接收Agent和ToolRequest参数，返回Option<ToolResponse>


