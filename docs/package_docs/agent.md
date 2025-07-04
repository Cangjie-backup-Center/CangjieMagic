## Package agent
- [Package agent](#package-agent)
  - [class AgentExecutionInfo](#class-agentexecutioninfo)
    - [func addMessage](#func-addmessage)
    - [func addMessages](#func-addmessages)
    - [func addQuestion](#func-addquestion)
    - [func addStepMessage](#func-addstepmessage)
    - [prop chatRound](#prop-chatround)
    - [func init](#func-init)
    - [prop messages](#prop-messages)
    - [func removeLastMessage](#func-removelastmessage)
    - [prop retrievalInfo](#prop-retrievalinfo)
    - [func setAnswer](#func-setanswer)
    - [prop verboseInfo](#prop-verboseinfo)
  - [class BaseAgent](#class-baseagent)
    - [prop description](#prop-description)
    - [prop executor](#prop-executor)
    - [func init](#func-init-1)
    - [prop interceptor](#prop-interceptor)
    - [prop memory](#prop-memory)
    - [prop model](#prop-model)
    - [prop name](#prop-name)
    - [prop retriever](#prop-retriever)
    - [prop systemPrompt](#prop-systemprompt)
    - [prop temperature](#prop-temperature)
    - [prop toolManager](#prop-toolmanager)
  - [class ConversationAgent](#class-conversationagent)
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat)
    - [func init](#func-init-1)
  - [class DispatchAgent](#class-dispatchagent)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class GroupAsAgent](#class-groupasagent)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class HumanAgent](#class-humanagent)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class ToolAgent<T>](#class-toolagent<t>)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
  - [class ToolSelectAgent](#class-toolselectagent)
    - [func chat](#func-chat-1)
    - [func init](#func-init-1)
    - [func select](#func-select)

### class AgentExecutionInfo
#### func addMessage
```
public func addMessage(msg: Message): Unit
```
- Description: Adds a message to the message list
- Parameters:
  - `msg`: `Message`, The message to add

#### func addMessages
```
public func addMessages(msgs: Array<Message>): Unit
```
- Description: Adds multiple messages to the message list
- Parameters:
  - `msgs`: `Array<Message>`, The messages to add

#### func addQuestion
```
public func addQuestion(question: String): Unit
```
- Description: Adds a question to the message list
- Parameters:
  - `question`: `String`, The question to add

#### func addStepMessage
```
public func addStepMessage(msg: Message): Unit
```
- Description: Adds a message to both the message list and step messages
- Parameters:
  - `msg`: `Message`, The message to add

#### prop chatRound
```
override public prop chatRound: ChatRound
```
- Description: Gets the chat round information

#### func init
```
public init(agent: Agent)
```
- Description: Initializes the AgentExecutionInfo with the given agent
- Parameters:
  - `agent`: `Agent`, The agent to initialize with

#### prop messages
```
override public prop messages: MessageList
```
- Description: Gets the message list

#### func removeLastMessage
```
public func removeLastMessage(): Unit
```
- Description: Removes the last message from the message list

#### prop retrievalInfo
```
override public prop retrievalInfo: ArrayList<RetrievalInfo>
```
- Description: Bookkeeping information during the agent execution

#### func setAnswer
```
override public func setAnswer(answer: String): Unit
```
- Description: Sets the answer
- Parameters:
  - `answer`: `String`, The answer to set

#### prop verboseInfo
```
override public prop verboseInfo: Iterator<String>
```
- Description: Gets verbose information, only accessible when verbose is set to true in AgentRequest


### class BaseAgent
#### prop description
```
prop description: String
```
- Description: Gets the description of the agent

#### prop executor
```
prop executor: AgentExecutor
```
- Description: Gets or sets the executor for the agent

#### func init
```
init(model: ChatModel, name: String = "Base Agent", description: String = "", temperature: Option<Float64> = None, systemPrompt: String = "", toolManager: ToolManager = SimpleToolManager(), executor: Option<AgentExecutor> = None, retriever: Option<Retriever> = None, memory: Option<Memory> = None, interceptor: Option<Interceptor> = None)
```
- Description: Constructor for BaseAgent class
- Parameters:
  - `model`: `ChatModel`, The chat model to be used by the agent
  - `name`: `String`, The name of the agent, defaults to "Base Agent"
  - `description`: `String`, Description of the agent, defaults to empty string
  - `temperature`: `Option<Float64>`, Temperature parameter for the agent, defaults to None
  - `systemPrompt`: `String`, System prompt for the agent, defaults to empty string
  - `toolManager`: `ToolManager`, Tool manager for the agent, defaults to SimpleToolManager
  - `executor`: `Option<AgentExecutor>`, Executor for the agent, defaults to None
  - `retriever`: `Option<Retriever>`, Retriever for the agent, defaults to None
  - `memory`: `Option<Memory>`, Memory for the agent, defaults to None
  - `interceptor`: `Option<Interceptor>`, Interceptor for the agent, defaults to None

#### prop interceptor
```
prop interceptor: Option<Interceptor>
```
- Description: Gets or sets the interceptor for the agent

#### prop memory
```
prop memory: Option<Memory>
```
- Description: Gets or sets the memory for the agent

#### prop model
```
prop model: ChatModel
```
- Description: Gets or sets the chat model for the agent

#### prop name
```
prop name: String
```
- Description: Gets the name of the agent

#### prop retriever
```
prop retriever: Option<Retriever>
```
- Description: Gets or sets the retriever for the agent

#### prop systemPrompt
```
prop systemPrompt: String
```
- Description: Gets or sets the system prompt for the agent

#### prop temperature
```
prop temperature: Option<Float64>
```
- Description: Gets or sets the temperature parameter for the agent

#### prop toolManager
```
prop toolManager: ToolManager
```
- Description: Gets the tool manager for the agent


### class ConversationAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Processes an asynchronous chat request, wraps the response, and returns it.
- Parameters:
  - `request`: `AgentRequest`, The asynchronous chat request to be processed.

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes a chat request, saves the conversation, and returns the response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be processed.

#### func init
```
init(agent: Agent)
```
- Description: Initializes a new ConversationAgent with the given agent.
- Parameters:
  - `agent`: `Agent`, The agent to be wrapped as a conversation agent.


### class DispatchAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Processes the chat request asynchronously and dispatches it to the appropriate agent.
- Parameters:
  - `request`: `AgentRequest`, The request containing the user's question.

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes the chat request and dispatches it to the appropriate agent.
- Parameters:
  - `request`: `AgentRequest`, The request containing the user's question.

#### func init
```
init(model: String)
```
- Description: Initializes the DispatchAgent with the specified model.
- Parameters:
  - `model`: `String`, The model to be used by the DispatchAgent.


### class GroupAsAgent
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Dispatches the chat request asynchronously to the group and returns the response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be dispatched asynchronously.

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Dispatches the chat request to the group and returns the response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be dispatched.

#### func init
```
init(group: AgentGroup, description!: String)
```
- Description: Initializes the GroupAsAgent with a group and description.
- Parameters:
  - `group`: `AgentGroup`, The group of agents to dispatch the question to.
  - `description`: `String`, The description of the agent.


### class HumanAgent
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes the chat request by delegating the question to the configured question-answer function and returns the response.
- Parameters:
  - `request`: `AgentRequest`, The request containing the question to be answered.

#### func init
```
init(qaFunc!: Option<(String) -> String> = None)
```
- Description: Initializes the HumanAgent with an optional question-answer function. If not provided, defaults to a console UI.
- Parameters:
  - `qaFunc!`: `Option<(String) -> String>`, An optional function that takes a string question and returns a string answer.


### class ToolAgent<T>
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes the agent request by executing the provided function and returns an agent response.
- Parameters:
  - `request`: `AgentRequest`, The request containing the question to be processed by the agent.

#### func init
```
init(fn!: (String) -> T)
```
- Description: Initializes the ToolAgent with a function that takes a String and returns a generic type T.
- Parameters:
  - `fn!`: `(String) -> T`, A function that processes a String input and returns a generic type T.


### class ToolSelectAgent
#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes the agent request and returns a response.
- Parameters:
  - `request`: `AgentRequest`, The request to be processed by the agent.

#### func init
```
init(model: ChatModel, tools: Array<Tool>)
```
- Description: Initializes the ToolSelectAgent with a chat model and a list of tools.
- Parameters:
  - `model`: `ChatModel`, The chat model to be used by the agent.
  - `tools`: `Array<Tool>`, A list of tools available for selection.

#### func select
```
func select(question: String): Option<ToolRequest>
```
- Description: Selects a proper tool for the given question.
- Parameters:
  - `question`: `String`, The question for which a tool needs to be selected.


