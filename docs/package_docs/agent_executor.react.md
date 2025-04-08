## Package agent_executor.react
- [Package agent_executor.react](#package-agent_executor.react)
  - [class ReactDumper](#class-reactdumper)
    - [func dump](#func-dump)
    - [func init](#func-init)
    - [func init](#func-init-1)
  - [class ReactExecutor](#class-reactexecutor)
    - [func asyncRun](#func-asyncrun)
    - [func run](#func-run)

### class ReactDumper
#### func dump
```
dump(): Unit
```
- 描述: 打印详细的React内部信息用于调试

#### func init
```
init(asyncResponse: AsyncAgentResponse)
```
- 描述: 初始化ReactDumper，传入异步代理响应
- 参数:
  - `asyncResponse`: `AsyncAgentResponse`, 异步代理响应，包含执行信息

#### func init
```
init(chunks: Iterator<String>)
```
- 描述: 初始化ReactDumper，传入字符串迭代器
- 参数:
  - `chunks`: `Iterator<String>`, 字符串迭代器，用于读取内容


### class ReactExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 执行代理的异步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理实例
  - `request`: `AgentRequest`, 代理执行的请求参数

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理的同步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理实例
  - `request`: `AgentRequest`, 代理执行的请求参数


