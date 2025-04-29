## Package config
- [Package config](#package-config)
  - [class Config](#class-config)
    - [var agentLogDir](#var-agentlogdir)
    - [var codeInterpreterDir](#var-codeinterpreterdir)
    - [var defaultChatModel](#var-defaultchatmodel)
    - [var defaultEmbeddingModel](#var-defaultembeddingmodel)
    - [var enableAgentLog](#var-enableagentlog)
    - [let env](#let-env)
    - [prop externalScriptDir](#prop-externalscriptdir)
    - [var filterThink](#var-filterthink)
    - [var httpConnectTimeout](#var-httpconnecttimeout)
    - [var httpReadTimeout](#var-httpreadtimeout)
    - [var logFile](#var-logfile)
    - [var logLevel](#var-loglevel)
    - [var maxReactNumber](#var-maxreactnumber)
    - [var modelRequestDir](#var-modelrequestdir)
    - [var modelRetryNumber](#var-modelretrynumber)
    - [var outputRepairRetryNumber](#var-outputrepairretrynumber)
    - [var saveCodeInterpreter](#var-savecodeinterpreter)
    - [var saveModelRequest](#var-savemodelrequest)
  - [struct EnvWrapper](#struct-envwrapper)
    - [func []](#func-[])
    - [func []](#func-[]-1)

### class Config
#### var agentLogDir
```
static var agentLogDir = "./logs/agent-logs"
```
- 描述: 代理日志目录

#### var codeInterpreterDir
```
static var codeInterpreterDir = "./logs/code-interpreter-scripts"
```
- 描述: 代码解释器脚本保存目录

#### var defaultChatModel
```
static var defaultChatModel = Option<ChatModel>.None
```
- 描述: 默认聊天模型

#### var defaultEmbeddingModel
```
static var defaultEmbeddingModel = Option<EmbeddingModel>.None
```
- 描述: 默认嵌入模型

#### var enableAgentLog
```
static var enableAgentLog = false
```
- 描述: 是否启用代理日志

#### let env
```
static let env = EnvWrapper()
```
- 描述: 提供一种简便的方式来获取/设置环境变量

#### prop externalScriptDir
```
static mut prop externalScriptDir: String
```
- 描述: 外部脚本目录

#### var filterThink
```
static var filterThink = false
```
- 描述: 是否过滤推理LLM生成的<think>消息，仅在同步调用时生效

#### var httpConnectTimeout
```
static var httpConnectTimeout = 60000
```
- 描述: HTTP请求的最大连接超时时间（毫秒）

#### var httpReadTimeout
```
static var httpReadTimeout = 60000
```
- 描述: HTTP请求的最大读取超时时间（毫秒）

#### var logFile
```
static var logFile: String = "stderr"
```
- 描述: 日志文件路径，默认为标准错误输出

#### var logLevel
```
static var logLevel = LogLevel.ERROR
```
- 描述: 日志级别，默认为ERROR

#### var maxReactNumber
```
static var maxReactNumber = 10
```
- 描述: React执行的最大步骤数

#### var modelRequestDir
```
static var modelRequestDir = "./logs/model-requests"
```
- 描述: 模型请求保存目录

#### var modelRetryNumber
```
static var modelRetryNumber = 3
```
- 描述: 获取LLM响应失败时的最大重试次数

#### var outputRepairRetryNumber
```
static var outputRepairRetryNumber = 3
```
- 描述: 生成所需JSON模式输出失败时的最大重试次数

#### var saveCodeInterpreter
```
static var saveCodeInterpreter = false
```
- 描述: 是否保存代码解释器脚本

#### var saveModelRequest
```
static var saveModelRequest = false
```
- 描述: 是否保存模型请求


### struct EnvWrapper
#### func operator []
```
operator func [](name: String): Option<String>
```
- 描述: 获取环境变量的值
- 参数:
  - `name`: `String`, 环境变量的名称

#### func operator []
```
operator func [](name: String, value!: String): Unit
```
- 描述: 设置环境变量的值
- 参数:
  - `name`: `String`, 环境变量的名称
  - `value`: `String`, 环境变量的值


