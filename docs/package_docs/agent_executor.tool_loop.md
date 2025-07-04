## Package agent_executor.tool_loop
- [Package agent_executor.tool_loop](#package-agent_executor.tool_loop)
  - [class ToolLoopExecutor](#class-toolloopexecutor)
    - [func asyncRun](#func-asyncrun)
    - [prop name](#prop-name)
    - [func run](#func-run)

### class ToolLoopExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- Description: Executes the agent's task asynchronously and returns a future response.
- Parameters:
  - `agent`: `Agent`, The agent to be executed.
  - `request`: `AgentRequest`, The request containing the task details.

#### prop name
```
prop name: String
```
- Description: Returns the name of the executor as 'tool-loop'.

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- Description: Executes the agent's task synchronously and returns the response.
- Parameters:
  - `agent`: `Agent`, The agent to be executed.
  - `request`: `AgentRequest`, The request containing the task details.


