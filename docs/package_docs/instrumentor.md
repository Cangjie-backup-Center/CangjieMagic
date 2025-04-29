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
public static var AFTER_AGENT_RUN_FN: Option<(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>>
```
- 描述: 在Agent运行后调用的函数

#### var AFTER_TOOL_CALL_FN
```
public static var AFTER_TOOL_CALL_FN: Option<(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>>
```
- 描述: 在Tool调用后调用的函数

#### var BEFORE_AGENT_RUN_FN
```
public static var BEFORE_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Option<AgentResponse>>
```
- 描述: 在Agent运行前调用的函数

#### var BEFORE_CHAT_MODEL_FN
```
public static var BEFORE_CHAT_MODEL_FN: Option<(ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 在ChatModel处理请求前调用的函数

#### var BEFORE_CHAT_MODEL_FN2
```
public static var BEFORE_CHAT_MODEL_FN2: Option<(String, ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 在ChatModel处理请求前调用的函数，带有一个字符串参数

#### var BEFORE_TOOL_CALL_FN
```
public static var BEFORE_TOOL_CALL_FN: Option<(Agent, ToolRequest) -> Option<ToolResponse>>
```
- 描述: 在Tool调用前调用的函数

#### func registerAfterAgentRun
```
public static func registerAfterAgentRun(fn: (Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>)
```
- 描述: 注册在Agent运行后调用的函数
- 参数:
  - `fn`: `(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>`, 接收Agent、AgentRequest和AgentResponse并返回Option<AgentResponse>的函数

#### func registerAfterToolCall
```
public static func registerAfterToolCall(fn: (Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>)
```
- 描述: 注册在Tool调用后调用的函数
- 参数:
  - `fn`: `(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>`, 接收Agent、ToolRequest和ToolResponse并返回Option<ToolResponse>的函数

#### func registerBeforeAgentRun
```
public static func registerBeforeAgentRun(fn: (Agent, AgentRequest) -> Option<AgentResponse>)
```
- 描述: 注册在Agent运行前调用的函数
- 参数:
  - `fn`: `(Agent, AgentRequest) -> Option<AgentResponse>`, 接收Agent和AgentRequest并返回Option<AgentResponse>的函数

#### func registerBeforeChatModel
```
public static func registerBeforeChatModel(fn: (ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册在ChatModel处理请求前调用的函数
- 参数:
  - `fn`: `(ChatModel, ChatRequest) -> Option<ChatResponse>`, 接收ChatModel和ChatRequest并返回Option<ChatResponse>的函数

#### func registerBeforeChatModel
```
public static func registerBeforeChatModel(fn: (String, ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册在ChatModel处理请求前调用的函数，带有一个字符串参数
- 参数:
  - `fn`: `(String, ChatModel, ChatRequest) -> Option<ChatResponse>`, 接收String、ChatModel和ChatRequest并返回Option<ChatResponse>的函数

#### func registerBeforeToolCall
```
public static func registerBeforeToolCall(fn: (Agent, ToolRequest) -> Option<ToolResponse>)
```
- 描述: 注册在Tool调用前调用的函数
- 参数:
  - `fn`: `(Agent, ToolRequest) -> Option<ToolResponse>`, 接收Agent和ToolRequest并返回Option<ToolResponse>的函数


