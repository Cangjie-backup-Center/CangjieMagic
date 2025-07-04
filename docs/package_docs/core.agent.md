## Package core.agent
- [Package core.agent](#package-core.agent)
  - [interface Agent](#interface-agent)
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat)
    - [prop description](#prop-description)
    - [prop executor](#prop-executor)
    - [prop interceptor](#prop-interceptor)
    - [prop memory](#prop-memory)
    - [prop model](#prop-model)
    - [prop name](#prop-name)
    - [prop retriever](#prop-retriever)
    - [prop systemPrompt](#prop-systemprompt)
    - [prop temperature](#prop-temperature)
    - [prop toolManager](#prop-toolmanager)
  - [interface AgentExecution](#interface-agentexecution)
    - [prop chatRound](#prop-chatround)
    - [prop messages](#prop-messages)
    - [prop retrievalInfo](#prop-retrievalinfo)
    - [func setAnswer](#func-setanswer)
    - [prop verboseInfo](#prop-verboseinfo)
  - [class AgentExecutionException](#class-agentexecutionexception)
    - [func init](#func-init)
  - [interface AgentExecutor](#interface-agentexecutor)
    - [func asyncRun](#func-asyncrun)
    - [prop name](#prop-name-1)
    - [func run](#func-run)
  - [interface AgentGroup](#interface-agentgroup)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func chat](#func-chat-1)
    - [func operator []](#func-operator-[])
  - [class AgentRequest](#class-agentrequest)
    - [let conversation](#let-conversation)
    - [func init](#func-init-1)
    - [let maxTool](#let-maxtool)
    - [let question](#let-question)
    - [let verbose](#let-verbose)
  - [struct AgentResponse](#struct-agentresponse)
    - [let content](#let-content)
    - [prop execution](#prop-execution)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
  - [class AsyncAgentResponse](#class-asyncagentresponse)
    - [prop content](#prop-content)
    - [prop execution](#prop-execution-1)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [func next](#func-next)
  - [class Interceptor](#class-interceptor)
    - [func init](#func-init-1)
  - [enum InterceptorMode](#enum-interceptormode)
    - [enumeration Always](#enumeration-always)
    - [enumeration Conditional](#enumeration-conditional)
    - [enumeration Periodic](#enumeration-periodic)

### interface Agent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Query the agent and get the answer. It returns the agent reply in stream
- Parameters:
  - `request`: `AgentRequest`, The request to the agent

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Query the agent and get the answer. It may throw AgentExecutionException
- Parameters:
  - `request`: `AgentRequest`, The request to the agent

#### prop description
```
prop description: String
```
- Description: Functionality description of the agent

#### prop executor
```
mut prop executor: AgentExecutor
```
- Description: The underlying agent executor

#### prop interceptor
```
mut prop interceptor: Option<Interceptor>
```
- Description: Set the agent interceptor

#### prop memory
```
mut prop memory: Option<Memory>
```
- Description: Memory the agent will use

#### prop model
```
mut prop model: ChatModel
```
- Description: Chat model the agent will use

#### prop name
```
prop name: String
```
- Description: Name of the agent

#### prop retriever
```
mut prop retriever: Option<Retriever>
```
- Description: Retriever the agent can use

#### prop systemPrompt
```
mut prop systemPrompt: String
```
- Description: System prompt of the agent

#### prop temperature
```
mut prop temperature: Option<Float64>
```
- Description: Temperature the agent will pass to the LLM

#### prop toolManager
```
prop toolManager: ToolManager
```
- Description: Tools the agent can use


### interface AgentExecution
#### prop chatRound
```
prop chatRound: ChatRound
```
- Description: The current chat round, including the question, internal assistant execution messages, and the answer

#### prop messages
```
prop messages: MessageList
```
- Description: Complete messages, including system prompts, user questions, internal assistant messages

#### prop retrievalInfo
```
prop retrievalInfo: ArrayList<RetrievalInfo>
```
- Description: RAG info when used

#### func setAnswer
```
func setAnswer(answer: String): Unit
```
- Description: Internally used thought it's public
- Parameters:
  - `answer`: `String`, The answer to set

#### prop verboseInfo
```
prop verboseInfo: Iterator<String>
```
- Description: Only access this field when setting verbose: true in AgentRequest


### class AgentExecutionException
#### func init
```
init(msg: String)
```
- Description: Initializes a new instance of the AgentExecutionException class with a specified error message.
- Parameters:
  - `msg`: `String`, The error message that explains the reason for the exception.


### interface AgentExecutor
#### func asyncRun
```
func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse
```
- Description: Runs the agent asynchronously with the given request and returns a response
- Parameters:
  - `agent`: `Agent`, The agent to be executed
  - `request`: `AgentRequest`, The request to be processed by the agent

#### prop name
```
prop name: String
```
- Description: Name of the executor

#### func run
```
func run(agent: Agent, request: AgentRequest): AgentResponse
```
- Description: Runs the agent with the given request and returns a response
- Parameters:
  - `agent`: `Agent`, The agent to be executed
  - `request`: `AgentRequest`, The request to be processed by the agent


### interface AgentGroup
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Asynchronously chat with the agent group using a request
- Parameters:
  - `request`: `AgentRequest`, The request to send to the agent group

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Chat with the agent group using a request
- Parameters:
  - `request`: `AgentRequest`, The request to send to the agent group

#### func chat
```
func chat(request: AgentRequest, maxRound!: Int64): AgentResponse
```
- Description: Chat with the agent group using a request and a maximum number of rounds
- Parameters:
  - `request`: `AgentRequest`, The request to send to the agent group
  - `maxRound!`: `Int64`, The maximum number of rounds for the chat

#### func operator operator []
```
operator func [](memberName: String): Agent
```
- Description: Find the agent according to its name
- Parameters:
  - `memberName`: `String`, The name of the agent to find


### class AgentRequest
#### let conversation
```
let conversation: Option<Conversation>
```
- Description: Conversation between the user and agent

#### func init
```
public init(question: String, conversation!: Option<Conversation> = None, verbose!: Bool = false, maxTool!: Int64 = 10)
```
- Description: Constructor for AgentRequest
- Parameters:
  - `question`: `String`, The current user question
  - `conversation`: `Option<Conversation>`, Conversation between the user and agent
  - `verbose`: `Bool`, Dump internal execution information
  - `maxTool`: `Int64`, The maximum number of tools that can be used when enable tool filter

#### let maxTool
```
let maxTool: Int64
```
- Description: The maximum number of tools that can be used when enable tool filter

#### let question
```
let question: String
```
- Description: The current user question

#### let verbose
```
let verbose: Bool
```
- Description: Dump internal execution information


### struct AgentResponse
#### let content
```
let content: String
```
- Description: The execution result

#### prop execution
```
prop execution: AgentExecution
```
- Description: Gets the execution details

#### func init
```
public init(content: String)
```
- Description: Initializes the AgentResponse with content
- Parameters:
  - `content`: `String`, The execution result

#### func init
```
public init(content: String, execution!: AgentExecution)
```
- Description: Initializes the AgentResponse with content and execution details
- Parameters:
  - `content`: `String`, The execution result
  - `execution`: `AgentExecution`, The execution details


### class AsyncAgentResponse
#### prop content
```
public prop content: String
```
- Description: The execution result. This is a synchronous method, which will wait until the executor completes

#### prop execution
```
prop execution: AgentExecution
```
- Description: The asynchronous execution response from an agent executor

#### func init
```
public init(chunks: Iterator<String>)
```
- Description: Constructor for AsyncAgentResponse with chunks
- Parameters:
  - `chunks`: `Iterator<String>`, Iterator of strings representing chunks of data

#### func init
```
public init(chunks: Iterator<String>, execution: AgentExecution)
```
- Description: Constructor for AsyncAgentResponse with chunks and execution
- Parameters:
  - `chunks`: `Iterator<String>`, Iterator of strings representing chunks of data
  - `execution`: `AgentExecution`, Agent execution context

#### func next
```
override public func next(): Option<String>
```
- Description: Gets the next chunk of data


### class Interceptor
#### func init
```
init(agent: Agent, mode: InterceptorMode = InterceptorMode.Always)
```
- Description: Initializes a new Interceptor instance with the specified agent and mode.
- Parameters:
  - `agent`: `Agent`, The agent to be used by the interceptor.
  - `mode`: `InterceptorMode`, The mode in which the interceptor operates. Defaults to InterceptorMode.Always.


### enum InterceptorMode
####  Always
```
Always
```
- Description: Always intercept the request

####  Conditional
```
Conditional((AgentRequest) -> Bool)
```
- Description: Intercept the request when the condition is true
- Parameters:
  - `condition`: `(AgentRequest) -> Bool`, The condition function to determine interception

####  Periodic
```
Periodic(Int64)
```
- Description: Intercept the request periodically
- Parameters:
  - `period`: `Int64`, The interval period for interception


