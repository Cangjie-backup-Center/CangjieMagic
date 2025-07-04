## Package agent_executor.naive
- [Package agent_executor.naive](#package-agent_executor.naive)
  - [class NaiveExecutor](#class-naiveexecutor)
    - [func asyncRun](#func-asyncrun)
    - [prop name](#prop-name)
    - [func run](#func-run)

### class NaiveExecutor
#### func asyncRun
```
public override func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- Description: Executes the agent's task asynchronously.
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
public override func run(agent: Agent, request: AgentRequest): AgentResponse
```
- Description: Executes the agent's task synchronously.
- Parameters:
  - `agent`: `Agent`, The agent to be executed.
  - `request`: `AgentRequest`, The request containing the task details.


