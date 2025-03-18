<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Package agent](#package-agent)
  - [class BaseAgent](#class-baseagent)
    - [func init](#func-init)
    - [prop name](#prop-name)
    - [prop description](#prop-description)
    - [prop temperature](#prop-temperature)
    - [prop systemPrompt](#prop-systemprompt)
    - [prop toolManager](#prop-toolmanager)
    - [prop model](#prop-model)
    - [prop executor](#prop-executor)
    - [prop retriever](#prop-retriever)
    - [prop memory](#prop-memory)
    - [prop interceptor](#prop-interceptor)
  - [class DispatchAgent](#class-dispatchagent)
    - [func chat](#func-chat)
    - [func init](#func-init-1)
  - [class HumanAgent](#class-humanagent)
    - [func init](#func-init-2)
    - [func chat](#func-chat-1)
  - [class ToolAgent<T>](#class-toolagentt)
    - [func init](#func-init-3)
    - [func chat](#func-chat-2)
    - [func chatGet](#func-chatget)
- [Package agent_executor](#package-agent_executor)
  - [struct AgentExecutorManager](#struct-agentexecutormanager)
    - [func register](#func-register)
    - [func register](#func-register-1)
    - [func create](#func-create)
- [Package agent_executor.naive](#package-agent_executornaive)
  - [class NaiveExecutor](#class-naiveexecutor)
    - [func run](#func-run)
    - [func asyncRun](#func-asyncrun)
- [Package agent_executor.react](#package-agent_executorreact)
  - [class ReactDumper](#class-reactdumper)
    - [func init](#func-init-4)
    - [func dump](#func-dump)
  - [class ReactExecutor](#class-reactexecutor)
    - [func run](#func-run-1)
    - [func asyncRun](#func-asyncrun-1)
- [Package agent_group](#package-agent_group)
  - [interface AgentCollaboration](#interface-agentcollaboration)
  - [interface AgentGroup](#interface-agentgroup)
    - [func chat](#func-chat-3)
    - [func chat](#func-chat-4)
    - [func asyncChat](#func-asyncchat)
    - [func operator operator []](#func-operator-operator-)
  - [class FreeGroup](#class-freegroup)
    - [func init](#func-init-5)
    - [func chat](#func-chat-5)
    - [func chat](#func-chat-6)
    - [func asyncChat](#func-asyncchat-1)
    - [func discuss](#func-discuss)
    - [func []](#func-)
    - [func |](#func--1)
  - [enum FreeGroupMode](#enum-freegroupmode)
    - [Auto](#auto)
    - [RoundRobin](#roundrobin)
  - [class LeaderGroup](#class-leadergroup)
    - [func chat](#func-chat-7)
    - [func chat](#func-chat-8)
    - [func asyncChat](#func-asyncchat-2)
    - [func operator []](#func-operator-)
  - [class LinearGroup](#class-lineargroup)
    - [func chat](#func-chat-9)
    - [func chat](#func-chat-10)
    - [func asyncChat](#func-asyncchat-3)
    - [func operator []](#func-operator--1)
- [Package config](#package-config)
  - [class Config](#class-config)
    - [var logLevel](#var-loglevel)
    - [var logFile](#var-logfile)
    - [var enableAgentLog](#var-enableagentlog)
    - [var agentLogDir](#var-agentlogdir)
    - [var saveModelRequest](#var-savemodelrequest)
    - [var modelRequestDir](#var-modelrequestdir)
    - [var saveCodeInterpreter](#var-savecodeinterpreter)
    - [var codeInterpreterDir](#var-codeinterpreterdir)
    - [var defaultChatModel](#var-defaultchatmodel)
    - [var defaultEmbeddingModel](#var-defaultembeddingmodel)
    - [prop externalScriptDir](#prop-externalscriptdir)
    - [var modelRetryNumber](#var-modelretrynumber)
    - [var filterThink](#var-filterthink)
    - [let env](#let-env)
    - [var maxReactNumber](#var-maxreactnumber)
    - [var outputRepairRetryNumber](#var-outputrepairretrynumber)
  - [struct EnvWrapper](#struct-envwrapper)
    - [func operator []](#func-operator--2)
    - [func operator []](#func-operator--3)
- [Package core.agent](#package-coreagent)
  - [interface Agent](#interface-agent)
    - [prop name](#prop-name-1)
    - [prop description](#prop-description-1)
    - [prop temperature](#prop-temperature-1)
    - [prop systemPrompt](#prop-systemprompt-1)
    - [prop toolManager](#prop-toolmanager-1)
    - [prop model](#prop-model-1)
    - [prop executor](#prop-executor-1)
    - [prop retriever](#prop-retriever-1)
    - [prop memory](#prop-memory-1)
    - [prop interceptor](#prop-interceptor-1)
    - [func chat](#func-chat-11)
    - [func asyncChat](#func-asyncchat-4)
  - [class AgentExecutionException](#class-agentexecutionexception)
    - [func init](#func-init-6)
  - [class AgentExecutionInfo](#class-agentexecutioninfo)
    - [let dialog](#let-dialog)
    - [let retrievalInfo](#let-retrievalinfo)
    - [func init](#func-init-7)
    - [func init](#func-init-8)
    - [prop verboseInfo](#prop-verboseinfo)
  - [interface AgentExecutor](#interface-agentexecutor)
    - [func run](#func-run-2)
    - [func asyncRun](#func-asyncrun-2)
  - [struct AgentRequest](#struct-agentrequest)
    - [let question](#let-question)
    - [let dialog](#let-dialog-1)
    - [let verbose](#let-verbose)
    - [func init](#func-init-9)
  - [struct AgentResponse](#struct-agentresponse)
    - [let content](#let-content)
    - [let execInfo](#let-execinfo)
    - [func init](#func-init-10)
    - [func init](#func-init-11)
  - [class AsyncAgentResponse](#class-asyncagentresponse)
    - [let execInfo](#let-execinfo-1)
    - [func init](#func-init-12)
    - [func init](#func-init-13)
    - [prop content](#prop-content)
    - [func next](#func-next)
  - [class Interceptor](#class-interceptor)
    - [func init](#func-init-14)
  - [enum InterceptorMode](#enum-interceptormode)
    - [Always](#always)
    - [Periodic](#periodic)
    - [Conditional](#conditional)
- [Package core.memory](#package-corememory)
  - [interface Memory](#interface-memory)
    - [func update](#func-update)
    - [func search](#func-search)
- [Package core.message](#package-coremessage)
  - [class ChatMessage](#class-chatmessage)
    - [let name](#let-name)
    - [let role](#let-role)
    - [let content](#let-content-1)
    - [let image](#let-image)
    - [func init](#func-init-15)
    - [func toString](#func-tostring)
    - [func toLogString](#func-tologstring)
    - [func system](#func-system)
    - [func assistant](#func-assistant)
    - [func user](#func-user)
  - [enum ChatMessageRole](#enum-chatmessagerole)
    - [System](#system)
    - [User](#user)
    - [Assistant](#assistant)
    - [Unknown](#unknown)
    - [func toString](#func-tostring-1)
    - [func fromStr](#func-fromstr)
    - [func operator ==](#func-operator--4)
    - [func operator !=](#func-operator--5)
  - [class Dialog](#class-dialog)
    - [func init](#func-init-16)
    - [func init](#func-init-17)
    - [func init](#func-init-18)
    - [func clone](#func-clone)
    - [func addMessage](#func-addmessage)
    - [func addMessage](#func-addmessage-1)
    - [func clear](#func-clear)
    - [func removeLast](#func-removelast)
    - [func iterator](#func-iterator)
    - [func operator operator[]](#func-operator-operator)
    - [prop size](#prop-size)
    - [func isEmpty](#func-isempty)
    - [func toString](#func-tostring-2)
- [Package core.model](#package-coremodel)
  - [struct AsyncChatChunk](#struct-asyncchatchunk)
  - [class AsyncChatResponse](#class-asyncchatresponse)
    - [let model](#let-model)
    - [let chunks](#let-chunks)
    - [func init](#func-init-19)
    - [func next](#func-next-1)
    - [prop stream](#prop-stream)
    - [prop usage](#prop-usage)
    - [prop dialog](#prop-dialog)
    - [func toString](#func-tostring-3)
  - [interface ChatModel](#interface-chatmodel)
    - [func create](#func-create-1)
    - [func asyncCreate](#func-asynccreate)
  - [class ChatRequest](#class-chatrequest)
    - [let dialog](#let-dialog-2)
    - [let stop](#let-stop)
    - [let temperature](#let-temperature)
    - [func init](#func-init-20)
    - [func init](#func-init-21)
    - [func init](#func-init-22)
    - [func toString](#func-tostring-4)
  - [struct ChatResponse](#struct-chatresponse)
    - [let model](#let-model-1)
    - [let dialog](#let-dialog-3)
    - [let usage](#let-usage)
    - [func init](#func-init-23)
    - [func toString](#func-tostring-5)
  - [class ChatUsage](#class-chatusage)
    - [let promptTokens](#let-prompttokens)
    - [let completionTokens](#let-completiontokens)
    - [let totalTokens](#let-totaltokens)
    - [let timeCost](#let-timecost)
    - [func init](#func-init-24)
    - [func toString](#func-tostring-6)
  - [interface EmbeddingModel](#interface-embeddingmodel)
    - [func create](#func-create-2)
  - [struct EmbeddingRequest](#struct-embeddingrequest)
    - [let prompt](#let-prompt)
    - [let dimensions](#let-dimensions)
    - [func init](#func-init-25)
  - [struct EmbeddingResponse](#struct-embeddingresponse)
    - [let data](#let-data)
    - [func init](#func-init-26)
    - [func toString](#func-tostring-7)
  - [interface ImageModel](#interface-imagemodel)
    - [func create](#func-create-3)
  - [struct ImageRequest](#struct-imagerequest)
    - [let prompt](#let-prompt-1)
    - [let quality](#let-quality)
    - [let responseFormat](#let-responseformat)
    - [let size](#let-size)
    - [let style](#let-style)
    - [func init](#func-init-27)
  - [struct ImageResponse](#struct-imageresponse)
    - [let b64Json](#let-b64json)
    - [let url](#let-url)
    - [let revisedPrompt](#let-revisedprompt)
    - [func init](#func-init-28)
  - [interface Model](#interface-model)
    - [prop service](#prop-service)
    - [prop name](#prop-name-2)
  - [class ModelException](#class-modelexception)
    - [func init](#func-init-29)
- [Package core.rag](#package-corerag)
  - [class Document](#class-document)
    - [let content](#let-content-2)
    - [let metadata](#let-metadata)
    - [func init](#func-init-30)
    - [func init](#func-init-31)
    - [func toString](#func-tostring-8)
    - [func toPrompt](#func-toprompt)
    - [func getTypeSchema](#func-gettypeschema)
    - [func fromJsonValue](#func-fromjsonvalue)
    - [func toJsonValue](#func-tojsonvalue)
  - [interface Retrieval](#interface-retrieval)
    - [prop sources](#prop-sources)
  - [struct RetrievalInfo](#struct-retrievalinfo)
  - [interface Retriever](#interface-retriever)
    - [prop description](#prop-description-2)
    - [prop mode](#prop-mode)
    - [func search](#func-search-1)
  - [class RetrieverException](#class-retrieverexception)
    - [func init](#func-init-32)
  - [enum RetrieverMode](#enum-retrievermode)
    - [Static](#static)
    - [Dynamic](#dynamic)
    - [func operator ==](#func-operator--6)
    - [func operator !=](#func-operator--7)
- [Package core.tool](#package-coretool)
  - [interface Tool](#interface-tool)
    - [prop name](#prop-name-3)
    - [prop description](#prop-description-3)
    - [prop parameters](#prop-parameters)
    - [prop retType](#prop-rettype)
    - [prop examples](#prop-examples)
    - [func invoke](#func-invoke)
  - [class ToolException](#class-toolexception)
    - [let reason](#let-reason)
    - [func init](#func-init-33)
  - [interface ToolManager](#interface-toolmanager)
    - [func addTool](#func-addtool)
    - [func delTool](#func-deltool)
    - [func addTools](#func-addtools)
    - [func clear](#func-clear-1)
    - [func findTool](#func-findtool)
    - [func getTools](#func-gettools)
    - [func searchTool](#func-searchtool)
    - [prop enableToolSearch](#prop-enabletoolsearch)
  - [struct ToolParameter](#struct-toolparameter)
    - [let name](#let-name-1)
    - [let description](#let-description)
    - [let typeSchema](#let-typeschema)
    - [func init](#func-init-34)
  - [struct ToolResponse](#struct-toolresponse)
    - [let content](#let-content-3)
    - [func init](#func-init-35)
- [Package instrumentor](#package-instrumentor)
  - [class Instrumentor](#class-instrumentor)
    - [var BEFORE_CHAT_MODEL_FN](#var-before_chat_model_fn)
    - [var BEFORE_CHAT_MODEL_FN2](#var-before_chat_model_fn2)
    - [func registerBeforeChatModel](#func-registerbeforechatmodel)
    - [func registerBeforeChatModel](#func-registerbeforechatmodel-1)
    - [var BEFORE_AGENT_RUN_FN](#var-before_agent_run_fn)
    - [func registerBeforeAgentRun](#func-registerbeforeagentrun)
    - [var AFTER_AGENT_RUN_FN](#var-after_agent_run_fn)
    - [func registerAfterAgentRun](#func-registerafteragentrun)
- [Package jsonable](#package-jsonable)
  - [struct FieldSchema](#struct-fieldschema)
  - [struct JsonUtils](#struct-jsonutils)
    - [func buildJsonObject](#func-buildjsonobject)
    - [func buildJsonObject](#func-buildjsonobject-1)
    - [func buildJsonObject](#func-buildjsonobject-2)
    - [func buildJsonArray](#func-buildjsonarray)
    - [func appendJsonObject](#func-appendjsonobject)
    - [func asJsonObject](#func-asjsonobject)
    - [func asJsonArray](#func-asjsonarray)
    - [func toString](#func-tostring-9)
    - [func toFloat](#func-tofloat)
    - [func toInt](#func-toint)
    - [func toBool](#func-tobool)
    - [func getJsonValue](#func-getjsonvalue)
    - [func getJsonObject](#func-getjsonobject)
    - [func getJsonArray](#func-getjsonarray)
    - [func getString](#func-getstring)
    - [func getFloat](#func-getfloat)
    - [func getInt](#func-getint)
    - [func getBool](#func-getbool)
    - [func toFloatArray](#func-tofloatarray)
  - [interface Jsonable](#interface-jsonable)
    - [func getTypeSchema](#func-gettypeschema-1)
    - [func fromJsonValue](#func-fromjsonvalue-1)
  - [class JsonableException](#class-jsonableexception)
    - [func init](#func-init-36)
  - [interface ToJsonValue](#interface-tojsonvalue)
    - [func toJsonValue](#func-tojsonvalue-1)
  - [enum TypeSchema](#enum-typeschema)
    - [Str](#str)
    - [Int](#int)
    - [Float](#float)
    - [Boolean](#boolean)
    - [Arr](#arr)
    - [Obj](#obj)
    - [func toJsonValue](#func-tojsonvalue-2)
    - [func toString](#func-tostring-10)
- [Package log](#package-log)
  - [struct LogUtils](#struct-logutils)
    - [func debug](#func-debug)
    - [func info](#func-info)
    - [func info](#func-info-1)
    - [func info](#func-info-2)
    - [func info](#func-info-3)
    - [func info](#func-info-4)
    - [func info](#func-info-5)
    - [func info](#func-info-6)
    - [func info](#func-info-7)
    - [func error](#func-error)
    - [func error](#func-error-1)
  - [struct LogUtils](#struct-logutils-1)
    - [func debug](#func-debug-1)
    - [func info](#func-info-8)
    - [func info](#func-info-9)
    - [func info](#func-info-10)
    - [func info](#func-info-11)
    - [func info](#func-info-12)
    - [func info](#func-info-13)
    - [func info](#func-info-14)
    - [func info](#func-info-15)
    - [func error](#func-error-2)
    - [func error](#func-error-3)
- [Package mcp](#package-mcp)
  - [class MCPClient](#class-mcpclient)
    - [func init](#func-init-37)
    - [func getTools](#func-gettools-1)
    - [func callTool](#func-calltool)
  - [enum ToolCallContent](#enum-toolcallcontent)
    - [Text](#text)
    - [Image](#image)
    - [func getTypeSchema](#func-gettypeschema-2)
    - [func fromJsonValue](#func-fromjsonvalue-2)
    - [func toJsonValue](#func-tojsonvalue-3)
    - [func getValue](#func-getvalue)
  - [class MCPServer](#class-mcpserver)
    - [func init](#func-init-38)
    - [func start](#func-start)
    - [func startWith](#func-startwith)
- [Package memory](#package-memory)
  - [class ShortMemory](#class-shortmemory)
    - [func update](#func-update-1)
    - [func search](#func-search-2)
- [Package model](#package-model)
  - [class ModelConfig](#class-modelconfig)
    - [func init](#func-init-39)
  - [struct ModelManager](#struct-modelmanager)
    - [func registerChatModel](#func-registerchatmodel)
    - [func createChatModel](#func-createchatmodel)
    - [func createChatModel](#func-createchatmodel-1)
    - [func registerEmbeddingModel](#func-registerembeddingmodel)
    - [func createEmbeddingModel](#func-createembeddingmodel)
    - [func createEmbeddingModel](#func-createembeddingmodel-1)
    - [func registerImageModel](#func-registerimagemodel)
    - [func createImageModel](#func-createimagemodel)
    - [func createImageModel](#func-createimagemodel-1)
  - [struct ModelUtils](#struct-modelutils)
    - [func makeChat](#func-makechat)
    - [func makeChat](#func-makechat-1)
    - [func makeChat](#func-makechat-2)
    - [func makeChat](#func-makechat-3)
    - [func makeChatGet](#func-makechatget)
    - [func agentMakeChat](#func-agentmakechat)
    - [func agentMakeChatGet](#func-agentmakechatget)
- [Package parser](#package-parser)
  - [struct OutputParserUtils](#struct-outputparserutils)
    - [func extractLastCode](#func-extractlastcode)
    - [func extractLastSection](#func-extractlastsection)
    - [func parseToolCall](#func-parsetoolcall)
- [Package rag](#package-rag)
  - [struct RetrieverUtils](#struct-retrieverutils)
    - [func createRetriever](#func-createretriever)
    - [func createRetriever](#func-createretriever-1)
- [Package rag.splitter](#package-ragsplitter)
  - [class CharacterTextSplitter](#class-charactertextsplitter)
    - [func split](#func-split)
  - [class DocumentLoader](#class-documentloader)
    - [func load](#func-load)
    - [func loadSplit](#func-loadsplit)
  - [class MarkdownSplitter](#class-markdownsplitter)
    - [func init](#func-init-40)
    - [func split](#func-split-1)
  - [interface Splitter](#interface-splitter)
    - [func split](#func-split-2)
- [Package tool](#package-tool)
  - [class NativeFuncTool](#class-nativefunctool)
    - [func init](#func-init-41)
    - [prop name](#prop-name-4)
    - [prop description](#prop-description-4)
    - [prop parameters](#prop-parameters-1)
    - [prop retType](#prop-rettype-1)
    - [prop examples](#prop-examples-1)
    - [func invoke](#func-invoke-1)
    - [func addExamples](#func-addexamples)
  - [class RetrieverTool](#class-retrievertool)
    - [func init](#func-init-42)
    - [prop name](#prop-name-5)
    - [prop description](#prop-description-5)
    - [prop parameters](#prop-parameters-2)
    - [prop retType](#prop-rettype-2)
    - [prop examples](#prop-examples-2)
    - [func invoke](#func-invoke-2)
  - [class SimpleToolManager](#class-simpletoolmanager)
    - [func init](#func-init-43)
    - [func init](#func-init-44)
    - [func addTool](#func-addtool-1)
    - [func delTool](#func-deltool-1)
    - [func addTools](#func-addtools-1)
    - [func clear](#func-clear-2)
    - [func findTool](#func-findtool-1)
    - [func getTools](#func-gettools-2)
    - [func searchTool](#func-searchtool-1)
    - [prop enableToolSearch](#prop-enabletoolsearch-1)
- [Package utils](#package-utils)
  - [struct SqliteUtils](#struct-sqliteutils)
    - [let SQLITE_ROW](#let-sqlite_row)
    - [let SQLITE_DONE](#let-sqlite_done)
    - [func sqlOpen](#func-sqlopen)
    - [func sqlPrepare](#func-sqlprepare)
    - [func sqlStep](#func-sqlstep)
    - [func sqlColumnType](#func-sqlcolumntype)
    - [func sqlColumnText](#func-sqlcolumntext)
    - [func sqlColumnBytes](#func-sqlcolumnbytes)
    - [func sqlColumnInt64](#func-sqlcolumnint64)
    - [func sqlColumnDouble](#func-sqlcolumndouble)
    - [func sqlColumnBlob](#func-sqlcolumnblob)
    - [func sqlColumnCount](#func-sqlcolumncount)
    - [func sqlColumnName](#func-sqlcolumnname)
    - [func sqlColumnDecltype](#func-sqlcolumndecltype)
    - [func sqlReset](#func-sqlreset)
    - [func sqlBusyTimeout](#func-sqlbusytimeout)
    - [func sqlChanges](#func-sqlchanges)
    - [func sqlLastInsertRowid](#func-sqllastinsertrowid)
    - [func sqlSoftHeapLimit](#func-sqlsoftheaplimit)
    - [func sqlBindParameterCount](#func-sqlbindparametercount)
    - [func sqlBindNull](#func-sqlbindnull)
    - [func sqlBindInt](#func-sqlbindint)
    - [func sqlBindInt64](#func-sqlbindint64)
    - [func sqlBindDouble](#func-sqlbinddouble)
    - [func sqlBindText](#func-sqlbindtext)
    - [func sqlClearBindings](#func-sqlclearbindings)
    - [func sqlExec](#func-sqlexec)
    - [func sqlClose](#func-sqlclose)
    - [func sqlFinalize](#func-sqlfinalize)
- [Package utils.http](#package-utilshttp)
  - [class HttpStream](#class-httpstream)
    - [func put](#func-put)
    - [func markEOF](#func-markeof)
    - [func markError](#func-markerror)
    - [func next](#func-next-2)
- [Package utils.ohos](#package-utilsohos)
  - [interface CJ2JS](#interface-cj2js)
    - [func toJS](#func-tojs)
  - [interface JS2CJ](#interface-js2cj)
    - [func fromJS](#func-fromjs)
- [Package vdb](#package-vdb)
  - [class FaissVectorDatabase](#class-faissvectordatabase)
    - [func init](#func-init-45)
    - [func close](#func-close)
    - [func save](#func-save)
    - [func load](#func-load-1)
    - [func addVector](#func-addvector)
    - [func search](#func-search-3)
  - [class InMemoryVectorDatabase](#class-inmemoryvectordatabase)
    - [func addVector](#func-addvector-1)
    - [func search](#func-search-4)
    - [func save](#func-save-1)
    - [func load](#func-load-2)
  - [interface IndexMap](#interface-indexmap)
    - [func add](#func-add)
    - [func get](#func-get)
    - [func save](#func-save-2)
    - [func load](#func-load-3)
  - [class JsonlIndexMap<T>](#class-jsonlindexmapt)
    - [func add](#func-add-1)
    - [func get](#func-get-1)
    - [func save](#func-save-3)
    - [func load](#func-load-4)
  - [class SemanticMap](#class-semanticmap)
    - [let vectorDB](#let-vectordb)
    - [let indexMap](#let-indexmap)
    - [func init](#func-init-46)
    - [prop embeddingModel](#prop-embeddingmodel)
    - [func put](#func-put-1)
    - [func search](#func-search-5)
    - [func asRetriever](#func-asretriever)
    - [func save](#func-save-4)
    - [func load](#func-load-5)
  - [class SemanticSet](#class-semanticset)
    - [func init](#func-init-47)
    - [prop embeddingModel](#prop-embeddingmodel-1)
    - [func put](#func-put-2)
    - [func search](#func-search-6)
    - [func asRetriever](#func-asretriever-1)
    - [func save](#func-save-5)
    - [func load](#func-load-6)
  - [class SimpleIndexMap](#class-simpleindexmap)
    - [func add](#func-add-2)
    - [func get](#func-get-2)
    - [func serialize](#func-serialize)
    - [func deserialize](#func-deserialize)
    - [func save](#func-save-6)
    - [func load](#func-load-7)
  - [class Vector](#class-vector)
    - [let vector](#let-vector)
    - [func init](#func-init-48)
  - [class VectorBuilder](#class-vectorbuilder)
    - [func createEmbeddingVector](#func-createembeddingvector)
  - [interface VectorDatabase](#interface-vectordatabase)
    - [func addVector](#func-addvector-2)
    - [func search](#func-search-7)
    - [func save](#func-save-7)
    - [func load](#func-load-8)

<!-- /code_chunk_output -->


## Package agent
### class BaseAgent
#### func init
```
init(model: ChatModel, name: String = "Base Agent", description: String = "", temperature: Option<Float64> = None, systemPrompt: String = "", toolManager: ToolManager = SimpleToolManager(), executor: Option<AgentExecutor> = None, retriever: Option<Retriever> = None, memory: Option<Memory> = None, interceptor: Option<Interceptor> = None)
```
- 描述: 初始化BaseAgent实例
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `name`: `String`, 代理名称，默认为"Base Agent"
  - `description`: `String`, 代理描述，默认为空
  - `temperature`: `Option<Float64>`, 温度参数，默认为None
  - `systemPrompt`: `String`, 系统提示，默认为空
  - `toolManager`: `ToolManager`, 工具管理器，默认为SimpleToolManager
  - `executor`: `Option<AgentExecutor>`, 代理执行器，默认为None
  - `retriever`: `Option<Retriever>`, 检索器，默认为None
  - `memory`: `Option<Memory>`, 内存，默认为None
  - `interceptor`: `Option<Interceptor>`, 拦截器，默认为None

#### prop name
```
prop name: String
```
- 描述: 获取代理名称

#### prop description
```
prop description: String
```
- 描述: 获取代理描述

#### prop temperature
```
prop temperature: Option<Float64>
```
- 描述: 获取或设置温度参数

#### prop systemPrompt
```
prop systemPrompt: String
```
- 描述: 获取或设置系统提示

#### prop toolManager
```
prop toolManager: ToolManager
```
- 描述: 获取工具管理器

#### prop model
```
prop model: ChatModel
```
- 描述: 获取或设置聊天模型

#### prop executor
```
prop executor: AgentExecutor
```
- 描述: 获取或设置代理执行器

#### prop retriever
```
prop retriever: Option<Retriever>
```
- 描述: 获取或设置检索器

#### prop memory
```
prop memory: Option<Memory>
```
- 描述: 获取或设置内存

#### prop interceptor
```
prop interceptor: Option<Interceptor>
```
- 描述: 获取或设置拦截器


### class DispatchAgent
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理用户问题并将其分发给其他代理。
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象。

#### func init
```
init(model: String)
```
- 描述: 初始化DispatchAgent实例。
- 参数:
  - `model`: `String`, 用于创建聊天模型的模型名称。


### class HumanAgent
#### func init
```
init(qaFunc!: Option<(String) -> String> = None)
```
- 描述: 初始化 HumanAgent 实例，接受一个可选的 qaFunc 参数。
- 参数:
  - `qaFunc`: `Option<(String) -> String>`, 一个可选的函数，用于处理问题和生成答案。

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理用户的问题并返回答案。
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象。


### class ToolAgent<T>
#### func init
```
init(fn!: (String) -> T)
```
- 描述: 初始化ToolAgent，传入一个函数用于回答问题。
- 参数:
  - `fn`: `(String) -> T`, 用于回答问题的函数，接受一个字符串参数并返回泛型T。

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求，通过执行传入的函数来回答问题。
- 参数:
  - `request`: `AgentRequest`, 包含用户问题的请求对象。

#### func chatGet
```
func chatGet<U>(question: String): Option<U> where U <: Jsonable<U>
```
- 描述: 根据用户问题，执行传入的函数并返回一个`Option<U>`类型的结果。
- 参数:
  - `question`: `String`, 用户提出的问题。


## Package agent_executor
### struct AgentExecutorManager
#### func register
```
public static func register(checkFn: (String) -> Bool, buildFn: (String) -> AgentExecutor): Unit
```
- 描述: 注册一个代理执行器构建器，用于根据条件函数和构建函数创建代理执行器。
- 参数:
  - `checkFn`: `(String) -> Bool`, 条件函数，用于检查是否使用该构建器。
  - `buildFn`: `(String) -> AgentExecutor`, 构建函数，用于创建代理执行器。

#### func register
```
public static func register(name: String, buildFn: () -> AgentExecutor): Unit
```
- 描述: 注册一个代理执行器构建器，用于根据名称和构建函数创建代理执行器。
- 参数:
  - `name`: `String`, 代理执行器的名称。
  - `buildFn`: `() -> AgentExecutor`, 构建函数，用于创建代理执行器。

#### func create
```
public static func create(name: String): AgentExecutor
```
- 描述: 根据名称创建代理执行器。如果名称匹配已知的执行器，则返回相应的执行器；否则抛出异常。
- 参数:
  - `name`: `String`, 代理执行器的名称。


## Package agent_executor.naive
### class NaiveExecutor
#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理任务并返回响应
- 参数:
  - `agent`: `Agent`, 要执行的代理
  - `request`: `AgentRequest`, 代理请求

#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步执行代理任务并返回响应
- 参数:
  - `agent`: `Agent`, 要执行的代理
  - `request`: `AgentRequest`, 代理请求


## Package agent_executor.react
### class ReactDumper
#### func init
```
init(chunks: Iterator<String>)
```
- 描述: 初始化ReactDumper类，用于调试React内部信息
- 参数:
  - `chunks`: `Iterator<String>`, 包含React内部信息的字符串迭代器

#### func dump
```
dump(): Unit
```
- 描述: 打印React内部信息，用于调试


### class ReactExecutor
#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理的同步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理
  - `request`: `AgentRequest`, 代理请求

#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 执行代理的异步运行逻辑
- 参数:
  - `agent`: `Agent`, 要执行的代理
  - `request`: `AgentRequest`, 代理请求


## Package agent_group
### interface AgentCollaboration

### interface AgentGroup
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest, maxRound!: Int64): AgentResponse
```
- 描述: 处理聊天请求并返回响应，限制最大轮次
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象
  - `maxRound!`: `Int64`, 最大聊天轮次

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func operator operator []
```
operator func [](memberName: String): Agent
```
- 描述: 根据成员名称查找代理
- 参数:
  - `memberName`: `String`, 成员名称


### class FreeGroup
#### func init
```
init(a: Agent, b: Agent)
```
- 描述: 初始化FreeGroup，添加两个Agent成员
- 参数:
  - `a`: `Agent`, 第一个Agent成员
  - `b`: `Agent`, 第二个Agent成员

#### func chat
```
chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求，返回AgentResponse
- 参数:
  - `request`: `AgentRequest`, 聊天请求

#### func chat
```
chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理聊天请求，指定最大轮数，返回AgentResponse
- 参数:
  - `request`: `AgentRequest`, 聊天请求
  - `maxRound`: `Int64`, 最大讨论轮数

#### func asyncChat
```
asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 处理异步聊天请求，返回AsyncAgentResponse
- 参数:
  - `request`: `AgentRequest`, 异步聊天请求

#### func discuss
```
discuss(topic: String, initiator: String, speech: String, mode: FreeGroupMode, maxRound: Int64): String
```
- 描述: 根据指定模式和最大轮数进行讨论，返回讨论结果
- 参数:
  - `topic`: `String`, 讨论主题
  - `initiator`: `String`, 发起者
  - `speech`: `String`, 发言内容
  - `mode`: `FreeGroupMode`, 讨论模式
  - `maxRound`: `Int64`, 最大讨论轮数

#### func []
```
[](memberName: String): Agent
```
- 描述: 根据成员名称获取Agent
- 参数:
  - `memberName`: `String`, 成员名称

#### func |
```
|(member: Agent): FreeGroup
```
- 描述: 添加一个Agent成员并返回当前FreeGroup
- 参数:
  - `member`: `Agent`, 要添加的Agent成员


### enum FreeGroupMode
####  Auto
```
Auto
```
- 描述: LLM自动选择发言者

####  RoundRobin
```
RoundRobin
```
- 描述: 轮询选择发言者


### class LeaderGroup
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理聊天请求并返回响应，指定最大轮次
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象
  - `maxRound`: `Int64`, 最大讨论轮次

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func operator []
```
operator func [](memberName: String): Agent
```
- 描述: 通过成员名称访问代理
- 参数:
  - `memberName`: `String`, 成员名称


### class LinearGroup
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- 描述: 处理聊天请求并返回响应，支持指定最大轮次
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象
  - `maxRound`: `Int64`, 最大聊天轮次

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步处理聊天请求并返回响应
- 参数:
  - `request`: `AgentRequest`, 聊天请求对象

#### func operator []
```
operator func [](memberName: String): Agent
```
- 描述: 获取指定名称的成员代理
- 参数:
  - `memberName`: `String`, 成员代理的名称


## Package config
### class Config
#### var logLevel
```
static var logLevel = LogLevel.ERROR
```
- 描述: 日志级别，默认为ERROR

#### var logFile
```
static var logFile: String = "stdout"
```
- 描述: 日志文件路径，默认为标准输出

#### var enableAgentLog
```
static var enableAgentLog = false
```
- 描述: 是否启用代理日志，默认为false

#### var agentLogDir
```
static var agentLogDir = "./logs/agent-logs"
```
- 描述: 代理日志目录，默认为"./logs/agent-logs"

#### var saveModelRequest
```
static var saveModelRequest = false
```
- 描述: 是否保存模型请求，默认为false

#### var modelRequestDir
```
static var modelRequestDir = "./logs/model-requests"
```
- 描述: 模型请求保存目录，默认为"./logs/model-requests"

#### var saveCodeInterpreter
```
static var saveCodeInterpreter = false
```
- 描述: 是否保存代码解释器脚本，默认为false

#### var codeInterpreterDir
```
static var codeInterpreterDir = "./logs/code-interpreter-scripts"
```
- 描述: 代码解释器脚本保存目录，默认为"./logs/code-interpreter-scripts"

#### var defaultChatModel
```
static var defaultChatModel = Option<ChatModel>.None
```
- 描述: 默认的聊天模型，默认为None

#### var defaultEmbeddingModel
```
static var defaultEmbeddingModel = Option<EmbeddingModel>.None
```
- 描述: 默认的嵌入模型，默认为None

#### prop externalScriptDir
```
static mut prop externalScriptDir: String
```
- 描述: 外部脚本目录，可读写

#### var modelRetryNumber
```
static var modelRetryNumber = 3
```
- 描述: 获取LLM响应失败时的最大重试次数，默认为3

#### var filterThink
```
static var filterThink = false
```
- 描述: 是否过滤推理LLM生成的思考消息，仅在同步调用时生效，默认为false

#### let env
```
static let env = EnvWrapper()
```
- 描述: 提供一种简便的方式来获取/设置环境变量

#### var maxReactNumber
```
static var maxReactNumber = 10
```
- 描述: React执行的最大步骤数，默认为10

#### var outputRepairRetryNumber
```
static var outputRepairRetryNumber = 3
```
- 描述: 生成所需JSON Schema输出失败时的最大重试次数，默认为3


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
  - `value!`: `String`, 环境变量的值


## Package core.agent
### interface Agent
#### prop name
```
prop name: String
```
- 描述: 代理的名称

#### prop description
```
prop description: String
```
- 描述: 代理的功能描述

#### prop temperature
```
mut prop temperature: Option<Float64>
```
- 描述: 代理传递给大语言模型的温度值

#### prop systemPrompt
```
mut prop systemPrompt: String
```
- 描述: 代理的系统提示

#### prop toolManager
```
prop toolManager: ToolManager
```
- 描述: 代理可以使用的工具管理器

#### prop model
```
mut prop model: ChatModel
```
- 描述: 代理将使用的聊天模型

#### prop executor
```
mut prop executor: AgentExecutor
```
- 描述: 代理的底层执行器

#### prop retriever
```
mut prop retriever: Option<Retriever>
```
- 描述: 代理可以使用的检索器

#### prop memory
```
mut prop memory: Option<Memory>
```
- 描述: 代理将使用的内存

#### prop interceptor
```
mut prop interceptor: Option<Interceptor>
```
- 描述: 设置代理的拦截器

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- 描述: 向代理查询并获取答案，可能会抛出AgentExecutionException异常
- 参数:
  - `request`: `AgentRequest`, 代理请求

#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- 描述: 向代理查询并获取答案，返回代理的流式回复
- 参数:
  - `request`: `AgentRequest`, 代理请求


### class AgentExecutionException
#### func init
```
init(msg: String)
```
- 描述: 初始化AgentExecutionException异常
- 参数:
  - `msg`: `String`, 异常信息


### class AgentExecutionInfo
#### let dialog
```
let dialog: Dialog
```
- 描述: 代理执行期间与LLM的内部对话历史

#### let retrievalInfo
```
let retrievalInfo: ArrayList<RetrievalInfo>
```
- 描述: 执行期间检索到的文档

#### func init
```
public init()
```
- 描述: 初始化AgentExecutionInfo对象，默认初始化dialog和retrievalInfo

#### func init
```
public init(dialog: Dialog)
```
- 描述: 使用指定的dialog初始化AgentExecutionInfo对象，默认初始化retrievalInfo
- 参数:
  - `dialog`: `Dialog`, 指定的对话历史

#### prop verboseInfo
```
public prop verboseInfo: Iterator<String>
```
- 描述: 仅在AgentRequest中设置verbose: true时访问此字段


### interface AgentExecutor
#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- 描述: 执行代理任务并返回响应
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求

#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- 描述: 异步执行代理任务并返回响应
- 参数:
  - `agent`: `Agent`, 代理实例
  - `request`: `AgentRequest`, 代理请求


### struct AgentRequest
#### let question
```
let question: String
```
- 描述: 当前用户的问题

#### let dialog
```
let dialog: Option<Dialog>
```
- 描述: 用户与代理之间的历史对话记录

#### let verbose
```
let verbose: Bool
```
- 描述: 是否输出内部执行信息

#### func init
```
public init(question: String, dialog!: Option<Dialog> = None, verbose!: Bool = false)
```
- 描述: 初始化AgentRequest结构体
- 参数:
  - `question`: `String`, 当前用户的问题
  - `dialog`: `Option<Dialog>`, 用户与代理之间的历史对话记录
  - `verbose`: `Bool`, 是否输出内部执行信息


### struct AgentResponse
#### let content
```
let content: String
```
- 描述: 执行结果

#### let execInfo
```
let execInfo: Option<AgentExecutionInfo>
```
- 描述: 执行期间的内部信息

#### func init
```
public init(content: String)
```
- 描述: 初始化AgentResponse
- 参数:
  - `content`: `String`, 执行结果

#### func init
```
public init(content: String, execInfo!: AgentExecutionInfo)
```
- 描述: 初始化AgentResponse
- 参数:
  - `content`: `String`, 执行结果
  - `execInfo`: `AgentExecutionInfo`, 执行期间的内部信息


### class AsyncAgentResponse
#### let execInfo
```
public let execInfo: Option<AgentExecutionInfo>
```
- 描述: 执行期间的内部信息

#### func init
```
public init(chunks: Iterator<String>)
```
- 描述: 构造函数，初始化AsyncAgentResponse实例
- 参数:
  - `chunks`: `Iterator<String>`, 异步执行的块数据

#### func init
```
public init(chunks: Iterator<String>, execInfo!: AgentExecutionInfo)
```
- 描述: 构造函数，初始化AsyncAgentResponse实例，并包含执行信息
- 参数:
  - `chunks`: `Iterator<String>`, 异步执行的块数据
  - `execInfo`: `AgentExecutionInfo`, 执行期间的信息

#### prop content
```
public prop content: String
```
- 描述: 获取执行结果，这是一个同步方法，会等待执行器完成

#### func next
```
override public func next(): Option<String>
```
- 描述: 获取下一个块数据，并更新内部内容


### class Interceptor
#### func init
```
init(agent: Agent, mode!: InterceptorMode = InterceptorMode.Always)
```
- 描述: 初始化拦截器
- 参数:
  - `agent`: `Agent`, 代理对象，用于拦截操作
  - `mode`: `InterceptorMode`, 拦截模式，默认为InterceptorMode.Always


### enum InterceptorMode
####  Always
```
Always
```
- 描述: 总是拦截请求

####  Periodic
```
Periodic(Int64)
```
- 描述: 定期拦截请求
- 参数:
  - `interval`: `Int64`, 拦截的时间间隔

####  Conditional
```
Conditional((AgentRequest) -> Bool)
```
- 描述: 当条件为真时拦截请求
- 参数:
  - `condition`: `(AgentRequest) -> Bool`, 拦截请求的条件函数


## Package core.memory
### interface Memory
#### func update
```
func update(segment: String): Unit
```
- 描述: 更新内存
- 参数:
  - `segment`: `String`, 内存段

#### func search
```
func search(question: String): Array<String>
```
- 描述: 根据用户问题，在内存中查找相关内容
- 参数:
  - `question`: `String`, 用户问题


## Package core.message
### class ChatMessage
#### let name
```
let name: String
```
- 描述: 发送者的名称

#### let role
```
let role: ChatMessageRole
```
- 描述: 发送者的角色

#### let content
```
let content: String
```
- 描述: 消息内容

#### let image
```
let image: Option<String>
```
- 描述: 图片的URL或Base64编码

#### func init
```
init(role: ChatMessageRole, content: String, name!: String = "", image!: Option<String> = None)
```
- 描述: 初始化ChatMessage对象
- 参数:
  - `role`: `ChatMessageRole`, 发送者的角色
  - `content`: `String`, 消息内容
  - `name`: `String`, 发送者的名称
  - `image`: `Option<String>`, 图片的URL或Base64编码

#### func toString
```
func toString(): String
```
- 描述: 将消息转换为字符串

#### func toLogString
```
func toLogString(): String
```
- 描述: 将消息转换为日志字符串

#### func system
```
static func system(content: String): ChatMessage
```
- 描述: 创建一个系统角色的消息
- 参数:
  - `content`: `String`, 消息内容

#### func assistant
```
static func assistant(content: String, name!: String = ""): ChatMessage
```
- 描述: 创建一个助手角色的消息
- 参数:
  - `content`: `String`, 消息内容
  - `name`: `String`, 发送者的名称

#### func user
```
static func user(content: String, image!: Option<String> = None): ChatMessage
```
- 描述: 创建一个用户角色的消息
- 参数:
  - `content`: `String`, 消息内容
  - `image`: `Option<String>`, 图片的URL或Base64编码


### enum ChatMessageRole
####  System
```
System
```
- 描述: 系统角色

####  User
```
User
```
- 描述: 用户角色

####  Assistant
```
Assistant
```
- 描述: 助手角色

####  Unknown
```
Unknown
```
- 描述: 未知角色

#### func toString
```
func toString(): String
```
- 描述: 将角色转换为字符串

#### func fromStr
```
static func fromStr(str: String): ChatMessageRole
```
- 描述: 根据字符串返回对应的角色
- 参数:
  - `str`: `String`, 表示角色的字符串

#### func operator ==
```
operator func ==(other: ChatMessageRole): Bool
```
- 描述: 比较两个角色是否相等
- 参数:
  - `other`: `ChatMessageRole`, 要比较的另一个角色

#### func operator !=
```
operator func !=(other: ChatMessageRole): Bool
```
- 描述: 比较两个角色是否不相等
- 参数:
  - `other`: `ChatMessageRole`, 要比较的另一个角色


### class Dialog
#### func init
```
init()
```
- 描述: 初始化一个空的对话集合

#### func init
```
init(messages: ArrayList<ChatMessage>)
```
- 描述: 使用给定的消息列表初始化对话集合
- 参数:
  - `messages`: `ArrayList<ChatMessage>`, 包含聊天消息的列表

#### func init
```
init(messages: Array<ChatMessage>)
```
- 描述: 使用给定的消息数组初始化对话集合
- 参数:
  - `messages`: `Array<ChatMessage>`, 包含聊天消息的数组

#### func clone
```
func clone(): Dialog
```
- 描述: 克隆当前的对话集合

#### func addMessage
```
func addMessage(msg: ChatMessage): Unit
```
- 描述: 向对话集合中添加一条消息
- 参数:
  - `msg`: `ChatMessage`, 要添加的聊天消息

#### func addMessage
```
func addMessage(messages: Array<ChatMessage>): Unit
```
- 描述: 向对话集合中添加多条消息
- 参数:
  - `messages`: `Array<ChatMessage>`, 要添加的聊天消息数组

#### func clear
```
func clear(): Unit
```
- 描述: 清空对话集合中的所有消息

#### func removeLast
```
func removeLast(): ChatMessage
```
- 描述: 移除并返回对话集合中的最后一条消息

#### func iterator
```
func iterator(): Iterator<ChatMessage>
```
- 描述: 返回对话集合的迭代器

#### func operator operator[]
```
operator func[](index: Int64): ChatMessage
```
- 描述: 通过索引获取对话集合中的消息
- 参数:
  - `index`: `Int64`, 消息的索引

#### prop size
```
prop size: Int64
```
- 描述: 获取对话集合中消息的数量

#### func isEmpty
```
func isEmpty(): Bool
```
- 描述: 判断对话集合是否为空

#### func toString
```
func toString(): String
```
- 描述: 将对话集合转换为字符串表示


## Package core.model
### struct AsyncChatChunk

### class AsyncChatResponse
#### let model
```
let model: String
```
- 描述: 模型名称

#### let chunks
```
let chunks: Iterator<AsyncChatChunk>
```
- 描述: 异步聊天块的迭代器

#### func init
```
init(model: String, chunks: Iterator<AsyncChatChunk>)
```
- 描述: 初始化异步聊天响应
- 参数:
  - `model`: `String`, 模型名称
  - `chunks`: `Iterator<AsyncChatChunk>`, 异步聊天块的迭代器

#### func next
```
func next(): Option<String>
```
- 描述: 获取下一个聊天块的内容

#### prop stream
```
prop stream: Iterator<String>
```
- 描述: 获取聊天流的迭代器

#### prop usage
```
prop usage: Option<ChatUsage>
```
- 描述: 获取聊天使用情况

#### prop dialog
```
prop dialog: Dialog
```
- 描述: 同步获取聊天对话

#### func toString
```
func toString(): String
```
- 描述: 将聊天响应转换为字符串


### interface ChatModel
#### func create
```
func create(request: ChatRequest): ChatResponse
```
- 描述: 聊天模型的同步API
- 参数:
  - `request`: `ChatRequest`, 聊天请求

#### func asyncCreate
```
func asyncCreate(request: ChatRequest): AsyncChatResponse
```
- 描述: 聊天模型的异步API
- 参数:
  - `request`: `ChatRequest`, 聊天请求


### class ChatRequest
#### let dialog
```
let dialog: Dialog
```
- 描述: 表示对话的Dialog对象

#### let stop
```
let stop: Option<Array<String>>
```
- 描述: 表示停止条件的字符串数组

#### let temperature
```
let temperature: Option<Float64>
```
- 描述: 表示生成文本时的温度参数

#### func init
```
public init(message: String)
```
- 描述: 使用单条消息初始化ChatRequest对象
- 参数:
  - `message`: `String`, 用户输入的消息

#### func init
```
public init(messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- 描述: 使用消息数组初始化ChatRequest对象
- 参数:
  - `messages`: `Array<ChatMessage>`, 包含多条消息的数组
  - `temperature`: `Option<Float64>`, 生成文本时的温度参数
  - `stop`: `Option<Array<String>>`, 停止条件的字符串数组

#### func init
```
public init(dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None)
```
- 描述: 使用Dialog对象初始化ChatRequest对象
- 参数:
  - `dialog`: `Dialog`, 包含对话的Dialog对象
  - `temperature`: `Option<Float64>`, 生成文本时的温度参数
  - `stop`: `Option<Array<String>>`, 停止条件的字符串数组

#### func toString
```
public func toString(): String
```
- 描述: 将ChatRequest对象转换为字符串表示


### struct ChatResponse
#### let model
```
let model: String
```
- 描述: 模型名称

#### let dialog
```
let dialog: Dialog
```
- 描述: 对话内容

#### let usage
```
let usage: Option<ChatUsage>
```
- 描述: 使用情况

#### func init
```
public init(dialog: Dialog, model: String, usage!: Option<ChatUsage> = None)
```
- 描述: 初始化ChatResponse对象
- 参数:
  - `dialog`: `Dialog`, 对话内容
  - `model`: `String`, 模型名称
  - `usage`: `Option<ChatUsage>`, 使用情况

#### func toString
```
public func toString(): String
```
- 描述: 将ChatResponse对象转换为字符串


### class ChatUsage
#### let promptTokens
```
public let promptTokens: Int64
```
- 描述: 表示提示词的数量

#### let completionTokens
```
public let completionTokens: Int64
```
- 描述: 表示完成词的数量

#### let totalTokens
```
public let totalTokens: Int64
```
- 描述: 表示总词的数量

#### let timeCost
```
public let timeCost: Option<Duration>
```
- 描述: 表示时间消耗，可能为空

#### func init
```
public init(promptTokens: Int64, completionTokens: Int64, totalTokens: Int64, timeCost: Option<Duration>)
```
- 描述: 初始化ChatUsage对象
- 参数:
  - `promptTokens`: `Int64`, 提示词的数量
  - `completionTokens`: `Int64`, 完成词的数量
  - `totalTokens`: `Int64`, 总词的数量
  - `timeCost`: `Option<Duration>`, 时间消耗，可能为空

#### func toString
```
public func toString(): String
```
- 描述: 将ChatUsage对象转换为字符串表示


### interface EmbeddingModel
#### func create
```
func create(request: EmbeddingRequest): EmbeddingResponse
```
- 描述: 根据给定的嵌入请求创建嵌入响应
- 参数:
  - `request`: `EmbeddingRequest`, 嵌入请求，包含需要嵌入的数据


### struct EmbeddingRequest
#### let prompt
```
let prompt: String
```
- 描述: 用户输入的提示文本

#### let dimensions
```
let dimensions: Option<Int64>
```
- 描述: 嵌入向量的维度，可选参数

#### func init
```
init(prompt: String, dimensions: Option<Int64> = None)
```
- 描述: 初始化EmbeddingRequest结构体
- 参数:
  - `prompt`: `String`, 用户输入的提示文本
  - `dimensions`: `Option<Int64>`, 嵌入向量的维度，可选参数


### struct EmbeddingResponse
#### let data
```
let data: Array<Float64>
```
- 描述: 存储嵌入向量的数组

#### func init
```
init(data: Array<Float64>)
```
- 描述: 初始化EmbeddingResponse结构体
- 参数:
  - `data`: `Array<Float64>`, 嵌入向量数组

#### func toString
```
func toString(): String
```
- 描述: 将EmbeddingResponse转换为字符串表示


### interface ImageModel
#### func create
```
func create(request: ImageRequest): ImageResponse
```
- 描述: 根据图像请求创建图像响应
- 参数:
  - `request`: `ImageRequest`, 图像请求，包含生成图像所需的信息


### struct ImageRequest
#### let prompt
```
let prompt: String
```
- 描述: 生成图像的提示文本

#### let quality
```
let quality: String
```
- 描述: 图像的质量，默认为'standard'

#### let responseFormat
```
let responseFormat: String
```
- 描述: 响应的格式，默认为'url'

#### let size
```
let size: String
```
- 描述: 图像的尺寸，默认为'512x512'

#### let style
```
let style: String
```
- 描述: 图像的风格，默认为'natural'

#### func init
```
init(prompt: String, quality!: String = "standard", responseFormat!: String = "url", size!: String = "512x512", style!: String = "natural")
```
- 描述: 初始化ImageRequest结构体
- 参数:
  - `prompt`: `String`, 生成图像的提示文本
  - `quality`: `String`, 图像的质量，默认为'standard'
  - `responseFormat`: `String`, 响应的格式，默认为'url'
  - `size`: `String`, 图像的尺寸，默认为'512x512'
  - `style`: `String`, 图像的风格，默认为'natural'


### struct ImageResponse
#### let b64Json
```
let b64Json: String
```
- 描述: Base64编码的JSON字符串

#### let url
```
let url: String
```
- 描述: 图像的URL地址

#### let revisedPrompt
```
let revisedPrompt: String
```
- 描述: 修订后的提示文本

#### func init
```
public init(b64Json!: String = "", url!: String = "", revisedPrompt!: String = "")
```
- 描述: 初始化ImageResponse结构体
- 参数:
  - `b64Json`: `String`, Base64编码的JSON字符串
  - `url`: `String`, 图像的URL地址
  - `revisedPrompt`: `String`, 修订后的提示文本


### interface Model
#### prop service
```
prop service: String
```
- 描述: 服务名称，例如 openai

#### prop name
```
prop name: String
```
- 描述: 模型名称，例如 gpt-4o


### class ModelException
#### func init
```
init(msg: String)
```
- 描述: 初始化 ModelException 实例
- 参数:
  - `msg`: `String`, 异常信息


## Package core.rag
### class Document
#### let content
```
public let content: String
```
- 描述: 文档的内容

#### let metadata
```
public let metadata: HashMap<String, String>
```
- 描述: 文档的元数据

#### func init
```
public init(content: String)
```
- 描述: 初始化文档对象，仅包含内容
- 参数:
  - `content`: `String`, 文档的内容

#### func init
```
public init(content: String, metadata!: HashMap<String, String>)
```
- 描述: 初始化文档对象，包含内容和元数据
- 参数:
  - `content`: `String`, 文档的内容
  - `metadata`: `HashMap<String, String>`, 文档的元数据

#### func toString
```
override public func toString(): String
```
- 描述: 将文档对象转换为字符串表示

#### func toPrompt
```
override public func toPrompt(): String
```
- 描述: 将文档对象转换为提示字符串

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- 描述: 获取文档对象的类型模式

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): Document
```
- 描述: 从JSON值创建文档对象
- 参数:
  - `json`: `JsonValue`, 输入的JSON值

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- 描述: 将文档对象转换为JSON值


### interface Retrieval
#### prop sources
```
prop sources: Array<Document>
```
- 描述: 检索器的结果来源


### struct RetrievalInfo

### interface Retriever
#### prop description
```
prop description: String
```
- 描述: 描述检索器将搜索的内容。在动态模式下使用。

#### prop mode
```
mut prop mode: RetrieverMode
```
- 描述: 检索器的模式。

#### func search
```
func search(query: String): Retrieval
```
- 描述: 根据查询字符串进行搜索。
- 参数:
  - `query`: `String`, 搜索的查询字符串。


### class RetrieverException
#### func init
```
init(msg: String)
```
- 描述: 初始化RetrieverException异常
- 参数:
  - `msg`: `String`, 异常信息


### enum RetrieverMode
####  Static
```
Static
```
- 描述: 检索器将在代理回答问题之前用于搜索相关内容

####  Dynamic
```
Dynamic
```
- 描述: 检索器将在代理解决问题的过程中使用

#### func operator ==
```
operator func ==(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否相等
- 参数:
  - `other`: `RetrieverMode`, 另一个RetrieverMode实例

#### func operator !=
```
operator func !=(other: RetrieverMode): Bool
```
- 描述: 比较两个RetrieverMode是否不相等
- 参数:
  - `other`: `RetrieverMode`, 另一个RetrieverMode实例


## Package core.tool
### interface Tool
#### prop name
```
prop name: String
```
- 描述: 工具的唯一标识符

#### prop description
```
prop description: String
```
- 描述: 工具的描述，LLM将根据描述选择工具

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- 描述: 工具输入的类型模式

#### prop retType
```
prop retType: TypeSchema
```
- 描述: 工具的返回类型，目前未使用

#### prop examples
```
prop examples: Array<String>
```
- 描述: 工具调用的示例，可选

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 参数及其值在哈希表中分组
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 包含参数及其值的哈希表


### class ToolException
#### let reason
```
let reason: String
```
- 描述: 异常的原因

#### func init
```
init(reason: String)
```
- 描述: 初始化ToolException实例
- 参数:
  - `reason`: `String`, 异常的原因


### interface ToolManager
#### func addTool
```
func addTool(tool: Tool): Unit
```
- 描述: 添加一个新工具
- 参数:
  - `tool`: `Tool`, 要添加的工具

#### func delTool
```
func delTool(tool: Tool): Unit
```
- 描述: 删除一个工具（如果存在）
- 参数:
  - `tool`: `Tool`, 要删除的工具

#### func addTools
```
func addTools(tools: Array<Tool>): Unit
```
- 描述: 添加多个新工具
- 参数:
  - `tools`: `Array<Tool>`, 要添加的工具列表

#### func clear
```
func clear(): Unit
```
- 描述: 删除所有工具

#### func findTool
```
func findTool(name: String): Option<Tool>
```
- 描述: 根据名称查找工具
- 参数:
  - `name`: `String`, 工具的名称

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取所有工具

#### func searchTool
```
func searchTool(question: String, number!: Int64): Array<Tool>
```
- 描述: 根据问题搜索相关工具
- 参数:
  - `question`: `String`, 搜索的问题
  - `number!`: `Int64`, 返回的工具数量

#### prop enableToolSearch
```
prop enableToolSearch: Bool
```
- 描述: 是否启用工具语义搜索


### struct ToolParameter
#### let name
```
let name: String
```
- 描述: 参数的名称

#### let description
```
let description: String
```
- 描述: 参数的描述

#### let typeSchema
```
let typeSchema: TypeSchema
```
- 描述: 参数的类型模式

#### func init
```
init(name: String, description: String, typeSchema: TypeSchema)
```
- 描述: 初始化ToolParameter结构体
- 参数:
  - `name`: `String`, 参数的名称
  - `description`: `String`, 参数的描述
  - `typeSchema`: `TypeSchema`, 参数的类型模式


### struct ToolResponse
#### let content
```
let content: String
```
- 描述: 工具调用的结果内容

#### func init
```
init(content: String)
```
- 描述: 初始化ToolResponse结构体
- 参数:
  - `content`: `String`, 工具调用的结果内容


## Package instrumentor
### class Instrumentor
#### var BEFORE_CHAT_MODEL_FN
```
static var BEFORE_CHAT_MODEL_FN: Option<(ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 用于在聊天模型执行前调用的函数，接收聊天模型和聊天请求作为参数，返回可能的聊天响应。

#### var BEFORE_CHAT_MODEL_FN2
```
static var BEFORE_CHAT_MODEL_FN2: Option<(String, ChatModel, ChatRequest) -> Option<ChatResponse>>
```
- 描述: 用于在聊天模型执行前调用的函数，接收字符串、聊天模型和聊天请求作为参数，返回可能的聊天响应。

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册在聊天模型执行前调用的函数。
- 参数:
  - `fn`: `(ChatModel, ChatRequest) -> Option<ChatResponse>`, 接收聊天模型和聊天请求作为参数，返回可能的聊天响应的函数。

#### func registerBeforeChatModel
```
static func registerBeforeChatModel(fn: (String, ChatModel, ChatRequest) -> Option<ChatResponse>)
```
- 描述: 注册在聊天模型执行前调用的函数。
- 参数:
  - `fn`: `(String, ChatModel, ChatRequest) -> Option<ChatResponse>`, 接收字符串、聊天模型和聊天请求作为参数，返回可能的聊天响应的函数。

#### var BEFORE_AGENT_RUN_FN
```
static var BEFORE_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Option<AgentResponse>>
```
- 描述: 用于在代理执行前调用的函数，接收代理和代理请求作为参数，返回可能的代理响应。

#### func registerBeforeAgentRun
```
static func registerBeforeAgentRun(fn: (Agent, AgentRequest) -> Option<AgentResponse>)
```
- 描述: 注册在代理执行前调用的函数。
- 参数:
  - `fn`: `(Agent, AgentRequest) -> Option<AgentResponse>`, 接收代理和代理请求作为参数，返回可能的代理响应的函数。

#### var AFTER_AGENT_RUN_FN
```
static var AFTER_AGENT_RUN_FN: Option<(Agent, AgentRequest) -> Unit>
```
- 描述: 用于在代理执行后调用的函数，接收代理和代理请求作为参数，不返回任何值。

#### func registerAfterAgentRun
```
static func registerAfterAgentRun(fn: (Agent, AgentRequest) -> Unit)
```
- 描述: 注册在代理执行后调用的函数。
- 参数:
  - `fn`: `(Agent, AgentRequest) -> Unit`, 接收代理和代理请求作为参数，不返回任何值的函数。


## Package jsonable
### struct FieldSchema

### struct JsonUtils
#### func buildJsonObject
```
func buildJsonObject(key: String, value: String): JsonObject
```
- 描述: 根据给定的键值对构建一个JsonObject对象
- 参数:
  - `key`: `String`, Json对象中的键
  - `value`: `String`, Json对象中的值

#### func buildJsonObject
```
func buildJsonObject(items: Array<(String, String)>): JsonObject
```
- 描述: 根据给定的键值对数组构建一个JsonObject对象
- 参数:
  - `items`: `Array<(String, String)>`, 包含键值对的数组

#### func buildJsonObject
```
func buildJsonObject(items: Array<(String, JsonValue)>): JsonObject
```
- 描述: 根据给定的键值对数组构建一个JsonObject对象，值类型为JsonValue
- 参数:
  - `items`: `Array<(String, JsonValue)>`, 包含键值对的数组，值类型为JsonValue

#### func buildJsonArray
```
func buildJsonArray(items: Array<String>): JsonArray
```
- 描述: 根据给定的字符串数组构建一个JsonArray对象
- 参数:
  - `items`: `Array<String>`, 包含字符串的数组

#### func appendJsonObject
```
func appendJsonObject(obj: JsonObject, items: Array<(String, String)>): JsonObject
```
- 描述: 将给定的键值对数组追加到现有的JsonObject对象中
- 参数:
  - `obj`: `JsonObject`, 现有的JsonObject对象
  - `items`: `Array<(String, String)>`, 包含键值对的数组

#### func asJsonObject
```
func asJsonObject(j: JsonValue): Option<JsonObject>
```
- 描述: 将JsonValue转换为JsonObject对象
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func asJsonArray
```
func asJsonArray(j: JsonValue): Option<JsonArray>
```
- 描述: 将JsonValue转换为JsonArray对象
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func toString
```
func toString(j: JsonValue): Option<String>
```
- 描述: 将JsonValue转换为字符串
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func toFloat
```
func toFloat(j: JsonValue): Option<Float64>
```
- 描述: 将JsonValue转换为浮点数
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func toInt
```
func toInt(j: JsonValue): Option<Int64>
```
- 描述: 将JsonValue转换为整数
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func toBool
```
func toBool(j: JsonValue): Option<Bool>
```
- 描述: 将JsonValue转换为布尔值
- 参数:
  - `j`: `JsonValue`, 待转换的JsonValue对象

#### func getJsonValue
```
func getJsonValue(j: JsonValue, key: String): Option<JsonValue>
```
- 描述: 从JsonValue对象中获取指定键的值
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func getJsonObject
```
func getJsonObject(j: JsonValue, key: String): Option<JsonObject>
```
- 描述: 从JsonValue对象中获取指定键的JsonObject对象
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func getJsonArray
```
func getJsonArray(j: JsonValue, key: String): Option<JsonArray>
```
- 描述: 从JsonValue对象中获取指定键的JsonArray对象
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func getString
```
func getString(j: JsonValue, key: String): Option<String>
```
- 描述: 从JsonValue对象中获取指定键的字符串值
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func getFloat
```
func getFloat(j: JsonValue, key: String): Option<Float64>
```
- 描述: 从JsonValue对象中获取指定键的浮点数值
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func getInt
```
func getInt(key: String, j: JsonValue): Option<Int64>
```
- 描述: 从JsonValue对象中获取指定键的整数值
- 参数:
  - `key`: `String`, 要获取的键
  - `j`: `JsonValue`, JsonValue对象

#### func getBool
```
func getBool(j: JsonValue, key: String): Option<Bool>
```
- 描述: 从JsonValue对象中获取指定键的布尔值
- 参数:
  - `j`: `JsonValue`, JsonValue对象
  - `key`: `String`, 要获取的键

#### func toFloatArray
```
func toFloatArray(j: JsonArray): Array<Float64>
```
- 描述: 将JsonArray对象转换为浮点数数组
- 参数:
  - `j`: `JsonArray`, 待转换的JsonArray对象


### interface Jsonable
#### func getTypeSchema
```
static func getTypeSchema(): TypeSchema
```
- 描述: 获取类型T的模式

#### func fromJsonValue
```
static func fromJsonValue(json: JsonValue): T
```
- 描述: 从JsonValue反序列化为类型T的对象
- 参数:
  - `json`: `JsonValue`, 要反序列化的Json值


### class JsonableException
#### func init
```
public init(msg: String)
```
- 描述: 初始化JsonableException实例
- 参数:
  - `msg`: `String`, 异常信息


### interface ToJsonValue
#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- 描述: 将对象转换为JsonValue


### enum TypeSchema
####  Str
```
Str
```
- 描述: 表示字符串类型

####  Int
```
Int
```
- 描述: 表示整数类型

####  Float
```
Float
```
- 描述: 表示浮点数类型

####  Boolean
```
Boolean
```
- 描述: 表示布尔类型

####  Arr
```
Arr(TypeSchema)
```
- 描述: 表示数组类型，数组元素为TypeSchema类型
- 参数:
  - `ts`: `TypeSchema`, 数组元素的类型

####  Obj
```
Obj(Array<FieldSchema>)
```
- 描述: 表示对象类型，对象属性为FieldSchema类型的数组
- 参数:
  - `fields`: `Array<FieldSchema>`, 对象属性的数组

#### func toJsonValue
```
func toJsonValue(): JsonValue
```
- 描述: 将TypeSchema转换为JsonValue

#### func toString
```
func toString(): String
```
- 描述: 将TypeSchema转换为字符串表示


## Package log
### struct LogUtils
#### func debug
```
func debug(msg: String): Unit
```
- 描述: 记录调试信息
- 参数:
  - `msg`: `String`, 要记录的调试信息

#### func info
```
func info(msg: String): Unit
```
- 描述: 记录一般信息
- 参数:
  - `msg`: `String`, 要记录的信息

#### func info
```
func info(name: String, msg: String): Unit
```
- 描述: 记录带有名称的一般信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `String`, 要记录的信息

#### func info
```
func info(msg: ChatMessage): Unit
```
- 描述: 记录聊天消息信息
- 参数:
  - `msg`: `ChatMessage`, 要记录的聊天消息

#### func info
```
func info(name: String, msg: ChatMessage): Unit
```
- 描述: 记录带有名称的聊天消息信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `ChatMessage`, 要记录的聊天消息

#### func info
```
func info(history: Dialog): Unit
```
- 描述: 记录对话历史信息
- 参数:
  - `history`: `Dialog`, 要记录的对话历史

#### func info
```
func info(name: String, history: Dialog): Unit
```
- 描述: 记录带有名称的对话历史信息
- 参数:
  - `name`: `String`, 日志名称
  - `history`: `Dialog`, 要记录的对话历史

#### func info
```
func info(messages: Array<ChatMessage>): Unit
```
- 描述: 记录聊天消息数组信息
- 参数:
  - `messages`: `Array<ChatMessage>`, 要记录的聊天消息数组

#### func info
```
func info(name: String, messages: Array<ChatMessage>): Unit
```
- 描述: 记录带有名称的聊天消息数组信息
- 参数:
  - `name`: `String`, 日志名称
  - `messages`: `Array<ChatMessage>`, 要记录的聊天消息数组

#### func error
```
func error(msg: String): Unit
```
- 描述: 记录错误信息
- 参数:
  - `msg`: `String`, 要记录的错误信息

#### func error
```
func error(name: String, msg: String): Unit
```
- 描述: 记录带有名称的错误信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `String`, 要记录的错误信息


### struct LogUtils
#### func debug
```
func debug(msg: String): Unit
```
- 描述: 输出调试信息
- 参数:
  - `msg`: `String`, 要输出的调试信息

#### func info
```
func info(msg: String): Unit
```
- 描述: 输出普通信息
- 参数:
  - `msg`: `String`, 要输出的普通信息

#### func info
```
func info(name: String, msg: String): Unit
```
- 描述: 输出带有名称的普通信息
- 参数:
  - `name`: `String`, 信息的名称
  - `msg`: `String`, 要输出的普通信息

#### func info
```
func info(msg: ChatMessage): Unit
```
- 描述: 输出聊天消息
- 参数:
  - `msg`: `ChatMessage`, 要输出的聊天消息

#### func info
```
func info(name: String, msg: ChatMessage): Unit
```
- 描述: 输出带有名称的聊天消息
- 参数:
  - `name`: `String`, 信息的名称
  - `msg`: `ChatMessage`, 要输出的聊天消息

#### func info
```
func info(history: Dialog): Unit
```
- 描述: 输出对话历史
- 参数:
  - `history`: `Dialog`, 要输出的对话历史

#### func info
```
func info(name: String, history: Dialog): Unit
```
- 描述: 输出带有名称的对话历史
- 参数:
  - `name`: `String`, 信息的名称
  - `history`: `Dialog`, 要输出的对话历史

#### func info
```
func info(messages: Array<ChatMessage>): Unit
```
- 描述: 输出聊天消息列表
- 参数:
  - `messages`: `Array<ChatMessage>`, 要输出的聊天消息列表

#### func info
```
func info(name: String, messages: Array<ChatMessage>): Unit
```
- 描述: 输出带有名称的聊天消息列表
- 参数:
  - `name`: `String`, 信息的名称
  - `messages`: `Array<ChatMessage>`, 要输出的聊天消息列表

#### func error
```
func error(msg: String): Unit
```
- 描述: 输出错误信息
- 参数:
  - `msg`: `String`, 要输出的错误信息

#### func error
```
func error(name: String, msg: String): Unit
```
- 描述: 输出带有名称的错误信息
- 参数:
  - `name`: `String`, 信息的名称
  - `msg`: `String`, 要输出的错误信息


## Package mcp
### class MCPClient
#### func init
```
init(command: String, args: Array<String>)
```
- 描述: 初始化MCP客户端，启动MCP服务器进程
- 参数:
  - `command`: `String`, 启动MCP服务器的命令
  - `args`: `Array<String>`, 启动MCP服务器的参数

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取所有工具

#### func callTool
```
func callTool(name: String, args: Array<(String, ToJsonValue)>): CallToolResult
```
- 描述: 调用指定工具并返回结果
- 参数:
  - `name`: `String`, 工具名称
  - `args`: `Array<(String, ToJsonValue)>`, 工具参数


### enum ToolCallContent
####  Text
```
Text(TextContent)
```
- 描述: 表示文本内容的枚举值

####  Image
```
Image(ImageContent)
```
- 描述: 表示图像内容的枚举值

#### func getTypeSchema
```
public static func getTypeSchema(): TypeSchema
```
- 描述: 获取类型模式，当前方法不支持

#### func fromJsonValue
```
public static func fromJsonValue(json: JsonValue): ToolCallContent
```
- 描述: 从JSON值中解析出ToolCallContent对象
- 参数:
  - `json`: `JsonValue`, 输入的JSON值

#### func toJsonValue
```
public func toJsonValue(): JsonValue
```
- 描述: 将ToolCallContent对象转换为JSON值

#### func getValue
```
public func getValue(): String
```
- 描述: 获取ToolCallContent对象的值

### class MCPServer
#### func init
```
init(tools: Array<Tool>)
```
- 描述: 初始化MCP服务器端
- 参数:
  - `tools`: `Array<Tool>`, 服务器提供的工具

#### func start
```
func start(): Unit
```
- 描述: 服务器启动，执行事件循环，监听客户端请求并返回响应

#### func startWith
```
static func startWith(agents: Array<Agent>): Unit
```
- 描述: 将多个 Agent 作为工具，并启动 MCP 服务器
- 参数:
  - `agents`: `Array<Agent>`, 参与作为工具的 Agent

## Package memory
### class ShortMemory
#### func update
```
func update(segment: String): Unit
```
- 描述: 更新内存中的片段
- 参数:
  - `segment`: `String`, 需要更新的片段

#### func search
```
func search(question: String): Array<String>
```
- 描述: 根据用户问题，在内存中查找相关内容
- 参数:
  - `question`: `String`, 用户提出的问题


## Package model
### class ModelConfig
#### func init
```
init(service!: String, kind!: String, name!: String, apiKey!: String = "", baseURL!: String = "")
```
- 描述: 初始化ModelConfig对象。如果未指定apiKey，则使用XX_API_KEY；如果未指定baseURL，则使用XX_BASE_URL。
- 参数:
  - `service`: `String`, 服务名称
  - `kind`: `String`, 模型类型
  - `name`: `String`, 模型名称
  - `apiKey`: `String`, API密钥，默认为空字符串
  - `baseURL`: `String`, 基础URL，默认为空字符串


### struct ModelManager
#### func registerChatModel
```
registerChatModel(modelName: String, buildFn: () -> ChatModel): Unit
```
- 描述: 注册聊天模型。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> ChatModel`, 构建聊天模型的函数

#### func createChatModel
```
createChatModel(modelName: String, temperature!: Option<Float64> = None): ChatModel
```
- 描述: 创建聊天模型。
- 参数:
  - `modelName`: `String`, 模型名称
  - `temperature`: `Option<Float64>`, 温度参数，默认为None

#### func createChatModel
```
createChatModel(modelConfig: ModelConfig, temperature!: Option<Float64> = None): ChatModel
```
- 描述: 根据ModelConfig创建聊天模型。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置
  - `temperature`: `Option<Float64>`, 温度参数，默认为None

#### func registerEmbeddingModel
```
registerEmbeddingModel(modelName: String, buildFn: () -> EmbeddingModel): Unit
```
- 描述: 注册嵌入模型。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> EmbeddingModel`, 构建嵌入模型的函数

#### func createEmbeddingModel
```
createEmbeddingModel(modelName: String): EmbeddingModel
```
- 描述: 创建嵌入模型。
- 参数:
  - `modelName`: `String`, 模型名称

#### func createEmbeddingModel
```
createEmbeddingModel(modelConfig: ModelConfig): EmbeddingModel
```
- 描述: 根据ModelConfig创建嵌入模型。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置

#### func registerImageModel
```
registerImageModel(modelName: String, buildFn: () -> ImageModel): Unit
```
- 描述: 注册图像模型。
- 参数:
  - `modelName`: `String`, 模型名称
  - `buildFn`: `() -> ImageModel`, 构建图像模型的函数

#### func createImageModel
```
createImageModel(modelName: String): ImageModel
```
- 描述: 创建图像模型。
- 参数:
  - `modelName`: `String`, 模型名称

#### func createImageModel
```
createImageModel(modelConfig: ModelConfig): ImageModel
```
- 描述: 根据ModelConfig创建图像模型。
- 参数:
  - `modelConfig`: `ModelConfig`, 模型配置


### struct ModelUtils
#### func makeChat
```
func makeChat(model: ChatModel, dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的聊天模型和对话，生成聊天消息
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `dialog`: `Dialog`, 对话内容
  - `temperature`: `Option<Float64>`, 生成消息时的温度参数
  - `stop`: `Option<Array<String>>`, 生成消息时的停止词

#### func makeChat
```
func makeChat(model: ChatModel, messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的聊天模型和消息列表，生成聊天消息
- 参数:
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `temperature`: `Option<Float64>`, 生成消息时的温度参数
  - `stop`: `Option<Array<String>>`, 生成消息时的停止词

#### func makeChat
```
func makeChat(name: String, model: ChatModel, dialog: Dialog, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的名称、聊天模型和对话，生成聊天消息
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `dialog`: `Dialog`, 对话内容
  - `temperature`: `Option<Float64>`, 生成消息时的温度参数
  - `stop`: `Option<Array<String>>`, 生成消息时的停止词

#### func makeChat
```
func makeChat(name: String, model: ChatModel, messages: Array<ChatMessage>, temperature!: Option<Float64> = None, stop!: Option<Array<String>> = None): Option<ChatMessage>
```
- 描述: 根据给定的名称、聊天模型和消息列表，生成聊天消息
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `temperature`: `Option<Float64>`, 生成消息时的温度参数
  - `stop`: `Option<Array<String>>`, 生成消息时的停止词

#### func makeChatGet
```
func makeChatGet<T>(name: String, model: ChatModel, messages: Array<ChatMessage>, getFn!: (ChatMessage) -> Option<T>): Option<T>
```
- 描述: 根据给定的名称、聊天模型和消息列表，生成聊天消息并应用获取函数
- 参数:
  - `name`: `String`, 名称
  - `model`: `ChatModel`, 聊天模型
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `getFn`: `(ChatMessage) -> Option<T>`, 获取函数

#### func agentMakeChat
```
func agentMakeChat(agent: Agent, messages: Array<ChatMessage>): Option<ChatMessage>
```
- 描述: 根据给定的代理和消息列表，生成聊天消息
- 参数:
  - `agent`: `Agent`, 代理
  - `messages`: `Array<ChatMessage>`, 消息列表

#### func agentMakeChatGet
```
func agentMakeChatGet<T>(agent: Agent, messages: Array<ChatMessage>, getFn!: (ChatMessage) -> Option<T>): Option<T>
```
- 描述: 根据给定的代理和消息列表，生成聊天消息并应用获取函数
- 参数:
  - `agent`: `Agent`, 代理
  - `messages`: `Array<ChatMessage>`, 消息列表
  - `getFn`: `(ChatMessage) -> Option<T>`, 获取函数


## Package parser
### struct OutputParserUtils
#### func extractLastCode
```
func extractLastCode(str: String, lang: String): Option<String>
```
- 描述: 从字符串中提取指定编程语言的最后一段代码。
- 参数:
  - `str`: `String`, 包含代码的字符串。
  - `lang`: `String`, 要提取的编程语言。

#### func extractLastSection
```
func extractLastSection(str: String, section: String): ?String
```
- 描述: 从字符串中提取指定部分的最后一段内容。
- 参数:
  - `str`: `String`, 包含部分内容的字符串。
  - `section`: `String`, 要提取的部分名称。

#### func parseToolCall
```
func parseToolCall(str: String): (toolName: String, arguments: Array<String>)
```
- 描述: 解析工具调用的字符串，返回工具名称和参数列表。
- 参数:
  - `str`: `String`, 包含工具调用的字符串。


## Package rag
### struct RetrieverUtils
#### func createRetriever
```
public static func createRetriever(agent: Agent, source: String, mode: Option<RetrieverMode>, description: Option<String>): Retriever
```
- 描述: 根据提供的源路径和模式创建一个检索器。源路径可以是SQLite数据库路径或Markdown文件路径。
- 参数:
  - `agent`: `Agent`, 代理对象，用于获取模型信息。
  - `source`: `String`, 源路径，可以是SQLite数据库路径或Markdown文件路径。
  - `mode`: `Option<RetrieverMode>`, 检索器模式，可选参数。
  - `description`: `Option<String>`, 检索器的描述信息，可选参数。

#### func createRetriever
```
public static func createRetriever(_agent: Agent, source: Retriever, mode: Option<RetrieverMode>, description: Option<String>): Retriever
```
- 描述: 根据现有的检索器创建一个新的检索器包装器。
- 参数:
  - `_agent`: `Agent`, 代理对象，用于获取模型信息。
  - `source`: `Retriever`, 现有的检索器对象。
  - `mode`: `Option<RetrieverMode>`, 检索器模式，可选参数。
  - `description`: `Option<String>`, 检索器的描述信息，可选参数。


## Package rag.splitter
### class CharacterTextSplitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将输入的文本按照指定的大小进行分割，并返回分割后的文档数组。
- 参数:
  - `text`: `String`, 需要分割的文本内容。


### class DocumentLoader
#### func load
```
func load(): Array<Document>
```
- 描述: 加载文档内容并返回文档数组

#### func loadSplit
```
func loadSplit(splitter: Splitter): Array<Document>
```
- 描述: 根据指定的分割器加载并分割文档内容，返回分割后的文档数组
- 参数:
  - `splitter`: `Splitter`, 用于分割文档的分割器


### class MarkdownSplitter
#### func init
```
init(headersToSplit: Array<(String, String)>, returnEachLine: Bool, stripHeader: Bool)
```
- 描述: 初始化MarkdownSplitter类
- 参数:
  - `headersToSplit`: `Array<(String, String)>`, 需要跟踪的标题
  - `returnEachLine`: `Bool`, 是否返回每一行及其关联的标题
  - `stripHeader`: `Bool`, 是否从块的内容中去除分割标题

#### func split
```
func split(text: String): Array<Document>
```
- 描述: 分割Markdown文件
- 参数:
  - `text`: `String`, Markdown文件内容


### interface Splitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将输入的文本分割成文档数组
- 参数:
  - `text`: `String`, 需要分割的文本


## Package tool
### class NativeFuncTool
#### func init
```
init(name: String, description: String, parameters: Array<(String, String, TypeSchema)>, retType: TypeSchema, examples: Array<String>, execFn: Option<ExecFn>)
```
- 描述: 初始化NativeFuncTool类
- 参数:
  - `name`: `String`, 工具的名称
  - `description`: `String`, 工具的描述
  - `parameters`: `Array<(String, String, TypeSchema)>`, 工具的参数列表
  - `retType`: `TypeSchema`, 工具的返回类型
  - `examples`: `Array<String>`, 工具的使用示例
  - `execFn`: `Option<ExecFn>`, 工具的执行函数

#### prop name
```
prop name: String
```
- 描述: 获取工具的名称

#### prop description
```
prop description: String
```
- 描述: 获取工具的描述

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- 描述: 获取工具的参数列表

#### prop retType
```
prop retType: TypeSchema
```
- 描述: 获取工具的返回类型

#### prop examples
```
prop examples: Array<String>
```
- 描述: 获取工具的使用示例

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 调用工具的执行函数
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 传递给执行函数的参数

#### func addExamples
```
func addExamples(examples: Array<String>): Unit
```
- 描述: 添加工具的使用示例
- 参数:
  - `examples`: `Array<String>`, 要添加的使用示例


### class RetrieverTool
#### func init
```
init(retriever: Retriever)
```
- 描述: 初始化RetrieverTool实例
- 参数:
  - `retriever`: `Retriever`, 用于检索的Retriever实例

#### prop name
```
prop name: String
```
- 描述: 获取工具的名称

#### prop description
```
prop description: String
```
- 描述: 获取工具的描述信息

#### prop parameters
```
prop parameters: Array<ToolParameter>
```
- 描述: 获取工具的参数列表

#### prop retType
```
prop retType: TypeSchema
```
- 描述: 获取工具的返回类型

#### prop examples
```
prop examples: Array<String>
```
- 描述: 获取工具的示例列表

#### func invoke
```
func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```
- 描述: 执行检索操作并返回结果
- 参数:
  - `args`: `HashMap<String, ToJsonValue>`, 包含查询参数的哈希表


### class SimpleToolManager
#### func init
```
init()
```
- 描述: 初始化SimpleToolManager，默认禁用工具搜索功能

#### func init
```
init(tools: Collection<Tool>, enableToolSearch: Bool = false)
```
- 描述: 初始化SimpleToolManager，并设置工具集合和工具搜索功能
- 参数:
  - `tools`: `Collection<Tool>`, 工具集合
  - `enableToolSearch`: `Bool`, 是否启用工具搜索功能

#### func addTool
```
func addTool(tool: Tool): Unit
```
- 描述: 添加工具到管理器中
- 参数:
  - `tool`: `Tool`, 要添加的工具

#### func delTool
```
func delTool(tool: Tool): Unit
```
- 描述: 从管理器中删除工具
- 参数:
  - `tool`: `Tool`, 要删除的工具

#### func addTools
```
func addTools(tools: Array<Tool>): Unit
```
- 描述: 批量添加工具到管理器中
- 参数:
  - `tools`: `Array<Tool>`, 要添加的工具数组

#### func clear
```
func clear(): Unit
```
- 描述: 清空管理器中的所有工具

#### func findTool
```
func findTool(name: String): Option<Tool>
```
- 描述: 根据名称查找工具
- 参数:
  - `name`: `String`, 工具名称

#### func getTools
```
func getTools(): Array<Tool>
```
- 描述: 获取管理器中的所有工具

#### func searchTool
```
func searchTool(question: String, number: Int64 = 5): Array<Tool>
```
- 描述: 根据问题搜索相关工具
- 参数:
  - `question`: `String`, 搜索问题
  - `number`: `Int64`, 返回的工具数量

#### prop enableToolSearch
```
prop enableToolSearch: Bool
```
- 描述: 获取是否启用工具搜索功能


## Package utils
### struct SqliteUtils
#### let SQLITE_ROW
```
static let SQLITE_ROW: Int32
```
- 描述: sqlite3_step() 还未完成执行

#### let SQLITE_DONE
```
static let SQLITE_DONE: Int32
```
- 描述: sqlite3_step() 已执行完成

#### func sqlOpen
```
static func sqlOpen(path: String): CPointer<CPointer<Unit>>
```
- 描述: 打开数据库db文件
- 参数:
  - `path`: `String`, 数据库文件的路径

#### func sqlPrepare
```
static func sqlPrepare(ppDb: CPointer<CPointer<Unit>>, sql: String): CPointer<CPointer<Unit>>
```
- 描述: 预处理sql语句
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `sql`: `String`, 要预处理的SQL语句

#### func sqlStep
```
static func sqlStep(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 执行sql语句
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针

#### func sqlColumnType
```
static func sqlColumnType(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 获取sql结果指定列的数据类型
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnText
```
static func sqlColumnText(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String
```
- 描述: 获取sql结果指定文本类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnBytes
```
static func sqlColumnBytes(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 获取sql结果指定列值的字节数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnInt64
```
static func sqlColumnInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int64
```
- 描述: 获取sql结果指定Int64类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnDouble
```
static func sqlColumnDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Float64
```
- 描述: 获取sql结果指定Float64类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnBlob
```
static func sqlColumnBlob(ppStmt: CPointer<CPointer<Unit>>, i: Int32): CPointer<Unit>
```
- 描述: 获取sql结果blob类型列的值
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlColumnCount
```
static func sqlColumnCount(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取sql结果列数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针

#### func sqlColumnName
```
static func sqlColumnName(ppStmt: CPointer<CPointer<Unit>>, n: Int32): String
```
- 描述: 获取sql结果指定列名
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `n`: `Int32`, 列的索引

#### func sqlColumnDecltype
```
static func sqlColumnDecltype(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String
```
- 描述: 获取sql结果指定列声明的数据类型
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 列的索引

#### func sqlReset
```
static func sqlReset(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 重置sql语句
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针

#### func sqlBusyTimeout
```
static func sqlBusyTimeout(ppDb: CPointer<CPointer<Unit>>, ms: Int32): Int32
```
- 描述: 设置超时毫秒数
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `ms`: `Int32`, 超时毫秒数

#### func sqlChanges
```
static func sqlChanges(ppDb: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取最近执行的sql语句的修改数量
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlLastInsertRowid
```
static func sqlLastInsertRowid(ppDb: CPointer<CPointer<Unit>>): Int64
```
- 描述: 获取最近插入行的ID
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlSoftHeapLimit
```
static func sqlSoftHeapLimit(n: Int32): Unit
```
- 描述: 设置堆内存上限
- 参数:
  - `n`: `Int32`, 堆内存上限值

#### func sqlBindParameterCount
```
static func sqlBindParameterCount(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 获取sql语句绑定参数数量
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针

#### func sqlBindNull
```
static func sqlBindNull(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32
```
- 描述: 绑定空值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 参数的索引

#### func sqlBindInt
```
static func sqlBindInt(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int32): Int32
```
- 描述: 绑定Int32值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 参数的索引
  - `iValue`: `Int32`, 要绑定的Int32值

#### func sqlBindInt64
```
static func sqlBindInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int64): Int32
```
- 描述: 绑定Int64值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 参数的索引
  - `iValue`: `Int64`, 要绑定的Int64值

#### func sqlBindDouble
```
static func sqlBindDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32, rValue: Float64): Int32
```
- 描述: 绑定Float64值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 参数的索引
  - `rValue`: `Float64`, 要绑定的Float64值

#### func sqlBindText
```
static func sqlBindText(ppStmt: CPointer<CPointer<Unit>>, i: Int32, data: String)
```
- 描述: 绑定文本值到sql语句指定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针
  - `i`: `Int32`, 参数的索引
  - `data`: `String`, 要绑定的文本值

#### func sqlClearBindings
```
static func sqlClearBindings(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 解除sql语句绑定参数
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针

#### func sqlExec
```
static func sqlExec(ppDb: CPointer<CPointer<Unit>>, sql: String)
```
- 描述: 指定数据库执行sql命令
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针
  - `sql`: `String`, 要执行的SQL语句

#### func sqlClose
```
static func sqlClose(ppDb: CPointer<CPointer<Unit>>): Int32
```
- 描述: 关闭数据库连接
- 参数:
  - `ppDb`: `CPointer<CPointer<Unit>>`, 数据库连接指针

#### func sqlFinalize
```
static func sqlFinalize(ppStmt: CPointer<CPointer<Unit>>): Int32
```
- 描述: 销毁sql语句对象，释放内存
- 参数:
  - `ppStmt`: `CPointer<CPointer<Unit>>`, SQL语句指针


## Package utils.http
### class HttpStream
#### func put
```
func put(data: String): Unit
```
- 描述: 将数据放入队列中
- 参数:
  - `data`: `String`, 要放入队列的数据

#### func markEOF
```
func markEOF(): Unit
```
- 描述: 标记流结束

#### func markError
```
func markError(): Unit
```
- 描述: 标记流错误

#### func next
```
override public func next(): Option<String>
```
- 描述: 获取队列中的下一个数据


## Package utils.ohos
### interface CJ2JS
#### func toJS
```
func toJS(context: JSContext): JSValue
```
- 描述: 将当前对象转换为JavaScript对象
- 参数:
  - `context`: `JSContext`, JavaScript上下文，用于执行转换操作


### interface JS2CJ
#### func fromJS
```
static func fromJS(jsValue: JSValue): T
```
- 描述: 将JSValue转换为泛型类型T
- 参数:
  - `jsValue`: `JSValue`, 需要转换的JSValue对象


## Package vdb
### class FaissVectorDatabase
#### func init
```
init(dimension: Int64 = 1536)
```
- 描述: 初始化Faiss向量数据库
- 参数:
  - `dimension`: `Int64`, 向量的维度，默认值为1536

#### func close
```
close(): Unit
```
- 描述: 关闭Faiss向量数据库并释放资源

#### func save
```
save(filePath: String): Unit
```
- 描述: 将Faiss向量数据库保存到指定文件路径
- 参数:
  - `filePath`: `String`, 保存数据库的文件路径

#### func load
```
load(filePath: String): FaissVectorDatabase
```
- 描述: 从指定文件路径加载Faiss向量数据库
- 参数:
  - `filePath`: `String`, 加载数据库的文件路径

#### func addVector
```
addVector(vector: Vector): Unit
```
- 描述: 向Faiss向量数据库中添加一个向量
- 参数:
  - `vector`: `Vector`, 要添加的向量

#### func search
```
search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<Int64>
```
- 描述: 在Faiss向量数据库中搜索与查询向量最接近的向量
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number`: `Int64`, 返回的最接近向量的数量，默认值为5
  - `minDistance`: `Float64`, 最小距离阈值，默认值为0.6


### class InMemoryVectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- 描述: 向内存中的向量数据库添加一个向量
- 参数:
  - `vector`: `Vector`, 要添加的向量

#### func search
```
func search(queryVec: Vector, number: Int64 = 5, minDistance: Float64 = 0.6): Array<Int64>
```
- 描述: 在内存中的向量数据库中搜索与查询向量最相似的向量
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number`: `Int64`, 返回的最相似向量的数量
  - `minDistance`: `Float64`, 最小相似度阈值

#### func save
```
func save(filePath: String): Unit
```
- 描述: 保存内存中的向量数据库到文件
- 参数:
  - `filePath`: `String`, 文件路径

#### func load
```
func load(filePath: String): InMemoryVectorDatabase
```
- 描述: 从文件加载内存中的向量数据库
- 参数:
  - `filePath`: `String`, 文件路径


### interface IndexMap
#### func add
```
func add(content: T): Unit
```
- 描述: 根据添加顺序确定索引。
- 参数:
  - `content`: `T`, 要添加的内容。

#### func get
```
func get(index: Int64): T
```
- 描述: 根据索引获取内容。
- 参数:
  - `index`: `Int64`, 内容的索引。

#### func save
```
func save(filePath: String): Unit
```
- 描述: 将内容保存到指定文件路径。
- 参数:
  - `filePath`: `String`, 文件保存路径。

#### func load
```
static func load(filePath: String): Self
```
- 描述: 从指定文件路径加载内容。
- 参数:
  - `filePath`: `String`, 文件加载路径。


### class JsonlIndexMap<T>
#### func add
```
func add(content: T): Unit
```
- 描述: 将内容添加到索引映射中
- 参数:
  - `content`: `T`, 要添加的内容

#### func get
```
func get(index: Int64): T
```
- 描述: 根据索引获取内容
- 参数:
  - `index`: `Int64`, 内容的索引

#### func save
```
func save(filePath: String): Unit
```
- 描述: 将索引映射保存到指定文件路径
- 参数:
  - `filePath`: `String`, 文件保存路径

#### func load
```
static func load(filePath: String): JsonlIndexMap<T>
```
- 描述: 从指定文件路径加载索引映射
- 参数:
  - `filePath`: `String`, 文件加载路径


### class SemanticMap
#### let vectorDB
```
public let vectorDB: VDB
```
- 描述: 向量数据库实例

#### let indexMap
```
public let indexMap: IMAP
```
- 描述: 索引映射实例

#### func init
```
public init(vectorDB: VDB, indexMap: IMAP, embeddingModel: Option<EmbeddingModel> = None)
```
- 描述: 初始化SemanticMap实例
- 参数:
  - `vectorDB`: `VDB`, 向量数据库实例
  - `indexMap`: `IMAP`, 索引映射实例
  - `embeddingModel`: `Option<EmbeddingModel>`, 嵌入模型实例，可选

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- 描述: 获取或设置嵌入模型

#### func put
```
public func put(key: String, value: T): Unit
```
- 描述: 将键值对存入SemanticMap
- 参数:
  - `key`: `String`, 键
  - `value`: `T`, 值

#### func search
```
public func search(query: String, number: Int64 = 5, minDistance: Float64 = 0.3): Array<T>
```
- 描述: 查找相似数据
- 参数:
  - `query`: `String`, 查询字符串
  - `number`: `Int64`, 返回结果的数量，默认为5
  - `minDistance`: `Float64`, 最小距离阈值，默认为0.3

#### func asRetriever
```
public func asRetriever(): Retriever
```
- 描述: 将SemanticMap转换为Retriever

#### func save
```
public func save(dirPath: String): Unit
```
- 描述: 保存SemanticMap到指定目录
- 参数:
  - `dirPath`: `String`, 目录路径

#### func load
```
public static func load(dirPath: String): SemanticMap<VDB, IMAP, T>
```
- 描述: 从指定目录加载SemanticMap
- 参数:
  - `dirPath`: `String`, 目录路径


### class SemanticSet
#### func init
```
public init(vectorDB!: VDB, indexMap!: IMAP, embeddingModel!: Option<EmbeddingModel> = None)
```
- 描述: 初始化SemanticSet实例
- 参数:
  - `vectorDB`: `VDB`, 向量数据库实例
  - `indexMap`: `IMAP`, 索引映射实例
  - `embeddingModel`: `Option<EmbeddingModel>`, 嵌入模型，可选参数，默认为None

#### prop embeddingModel
```
public mut prop embeddingModel: EmbeddingModel
```
- 描述: 获取或设置嵌入模型

#### func put
```
public func put(value: T): Unit
```
- 描述: 将值插入SemanticSet中
- 参数:
  - `value`: `T`, 要插入的值

#### func search
```
public func search(query: String, number!: Int64 = 5, minDistance!: Float64 = 0.3): Array<T>
```
- 描述: 根据查询字符串搜索SemanticSet中的值
- 参数:
  - `query`: `String`, 查询字符串
  - `number`: `Int64`, 返回结果的数量，默认为5
  - `minDistance`: `Float64`, 最小距离阈值，默认为0.3

#### func asRetriever
```
public func asRetriever(): Retriever
```
- 描述: 将SemanticSet转换为Retriever实例

#### func save
```
public func save(dirPath: String): Unit
```
- 描述: 将SemanticSet保存到指定目录
- 参数:
  - `dirPath`: `String`, 保存目录路径

#### func load
```
public static func load(dirPath: String): SemanticSet<VDB, IMAP, T>
```
- 描述: 从指定目录加载SemanticSet实例
- 参数:
  - `dirPath`: `String`, 加载目录路径


### class SimpleIndexMap
#### func add
```
override public func add(content: String): Unit
```
- 描述: 将内容添加到索引映射中
- 参数:
  - `content`: `String`, 要添加的内容

#### func get
```
override public func get(index: Int64): String
```
- 描述: 根据索引获取内容
- 参数:
  - `index`: `Int64`, 要获取内容的索引

#### func serialize
```
public func serialize(): DataModel
```
- 描述: 将索引映射序列化为数据模型

#### func deserialize
```
public static func deserialize(dm: DataModel): SimpleIndexMap
```
- 描述: 从数据模型反序列化为索引映射
- 参数:
  - `dm`: `DataModel`, 要反序列化的数据模型

#### func save
```
override public func save(filePath: String): Unit
```
- 描述: 将索引映射保存到文件中
- 参数:
  - `filePath`: `String`, 文件路径

#### func load
```
redef public static func load(filePath:String): SimpleIndexMap
```
- 描述: 从文件中加载索引映射
- 参数:
  - `filePath`: `String`, 文件路径


### class Vector
#### let vector
```
let vector: Array<Float64>
```
- 描述: 存储向量的数组

#### func init
```
init(vec: Array<Float64>)
```
- 描述: 初始化向量对象
- 参数:
  - `vec`: `Array<Float64>`, 用于初始化向量的浮点数数组


### class VectorBuilder
#### func createEmbeddingVector
```
func createEmbeddingVector(content: String): Vector
```
- 描述: 根据输入的内容生成嵌入向量。
- 参数:
  - `content`: `String`, 用于生成嵌入向量的文本内容。


### interface VectorDatabase
#### func addVector
```
func addVector(vector: Vector): Unit
```
- 描述: 将向量添加到数据库中
- 参数:
  - `vector`: `Vector`, 要添加的向量

#### func search
```
func search(queryVec: Vector, number!: Int64, minDistance!: Float64): Array<Int64>
```
- 描述: 查询数据库并找到相似数据的索引
- 参数:
  - `queryVec`: `Vector`, 查询向量
  - `number!`: `Int64`, 要返回的相似数据的数量
  - `minDistance!`: `Float64`, 最小距离阈值

#### func save
```
func save(filePath: String): Unit
```
- 描述: 将数据库保存到文件中
- 参数:
  - `filePath`: `String`, 文件路径

#### func load
```
static func load(filePath: String): Self
```
- 描述: 从文件中加载数据库
- 参数:
  - `filePath`: `String`, 文件路径


