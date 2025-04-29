## Package agent_executor.react
- [Package agent_executor.react](#package-agent_executor.react)
  - [class ConsoleReactPrinter](#class-consolereactprinter)
    - [func dump](#func-dump)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [func print](#func-print)
  - [class ReactExecutor](#class-reactexecutor)
    - [func asyncRun](#func-asyncrun)
    - [func run](#func-run)

### class ConsoleReactPrinter
#### func dump
```
dump(): Unit
```
- 描述: 开始打印调试信息

#### func init
```
init(chunks: Iterator<String>)
```
- 描述: 构造函数，使用字符串迭代器初始化ConsoleReactPrinter
- 参数:
  - `chunks`: `Iterator<String>`, 字符串迭代器，用于初始化

#### func init
```
init(asyncResponse: AsyncAgentResponse)
```
- 描述: 构造函数，使用异步代理响应初始化ConsoleReactPrinter
- 参数:
  - `asyncResponse`: `AsyncAgentResponse`, 异步代理响应，用于初始化

#### func print
```
print(asyncResponse: AsyncAgentResponse, verbose!: Bool = false): Unit
```
- 描述: 静态方法，根据verbose标志打印异步代理响应的调试信息或直接输出数据
- 参数:
  - `asyncResponse`: `AsyncAgentResponse`, 异步代理响应，包含需要打印的数据
  - `verbose`: `Bool`, 是否打印详细调试信息，默认为false


### class ReactExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 执行代理的异步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理实例
  - `request`: `AgentRequest`, 代理请求参数

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理的同步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理实例
  - `request`: `AgentRequest`, 代理请求参数


