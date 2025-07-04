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
- Description: A static variable that holds a function to be called after agent run.

#### var AFTER_TOOL_CALL_FN
```
static var AFTER_TOOL_CALL_FN: Option<(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>>
```
- Description: A static variable that holds a function to be called after tool call.

#### var BEFORE_AGENT_RUN_FN
```
static var BEFORE_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Option<AgentResponse>>
```
- Description: A static variable that holds a function to be called before agent run.

#### var BEFORE_CHAT_MODEL_FN
```
static var BEFORE_CHAT_MODEL_FN: Option<(ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- Description: A static variable that holds a function to be called before chat model processing.

#### var BEFORE_CHAT_MODEL_FN2
```
static var BEFORE_CHAT_MODEL_FN2: Option<(String, ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- Description: A static variable that holds a function to be called before chat model processing, with an additional String parameter.

#### var BEFORE_TOOL_CALL_FN
```
static var BEFORE_TOOL_CALL_FN: Option<(Agent, ToolRequest) -> Option<ToolResponse>>
```
- Description: A static variable that holds a function to be called before tool call.

#### func registerAfterAgentRun
```
static func registerAfterAgentRun(fn: (Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>)
```
- Description: Registers a function to be called after agent run.
- Parameters:
  - `fn`: `(Agent, AgentRequest, AgentResponse) -> Option<AgentResponse>`, The function to register.

#### func registerAfterToolCall
```
static func registerAfterToolCall(fn: (Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>)
```
- Description: Registers a function to be called after tool call.
- Parameters:
  - `fn`: `(Agent, ToolRequest, ToolResponse) -> Option<ToolResponse>`, The function to register.

#### func registerBeforeAgentRun
```
static func registerBeforeAgentRun(fn: (Agent, AgentRequest) -> Option<AgentResponse>)
```
- Description: Registers a function to be called before agent run.
- Parameters:
  - `fn`: `(Agent, AgentRequest) -> Option<AgentResponse>`, The function to register.

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- Description: Registers a function to be called before chat model processing.
- Parameters:
  - `fn`: `(ChatModel, ChatRequest) -> Option<ChatResponse>`, The function to register.

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (String, ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- Description: Registers a function to be called before chat model processing, with an additional String parameter.
- Parameters:
  - `fn`: `(String, ChatModel, ChatRequest) -> Option<ChatResponse>`, The function to register.

#### func registerBeforeToolCall
```
static func registerBeforeToolCall(fn: (Agent, ToolRequest) -> Option<ToolResponse>)
```
- Description: Registers a function to be called before tool call.
- Parameters:
  - `fn`: `(Agent, ToolRequest) -> Option<ToolResponse>`, The function to register.


