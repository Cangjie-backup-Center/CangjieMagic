## Package agent_executor
- [Package agent_executor](#package-agent_executor)
  - [struct AgentExecutorManager](#struct-agentexecutormanager)
    - [func create](#func-create)
    - [func register](#func-register)
    - [func register](#func-register-1)

### struct AgentExecutorManager
#### func create
```
public static func create(name: String): AgentExecutor
```
- 描述: 根据名称创建代理执行器
- 参数:
  - `name`: `String`, 代理执行器的名称

#### func register
```
public static func register(name: String, buildFn: () -> AgentExecutor): Unit
```
- 描述: 注册一个指定名称的代理执行器构建器
- 参数:
  - `name`: `String`, 代理执行器的名称
  - `buildFn`: `() -> AgentExecutor`, 构建函数，用于创建代理执行器

#### func register
```
public static func register(checkFn: (String) -> Bool, buildFn: (String) -> AgentExecutor): Unit
```
- 描述: 注册一个代理执行器构建器
- 参数:
  - `checkFn`: `(String) -> Bool`, 检查函数，用于判断是否使用该构建器
  - `buildFn`: `(String) -> AgentExecutor`, 构建函数，用于创建代理执行器


