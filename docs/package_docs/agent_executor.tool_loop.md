## Package agent_executor.tool_loop
- [Package agent_executor.tool_loop](#package-agent_executor.tool_loop)
  - [class ToolLoopExecutor](#class-toolloopexecutor)
    - [func asyncRun](#func-asyncrun)
    - [func run](#func-run)

### class ToolLoopExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步执行代理任务并返回结果
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理任务并返回结果
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求


