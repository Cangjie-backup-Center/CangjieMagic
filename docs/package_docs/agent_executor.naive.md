## Package agent_executor.naive
- [Package agent_executor.naive](#package-agent_executor.naive)
  - [class NaiveExecutor](#class-naiveexecutor)
    - [func asyncRun](#func-asyncrun)
    - [func run](#func-run)

### class NaiveExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步执行代理任务，处理用户请求并返回异步响应
- 参数:
  - `agent`: `Agent`, 代理实例，包含代理的配置和行为
  - `request`: `AgentRequest`, 代理请求，包含用户的问题和其他相关信息

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 同步执行代理任务，处理用户请求并返回响应
- 参数:
  - `agent`: `Agent`, 代理实例，包含代理的配置和行为
  - `request`: `AgentRequest`, 代理请求，包含用户的问题和其他相关信息


