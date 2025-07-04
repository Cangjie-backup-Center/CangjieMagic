## Package agent_group
- [Package agent_group](#package-agent_group)
  - [interface AgentCollaboration](#interface-agentcollaboration)
    - [func ()](#func-())
    - [func ()](#func-()-1)
    - [func <=](#func-<=)
    - [func |](#func-|)
  - [class FreeGroup](#class-freegroup)
    - [func chat](#func-chat)
    - [func chat](#func-chat-1)
    - [func discuss](#func-discuss)
    - [func init](#func-init)
    - [func operator []](#func-operator-[])
    - [func operator |](#func-operator-|)
  - [enum FreeGroupMode](#enum-freegroupmode)
    - [enumeration Auto](#enumeration-auto)
    - [enumeration RoundRobin](#enumeration-roundrobin)
  - [class LeaderGroup](#class-leadergroup)
    - [func asyncChat](#func-asyncchat)
    - [func chat](#func-chat-1)
    - [func chat](#func-chat-1)
    - [func operator []](#func-operator-[]-1)
  - [class LinearGroup](#class-lineargroup)
    - [func asyncChat](#func-asyncchat-1)
    - [func chat](#func-chat-1)
    - [func chat](#func-chat-1)
    - [func operator []](#func-operator-[]-1)

### interface AgentCollaboration
#### func operator ()
```
operator func ()(prev: Agent): LinearGroup
```
- Description: Creates a LinearGroup from a single agent.
- Parameters:
  - `prev`: `Agent`, The agent to start the linear group.

#### func operator ()
```
operator func ()(prev: LinearGroup): LinearGroup
```
- Description: Extends an existing LinearGroup.
- Parameters:
  - `prev`: `LinearGroup`, The existing linear group to extend.

#### func operator <=
```
operator func <=(members: Array<Agent>): LeaderGroup
```
- Description: Creates a LeaderGroup from an array of agents.
- Parameters:
  - `members`: `Array<Agent>`, An array of agents to form the group.

#### func operator |
```
operator func |(member: Agent): FreeGroup
```
- Description: Creates a FreeGroup with a single agent.
- Parameters:
  - `member`: `Agent`, The agent to include in the free group.


### class FreeGroup
#### func chat
```
chat(request: AgentRequest): AgentResponse
```
- Description: Processes a chat request with default maximum rounds
- Parameters:
  - `request`: `AgentRequest`, The chat request to process

#### func chat
```
chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- Description: Processes a chat request with specified maximum rounds
- Parameters:
  - `request`: `AgentRequest`, The chat request to process
  - `maxRound`: `Int64`, Maximum number of discussion rounds

#### func discuss
```
discuss(topic: String, initiator: String, speech: String, mode: FreeGroupMode = FreeGroupMode.Auto, maxRound: Int64 = DISCUSSION_MAX_ROUND): String
```
- Description: Initiates a discussion with specified parameters and mode
- Parameters:
  - `topic`: `String`, Topic of the discussion
  - `initiator`: `String`, Name of the initiator
  - `speech`: `String`, Initial speech content
  - `mode`: `FreeGroupMode`, Mode of discussion (Auto or RoundRobin)
  - `maxRound`: `Int64`, Maximum number of discussion rounds

#### func init
```
init(a: Agent, b: Agent)
```
- Description: Initializes a FreeGroup with two agents
- Parameters:
  - `a`: `Agent`, First agent to add to the group
  - `b`: `Agent`, Second agent to add to the group

#### func operator operator []
```
operator [](memberName: String): Agent
```
- Description: Accesses an agent member by name
- Parameters:
  - `memberName`: `String`, Name of the agent to access

#### func operator operator |
```
operator |(member: Agent): FreeGroup
```
- Description: Adds a new member to the group
- Parameters:
  - `member`: `Agent`, Agent to add to the group


### enum FreeGroupMode
####  Auto
```
Auto
```
- Description: The speaker will be selected by LLM automatically

####  RoundRobin
```
RoundRobin
```
- Description: 


### class LeaderGroup
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Processes a chat request asynchronously and returns an asynchronous agent response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be processed asynchronously.

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes a chat request and returns an agent response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be processed.

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- Description: Processes a chat request with a specified maximum number of rounds and returns an agent response.
- Parameters:
  - `request`: `AgentRequest`, The chat request to be processed.
  - `maxRound`: `Int64`, The maximum number of rounds for the chat.

#### func operator operator []
```
operator func [](memberName: String): Agent
```
- Description: Retrieves an agent member by name.
- Parameters:
  - `memberName`: `String`, The name of the agent member to retrieve.


### class LinearGroup
#### func asyncChat
```
func asyncChat(request: AgentRequest): AsyncAgentResponse
```
- Description: Processes a chat request asynchronously through all agents in the group sequentially.
- Parameters:
  - `request`: `AgentRequest`, The initial request to be processed by the agent group.

#### func chat
```
func chat(request: AgentRequest): AgentResponse
```
- Description: Processes a chat request through all agents in the group sequentially.
- Parameters:
  - `request`: `AgentRequest`, The initial request to be processed by the agent group.

#### func chat
```
func chat(request: AgentRequest, maxRound: Int64): AgentResponse
```
- Description: Processes a chat request through all agents in the group sequentially with a specified maximum number of rounds.
- Parameters:
  - `request`: `AgentRequest`, The initial request to be processed by the agent group.
  - `maxRound`: `Int64`, The maximum number of rounds for processing the request.

#### func operator operator []
```
operator func [](memberName: String): Agent
```
- Description: Throws an UnsupportedException when trying to access an agent by name.
- Parameters:
  - `memberName`: `String`, The name of the agent to access.


