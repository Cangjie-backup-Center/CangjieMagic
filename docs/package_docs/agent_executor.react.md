## Package agent_executor.react
- [Package agent_executor.react](#package-agent_executor.react)
  - [class ReactExecutor](#class-reactexecutor)
    - [func asyncRun](#func-asyncrun)
    - [prop name](#prop-name)
    - [func run](#func-run)

### class ReactExecutor
#### func asyncRun
```
override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- Description: Executes the agent's task in an asynchronous manner.
- Parameters:
  - `agent`: `Agent`, The agent to be executed.
  - `request`: `AgentRequest`, The request containing the task details.

#### prop name
```
override public prop name: String
```
- Description: Gets the name of the executor.

#### func run
```
override public func run(agent: Agent, request: AgentRequest): AgentResponse
```
- Description: Executes the agent's task in a synchronous manner.
- Parameters:
  - `agent`: `Agent`, The agent to be executed.
  - `request`: `AgentRequest`, The request containing the task details.


