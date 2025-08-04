# User Tutorial


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [User Tutorial](#user-tutorial)
  - [Agent Definition](#agent-definition)
  - [Writing System Prompts](#writing-system-prompts)
    - [Using Prompt Patterns](#using-prompt-patterns)
    - [Custom Prompt Patterns](#custom-prompt-patterns)
  - [Agent Interaction Methods](#agent-interaction-methods)
    - [Input Templates](#input-templates)
  - [MCP Protocol and Tools](#mcp-protocol-and-tools)
    - [Writing Tool Functions](#writing-tool-functions)
    - [Using Tools and MCP Servers](#using-tools-and-mcp-servers)
    - [Additional Tool Property Settings](#additional-tool-property-settings)
  - [Planning](#planning)
    - [Agent Execution DSL (Experimental)](#agent-execution-dsl-experimental)
  - [External Knowledge](#external-knowledge)
  - [Examples](#examples)
    - [Example 1: CLI Assistant Agent](#example-1-cli-assistant-agent)
  - [Multi-Agent Collaboration](#multi-agent-collaboration)
    - [Linear Coordination](#linear-coordination)
    - [Master-Slave Coordination](#master-slave-coordination)
    - [Free Coordination](#free-coordination)
    - [Agent Subgroup Construction](#agent-subgroup-construction)
  - [AI Function Shortcut](#ai-function-shortcut)
  - [Model Configuration](#model-configuration)
  - [Core API Reference](#core-api-reference)
    - [Semantic Retrieval](#semantic-retrieval)
      - [Vector Models](#vector-models)
      - [Vector Databases](#vector-databases)
      - [Index Maps](#index-maps)
      - [Semantic Structures](#semantic-structures)
  - [Knowledge Graph](#knowledge-graph)
    - [MiniRAG](#minirag)
      - [Instantiation](#instantiation)
      - [Knowledge Graph Construction](#knowledge-graph-construction)
      - [Knowledge Graph Querying](#knowledge-graph-querying)

<!-- /code_chunk_output -->



The Cangjie Agent DSL is a domain-specific language designed for defining and cooperating Agents. It enables developers to enhance Agent capabilities through structured system prompts, tools, and collaborative strategies. This manual introduces how to use the various features of the Cangjie Agent DSL with examples to help users get started quickly.

The Cangjie Agent DSL is implemented as an embedded DSL (eDSL) within the Cangjie language, leveraging metaprogramming mechanisms. This means that code written in the Agent DSL is ultimately transformed into standard Cangjie code and compiled by the Cangjie compiler.

## Agent Definition

Currently, we use the `@agent` macro to decorate a `class` type to define an Agent.

```cangjie
@agent class Foo { }
```

The `@agent` macro supports the following attributes. Refer to the corresponding sections for details.

| Attribute | Value Type | Description |
|-----------|------------|-------------|
| `description` | `String` | A functional description of the Agent. If not set, the LLM will automatically summarize it from the system prompt. |
| `model` | `String` | Configures the LLM model provider to use. |
| `tools` | `Array` | Configures external tools available to the Agent. |
| `mcp` | `Array` | Configures the MCP servers to connect to. |
| `rag` | `Map` | Configures external knowledge sources. |
| `memory` | `Bool` | Whether to enable memory (saving Agent conversation history). Currently, memory is non-persistent (in-memory only). Defaults to `false`. |
| `executor` | `String` | The planning mode. Defaults to `react`. |
| `temperature` | `Float` | The temperature value used by the Agent's LLM. Defaults to `0.5`. |
| `enableToolFilter` | `Bool` | Enables tool filtering, allowing the Agent to automatically select suitable tools based on the input question. Defaults to `false`. |
| `dump` | `Bool` | Debugging flag to print the transformed AST of the Agent. Defaults to `false`. |

## Writing System Prompts

The core of every Agent is its system prompt, which defines its role and execution steps, enabling the LLM to answer questions more accurately and efficiently. The `@prompt` macro is used to define the system prompt for an Agent.

- Within the `@prompt` macro's scope, all string literals (including interpolated strings) are concatenated into a complete system prompt.
- Functions and member variables in Cangjie can be accessed within `@prompt`.
- Each Agent can have at most one `@prompt` definition.

**Example: String Concatenation**
In the following code, three strings are concatenated as the Agent's system prompt. The third interpolated string calls the function `bar()`.

```cangjie
@agent
class Foo {
    @prompt(
        "# This is a Foo agent"
        "## Description"
        "balabala ${bar()}"
    )
}
```

**Example: Accessing Member Variables**

```cangjie
@agent
class Calculator {
    @prompt(
        """
        You are a calculator capable of performing calculations.
        Your name is ${name}-${version}.
        """
        "For example, you can perform addition: 1 + 2 = 3 ..."
    )
    private let name: String
    private let version: Int64
    ...
}

let calculator = Calculator(name: "aha", version: 1)
```

The `@prompt` macro supports the `include` attribute, which takes a file path string. The file's content will be used as the Agent's system prompt.
- When `include` is set, string literals inside `@prompt` are ignored.
- If the file does not exist, an exception is thrown.

**Example: Using an External File for the System Prompt**

```cangjie
@agent
class Foo {
    @prompt[include: "./a.md"]()
}
```

### Using Prompt Patterns

Well-structured prompts significantly improve LLM performance. Defining a unified prompt syntax helps developers write more structured prompts.

**Using Prompt Patterns**

The `@prompt` macro supports the `pattern` attribute, which takes a prompt pattern type. When using a pattern, the `@prompt` scope must contain *prompt elements* conforming to the pattern rather than string literals.

⚠️Note: The `include` and `pattern` attributes are mutually exclusive; setting both will raise an exception.

**Example: Using a Prompt Pattern**

```cangjie
@agent
class Foo {
    @prompt[pattern: APE] (
        action: "Help users plan travel routes",
        purpose: "Allow users to visit as many attractions as possible within their planned time while ensuring adequate rest",
        expectation: "Generate a reasonable travel itinerary, including time, attractions, and transportation"
    )
}
```

The following prompt patterns are currently available:

<table>
    <tr>
        <th>Prompt Pattern</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><code>APE</code></td>
        <td>
            <code>action</code>: Defines the task or activity.<br>
            <code>purpose</code>: Defines the reason for the action.<br>
            <code>expectation</code>: Describes the expected outcome.
        </td>
    </tr>
    <tr>
        <td><code>BROKE</code></td>
        <td>
            <code>background</code>: Provides context.<br>
            <code>role</code>: Specifies the Agent's role.<br>
            <code>objectives</code>: Defines the task objectives.<br>
            <code>keyResult</code>: Defines measurable outcomes to evaluate success.<br>
            <code>evolve</code>: Optimizes through experimentation.
        </td>
    </tr>
    <tr>
        <td><code>COAST</code></td>
        <td>
            <code>context</code>: Sets conversation context.<br>
            <code>objective</code>: Describes the goal.<br>
            <code>action</code>: Explains required actions.<br>
            <code>scenario</code>: Describes the scenario.<br>
            <code>task</code>: Describes the task.
        </td>
    </tr>
    <tr>
        <td><code>TAG</code></td>
        <td>
            <code>task</code>: Defines a specific task.<br>
            <code>action</code>: Describes what to do.<br>
            <code>goal</code>: Explains the end goal.
        </td>
    </tr>
    <tr>
        <td><code>RISE</code></td>
        <td>
            <code>role</code>: Specifies the Agent's role.<br>
            <code>input</code>: Describes information/resources.<br>
            <code>steps</code>: Requires detailed steps.<br>
            <code>expectation</code>: Describes the expected result.
        </td>
    </tr>
    <tr>
        <td><code>TRACE</code></td>
        <td>
            <code>task</code>: Defines a specific task.<br>
            <code>request</code>: Describes the request.<br>
            <code>action</code>: Explains the action needed.<br>
            <code>context</code>: Provides context.<br>
            <code>example</code>: Gives an example.
        </td>
    </tr>
    <tr>
        <td><code>ERA</code></td>
        <td>
            <code>expectation</code>: Describes the expected result.<br>
            <code>role</code>: Specifies the Agent's role.<br>
            <code>action</code>: Specifies the action.
        </td>
    </tr>
    <tr>
        <td><code>CARE</code></td>
        <td>
            <code>context</code>: Sets conversation context.<br>
            <code>action</code>: Describes what to do.<br>
            <code>result</code>: Describes the expected result.<br>
            <code>example</code>: Provides an example.
        </td>
    </tr>
    <tr>
        <td><code>ROSES</code></td>
        <td>
            <code>role</code>: Specifies the Agent's role.<br>
            <code>objective</code>: States the goal.<br>
            <code>scenario</code>: Describes the scenario.<br>
            <code>expectation</code>: Defines the expected result.<br>
            <code>steps</code>: Lists steps to achieve the solution.
        </td>
    </tr>
    <tr>
        <td><code>ICIO</code></td>
        <td>
            <code>instruction</code>: Gives task instructions to the AI.<br>
            <code>context</code>: Provides background.<br>
            <code>input</code>: Specifies data to process.<br>
            <code>output</code>: Specifies the expected output format.
        </td>
    </tr>
    <tr>
        <td><code>CRISPE</code></td>
        <td>
            <code>capacityAndRole</code>: The Agent's role.<br>
            <code>insight</code>: Provides insights and context.<br>
            <code>statement</code>: Specifies the task.<br>
            <code>personality</code>: Defines response style.<br>
            <code>experiment</code>: Requests multiple response examples.
        </td>
    </tr>
    <tr>
        <td><code>RACE</code></td>
        <td>
            <code>role</code>: Specifies the Agent's role.<br>
            <code>action</code>: Details the action.<br>
            <code>context</code>: Provides context.<br>
            <code>expectation</code>: Describes the expected result.
        </td>
    </tr>
    <tr>
        <td><code>SAGE</code></td>
        <td>
            <code>situation</code>: Describes execution context.<br>
            <code>action</code>: Specifies operations or steps.<br>
            <code>goal</code>: Explains the desired outcome.<br>
            <code>expectation</code>: Defines output requirements.
        </td>
    </tr>
</table>

### Custom Prompt Patterns

The `@promptPattern` macro decorates a `class` to define a new prompt pattern. Inside the decorated class, the `@element` macro defines prompt elements.
- Each element must be of type `String`.
- The `description` attribute explains the element and does not affect the final prompt.

The prompt pattern type must implement the `toString` method, which constructs the prompt.

**Example: Custom Prompt Pattern**

```cangjie
@promptPattern
class APE {
    @element[description: "Defines the task"]
    let action: String

    @element[description: "Defines the task's purpose"]
    let purpose: String

    @element[description: "Clearly defines the expected result"]
    let expectation: String

    public func toString(): String {
        return "...${action}...${purpose}...${expectation}..."
    }
}
```

## Agent Interaction Methods

Agents defined with `@agent` have a default method `func chat(question: ToString): String` as the interaction entry.

```cangjie
@agent class Foo { ... }

let agent = Foo()
let result = agent.chat("What's the weather today?")
println(result)
```

Additionally, `chatGet` allows an Agent to return a typed value instead of just a string. If the Agent fails to produce valid data, it returns `None`:

```cangjie
func chatGet<T>(question: String): Option<T> where T <: Jsonable<T>
```

Here, the `Jsonable` interface ([see section](#jsonable-interface)) ensures type compatibility with JSON objects. Basic types like `Int`, `Int64`, and `String` already implement this interface.

The `@jsonable` macro customizes types to automatically implement the interface:
- `@jsonable` decorates a `class/struct/enum` type, automatically implementing `Jsonable` via code transformation.
- Inside the decorated type, `@field` adds descriptions for member variables. If unused, member variables will lack descriptions.

**Example: Returning Structured Data**

```cangjie
@jsonable
class MyDate {
    @field["Year of the foundation"]
    let year: Int64
    let month: Int64
}

@agent
class Foo { }

let agent = Foo()
let date = agent.chatGet<MyDate>("When was Huawei founded?")
println(date.year)
println(date.month)
```

### Input Templates

When defining an Agent with `@agent`, you can specify an *input template*—a question templated with *placeholder variables*. The interaction interface only requires values for these placeholders.

The `@user` macro defines input templates:
- Like `@prompt`, it concatenates all string literals inside as the full input template.
- Placeholder variables are written as `{variable}` in the template, where the variable name consists of letters, digits, and underscores.
- Like `@prompt`, `@user` supports the `include` attribute (a file path). If set, the file's content becomes the input template.

When calling `func chat(variables: Array<(String, ToString)>): String`, placeholder variables and their values must be provided.
- If an Agent lacks an input template, calling this method throws an `UnsupportedException`.

**Example: Using an Input Template**

```cangjie
@agent
class Foo {
    @prompt(
        "System: ..."
    )
    @user(
        "The rectangle has a length of {length} cm and a width of {width} cm."
        "Calculate the rectangle's area."
    )
}
let agent = Foo()
let area = agent.chat(
    ("length", 3),
    ("width", 4),
)
```

## MCP Protocol and Tools

Tools are functions an Agent can execute during processing. Agent tools come from two sources:
- Tool functions written directly in DSL.
- Tools provided by MCP servers (MCP servers act as *collections of tools*).

### Writing Tool Functions

The macro `@tool` is used for functions to convert them into **tool functions**. Functions that can be decorated include:

- Global functions
- Member methods of Agent classes defined by `@agent`
- Member methods of `Toolset` types defined by `@toolset`

- `description`: Describes the tool's functionality (**required**).
- `parameters`: Describes function parameter meanings as `<parameter-name>: <parameter-description>` key-value pairs (**optional**).
- `filterable`: Whether the tool can be filtered by the Agent (used with `@agent`'s `enableToolFilter`) (**optional**).
- `terminal`: Whether to terminate Agent execution. When set to true, the Agent will immediately end after executing this tool, and the function's return value will be used as the Agent's execution result **optional**

Global tool functions or toolset must be explicitly specified in the `tools` attribute for the Agent to use them.

**Example: Defining and Configuring a Global Tool**

```cangjie
@tool[description: "...",
      parameters: { arg: "..." }]
func foo(arg: String): String { ... }

@agent[
    tools: [foo]
]
class A {...}
```

**Example: Defining and Configuring a toolset**

```cangjie
@toolset
class FooToolset {
    @tool[description: "..."]
    func foo(arg: String): String { ... }

    @tool[description: "..."]
    func bar(): String { ... }
}

@agent[
    tools: [FooToolset()]
]
class A {...}
```

**Example: Defining an Internal Tool**

```cangjie
@agent
class A {
    @tool[description: "...",
          parameters: { str: "..." }]
    func bar(str: String): String { ... }
}
```

Limitations on tool functions:
- Tool functions cannot be called directly like regular functions.

    ```cangjie
    @tool[...]
    func foo() { ... }

    foo() // Error: Cannot call tool functions directly
    ```
- Tool parameters must be basic types.
- Tool return values must satisfy the `ToString` interface (the method's return value is used as the tool's output).

### Using Tools and MCP Servers

The `tools` attribute configures the MCP servers and custom tool functions used by the Agent. This attribute accepts multiple MCP servers or tool functions, each configured with the following syntax:

- **MCP server using the `stdio` protocol:** `stdioMCP(<command>, <env-kv-pair>*)` specifies the command to start the MCP server along with optional environment variables.
  Example: `stdioMCP("command and arguments", ENV_1: "value1", ENV_2: "value2")`.

- **MCP server using the `http/sse` protocol:** `mcpHttp(<url>)` specifies the URL of the MCP server.
  Example: `httpMCP("https://abc.com/mcp")`.

- **Tool functions:** `<func-id>+`, such as `foo, bar`.
  ⚠️ Note: If a tool is defined within the `Agent` class, it can be used directly by that Agent without explicit declaration in the `tools` attribute.

- **Toolset construction** `<expr>` – Typically an instantiation of a toolset type, e.g., `MyToolset()`.


```cangjie
@agent[
    tools: [
        stdioMCP("node index.js args"),
        stdioMCP("python main.py args", SOME_API_KEY: "xxx"),
        httpMCP("http://abc.mcp.server.com"),
        toolA,
        toolB,
        MyToolset()
    ]
]
class Foo { ... }
```

Alternatively, MCP tools can be configured via API:

```cangjie
// Initialize MCP client
let client = MCPClient("node", ["args"])
let agent = SomeAgent()
// Add MCP tools
agent.toolManager.addTools(client.getTools())
```

⚠️ Note: Currently, MCP servers only support tool-related MCP protocols.

Additionally, **MCP servers can be configured in JSON syntax** within the `tools` attribute:

- **`stdio` transport:** Configured with `command` (startup command), `args` (startup arguments), and optionally `env` (environment variables).
- **`HTTP/SSE` transport:** Configured with `url` (MCP server address).

```cangjie
@agent[
    tools: [
        { command: "node", args: ["index.js", "args"] },
        { command: "python", args: ["main.py", "args"], env: { SOME_API_KEY: "xxx" } },
        { url: "http://abc.mcp.server.com" }
    ]
]
class Foo { ... }
```

### Additional Tool Property Settings

All tools support storing extra property values through the special member variable `extra: HashMap<String, String>`. Currently, there are two special property values:

- `filterable: "true" | "false"` – Determines whether the tool can be filtered by the Agent, used in conjunction with the `agent.toolManager.enableFilter` setting.
- `terminal: "true" | "false"` – Determines whether it terminates Agent execution. When set to `true`, the Agent will immediately end after executing this tool, and the function's return value will be used as the Agent's execution result.

**Example: Setting Tool Extra Properties**

```cangjie
let tool: Tool = getSomeTool()
tool.extra["filterable"] = "false"
tool.extra["terminal"] = "true"
```

## Planning

Each Agent has an `executor` property specifying which executor to use (different executors employ different planning strategies). Currently supported executors:

| Executor Name | Description |
|---|---|
| `naive`  | Direct Q&A  |
| `react` | The Agent selects one tool per solving step, evaluates the execution result to determine completion, and iterates until the task is solved |
| `plan-react` | Performs initial task planning, then uses React mode to solve each subtask |
| `tool-loop` | Functionally similar to react, but without an explicit reasoning process |

The `react` and `tool-loop` executor can specify maximum iterations using `react:<number>` format, e.g., `react:5`.

**Example: Configuring Planning Method**

```cangjie
@agent[executor: "naive"]
class Foo{ }

@agent[executor: "react"]
class Bar{ }
```

### Agent Execution DSL (Experimental)

In addition to directly using the pre-defined planning methods provided by Magic, you can use the **Execution DSL** (Domain-Specific Language) to control the execution process of an Agent at a finer granularity.

**Definition of Agent Execution DSL**: A "programming language" designed to define the execution flow of an LLM Agent, enabling complex strategies by combining operations.

- **Avoid Repetitive Code**: Eliminates the need for manually writing redundant template code.
- **Flexible Customization**: Allows easy implementation of sophisticated planning strategies.

**Basic Rules**

- The Planning DSL is used inside `@execution` within an `@agent` block. Once the DSL is applied, the `executor` property configuration is ignored.
- The pipe operator `|>` chains multiple planning operations.
- The Agent’s execution state is represented as a *sequence of Prompts*:
  - After each operation performed by the LLM, the result is appended to this Prompt sequence.

**Example Usage**

```swift
@agent class Foo {
  @execution(
    plan |> loop(think |> action) |> answer
  )
}
```

**Execution Flow Diagram**

```
             plan         -> think         -> action ->       think -> ... -> answer
| SysPrompt | -> | SysPrompt | -> | SysPrompt |        | SysPrompt |
                 | Plan: ... |    | Plan: ... |        | Plan: ... |
                                  | Think: ... |       | Think: ... |
                                                       | Action: ... |
                                                       | Result: ... |
```

Planning operations are derived from existing planning methods, abstracting common logic into composable actions. They are categorized into three types: *Basic Operations*, *Task Decomposition Operations*, and *Conditional Control Operations*.

**Basic Operations Overview**

| Operator   | Purpose          |
|------------|----------------|
| `think`    | Generate reasoning steps |
| `action`   | Select and execute a tool |
| `answer`   | Return the final answer |
| `plan`     | Formulate a plan |
| `loop`     | Loop through a sequence of internal operations |
| `tool`     | Execute a sequence of tool functions in order; tool parameters are auto-generated by the LLM |
| `done`     | Check whether execution should terminate |

**Advanced Operations: Task Decomposition & Merging**

```swift
@agent class ResearchAssistant {
  @execution(
    divide |> each(tool(web_search)) |> summary |> answer
  )
  @tool
  func web_search(...) { ... }
}
```

| Operator   | Purpose          |
|------------|----------------|
| `divide`   | Task is split into sub-problems by the LLM; the number of sub-tasks is auto-determined |
| `each`     | Process sub-tasks |
| `summary`  | Aggregate results from sub-tasks |

**Advanced Operations: Conditional Control**

```swift
@agent class Assistant {
  @execution(
    switch(
      onCase("Is the question about weather?", tool(weather_api)),
      onCase("Is the question about order inquiry?", tool(db_query |> db_summary)),
      otherwise(think |> answer)
    )
  )
}
```

- `switch` accepts multiple `onCase` clauses.
- Each `onCase` consists of a condition (expressed in natural language) and an operation sequence:
  - If the condition holds true (based on the current execution state), the corresponding operation sequence is executed.
  - `onCase` clauses are evaluated top-down.
- If no `onCase` condition is met, the `otherwise` clause is executed.

## External Knowledge

Beyond system prompts, external knowledge can enhance an Agent's problem-solving capabilities. Agents can extract essential information from various knowledge sources.

The `rag` property specifies the data source for external knowledge, accepting multiple configurations with these key-value pairs:

| Property  | Value | Description |
|---|---|---|
| `source`  | `String \| Expr`  | Data source |
| `mode`  | `String`  | Usage mode: `"static"` or `"dynamic"` (default: `"static"`) |
| `description`  | `String`  | Additional source description to help Agents retrieve data more precisely |

The `source` property supports:
- Valid paths to *predefined file types*
    - Currently supported: markdown, SQLite databases
- Expressions of type `Retriever`

```cangjie
@agent[
  rag: { source: "path/to/some.db" }
]
class Foo { }
```

⚠️Note: SQLite functionality requires `sqlite = "enable"` in `cfg.toml` and third-party dependencies. See [third_party_libs.md](./third_party_libs.md)

## Examples

### Example 1: CLI Assistant Agent

```cangjie
@agent[executor: "react"]
class CJCAgent {
    @prompt(
        """
        You are a CJC command line assistant.
        You help users generate commands based on their queries.
        """
    )

    @tool[description: "Get CJC manual"]
    private func getManual(): String {
        let subProcess: SubProcess = Process.start(
            "cjc", ["--help"], stdOut: ProcessRedirect.Pipe
        )
        let strReader: StringReader<InputStream> = StringReader(subProcess.stdOut)
        let result = strReader.readToEnd().trimAscii()
        return result
    }
}

let agent = CJCAgent()
let result = agent.chat("Compile a file for ARM platform")
```

## Multi-Agent Collaboration

Agents can be organized into groups for efficient collaboration through three modes:

1. **Linear Coordination**: Sequential operation where each Agent receives the previous Agent's message (including results/tasks), processes it, and passes results to the next Agent.
2. **Master-Slave Coordination**: One Agent leads while others report to it.
3. **Free Coordination**: Equal collaboration where all Agents participate in group discussions with full message visibility.

The `AgentGroup` interface abstracts these coordination modes (see API Reference).

### Linear Coordination

The pipeline operator `|>` creates `LinearGroup`.

```cangjie
let linearGroup: LinearGroup = ag1 |> ag2 |> ag3
```

### Master-Slave Coordination

The `<=` operator creates `LeaderGroup`, with the left operand as leader and right as follower array.

```cangjie
let leaderGroup: LeaderGroup = ag1 <= [ag2, ag3]
```

### Free Coordination

The `|` operator creates `FreeGroup`.

```cangjie
let freeGroup: FreeGroup = ag1 | ag2 | ag3
```

`FreeGroup` also provides a flexible `discuss` method:

```cangjie
public enum FreeGroupMode {
    | Auto // The speaker will be selected by LLM automatically
    | RoundRobin
}
class FreeGroup {
    public func discuss(topic!: String, initiator!: String, speech!: String,
                        mode!: FreeGroupMode = FreeGroupMode.Auto): String
    ...
}
```

The `discuss` method specifies:
- `topic`: Discussion subject (the problem to solve)
- `initiator`: First speaker
- `speech`: Initial content
- `mode`: Discussion mode (auto-selected or round-robin)

Example implementation of number-guessing game between two Agents (reference [AutoGen](https://github.com/microsoft/autogen/blob/main/website/docs/tutorial/human-in-the-loop.ipynb)):

```cangjie
@agent class AgentWithNumber {
    @prompt(
        "You are playing a game of guess-my-number. You have the "
        "number 33 in your mind, and I will try to guess it. "
        "If I guess too high, say 'too high', if I guess too low, say 'too low'."
    )
}

@agent class AgentGuessNumber {
    @prompt(
        "I have a number in my mind, and you will try to guess it. "
        "If I say 'too high', you should guess a lower number. If I say 'too low', "
        "you should guess a higher number. "
    )
}

func game() {
    let group = AgentWithNumber() | AgentGuessNumber()
    group.discuss(topic: "Number guessing game",
                  initiator: "AgentWithNumber",
                  speech: "I have a number between 1 and 70. Guess it!",
                  mode: FreeGroupMode.RoundRobin)
}
```

### Agent Subgroup Construction

When building linear coordination, both Agents and AgentGroups can participate directly. For example:

```cangjie
ag1 |> (ag2 <= [ag3]) |> ag4
```

This creates a linear group where the second unit is a master-slave subgroup.

However, master-slave and free coordination don't directly accept `AgentGroup`. Use `subGroup()` to convert:

```cangjie
ag1 | subGroup(ag2 <= [ag3], description: "An subgroup attempts to ...") | ag4 // Okay
```

## AI Function Shortcut

`@ai` can be used to annotate functions, indicating that the function's execution will be performed by an LLM.

Functions decorated with `@ai` must be declared as `foreign`, meaning their implementation resides on the model side, making them foreign functions from the perspective of the current code.
**Requirements**: **The parameter types and return type of the function must satisfy the `Jsonable` interface.**

Additionally, the `@ai` decorator supports the following attributes:

| Attribute    | Type      | Description |
|--------------|-----------|-------------|
| `prompt`     | `String`  | Additional instructions for the AI function. |
| `model`      | `String`  | Specifies the LLM model provider to use. |
| `tools`      | `Array`   | Configures the external tools available for use. |
| `temperature`| `Float`   | The `temperature` value used by the agent when invoking the LLM. |
| `dump`       | `Bool`    | Used for debugging—if `true`, prints the agent's transformed AST; defaults to `false`. |

**Example**:

```cangjie
@tool[description: "Fetches the html content of a URL."]
func fetch(url: String): String { ... }

@ai[
    prompt: "No more than 3 keywords",
    tools: [fetch]
]
foreign func keywordsOf(url: String): Array<String>

main() { keywordsOf("https://cangjie-lang.cn/") }
```


## Model Configuration

Models are configured as `<provider>:<model>`. Current providers:

| Provider | Example | Config | URL Config |
|---|---|---|---|
| Aliyun | `dashscope:qwen-plus` | `DASHSCOPE_API_KEY` | `DASHSCOPE_BASE_URL` (default: `https://dashscope.aliyuncs.com/compatible-mode/v1`) |
| DeepSeek | `deepseek:deepseek-chat` | `DEEPSEEK_API_KEY` | `DEEPSEEK_BASE_URL` (default: `https://api.deepseek.com`) |
| Volcano Ark | `ark:doubao-lite-4k` | `ARK_API_KEY` | `ARK_BASE_URL` (default: `https://ark.cn-beijing.volces.com/api/v3`) |
| Llama.cpp | `llamacpp` | No API key needed | `LLAMACPP_BASE_URl` (default: `http://localhost:8080`) |
| Ollama | `ollama:phi-3` | No API key | `OLLAMA_BASE_URl` (default: `http://localhost:11434`) |
| OpenAI  | `openai:gpt-4o` | `OPENAI_API_KEY` | `OPENAI_BASE_URL` (default: `https://api.openai.com/v1`) |
| SiliconFlow | `siliconflow:deepseek-ai/DeepSeek-V3` | `SILICONFLOW_API_KEY` | `SILICONFLOW_BASE_URL` (default: `https://api.siliconflow.cn/v1`) |
| Zhipu AI | `zhipuai:glm-4` | `ZHIPUAI_API_KEY` | `ZHIPUAI_BASE_URL` (default: `https://open.bigmodel.cn/api/paas/v4`) |
| Google | `google:gemini-2.0-flash` | `GOOGLE_API_KEY` | `GOOGLE_BASE_URL`，(default: `https://generativelanguage.googleapis.com/v1beta/openai`) |
| Moonshot | `moonshot:kimi-k2-0711-preview` | `MOONSHOT_API_KEY` | `MOONSHOT_BASE_URL` (default: `https://api.moonshot.cn/v1`) |
| OpenRouter | `openrouter:qwen/qwen3-coder:free` | `OPENROUTER_API_KEY` | `OPENROUTER_BASE_URL` (default: `https://openrouter.ai/api/v1`) |

**Model Support Matrix**

|   | Chat | Embedding | Image |
|---|---|---|---|
| Aliyun | ✔️ | ✔️ | ❌ |
| DeepSeek | ✔️ | ❌️ | ❌ |
| Volcano Ark | ✔️ | ✔️ | ❌ |
| Llama.cpp | ✔️ | ✔️ | ❌ |
| Ollama | ✔️ | ✔️ | ❌ |
| OpenAI | ✔️ | ✔️ | ✔️ |
| SiliconFlow | ✔️ | ✔️ | ✔️ |
| Zhipu AI | ✔️ | ❌ | ❌ |
| Google | ✔️ | ❌ | ❌ |
| Moonshot | ✔️ | ❌ | ❌ |
| OpenRouter | ✔️ | ❌ | ❌ |

## Core API Reference

(Continuing with similarly detailed translations of API sections...)

### Semantic Retrieval

The semantic retrieval system comprises:
- **Vector Models**: Generate semantic vectors (`Vector`) from text
- **Vector Databases**: Maintain `vector -> index` mapping and search
- **Index Maps**: Maintain `index -> data` relationships
- **Semantic Structures**: Higher-level abstractions combining these components

#### Vector Models

```cangjie
class Vector {
    public init(data: Array<Float32>)
}

public class VectorBuilder {
    public VectorBuilder(model!: EmbeddingModel)
    public func createEmbeddingVector(content: String): Vector
}
```

#### Vector Databases

```cangjie
public interface VectorDatabase<Self> {
    func addVector(vector: Vector): Unit
    func search(queryVec: Vector, number!: Int64): Array<Int64>
    func save(filePath: String): Unit
    static func load(filePath: String): Self
}
```

#### Index Maps

```cangjie
public interface IndexMap<Self, T> where T <: ToString {
    func add(content: T): Unit
    func get(index: Int64): T
    func save(filePath: String): Unit
    static func load(filePath: String): Self
}
```

#### Semantic Structures

```cangjie
public class SemanticMap<VDB, IMAP, T> where VDB <: VectorDatabase<VDB>,
                                           IMAP <: IndexMap<IMAP, T>,
                                           T <: ToString {
    // Constructor and methods...
}

public class SemanticSet<VDB, IMAP, T> where VDB <: VectorDatabase<VDB>,
                                            IMAP <: IndexMap<IMAP, T>,
                                            T <: ToString {
    // Constructor and methods...
}
```

## Knowledge Graph
### MiniRAG
MiniRAG enables knowledge graph creation using vectors, key-value stores, and graph storage (local storage supported).
https://github.com/HKUDS/MiniRAG

#### Instantiation
```cangjie
import magic.config.Config
import magic.rag.graph.{MiniRagBuilder, MiniRagConfig, MiniRag}
import magic.model.ollama.OllamaEmbeddingModel
import magic.tokenizer.Cl100kTokenizer

func instantiateMiniRag(): MiniRag {
    Config.env["DEEPSEEK_API_KEY"] = "<your api key>"
    let model = ModelManager.createChatModel("<Chat Model Name>")
    let embed = OllamaEmbeddingModel("<Embedding Model Name>", baseURL: "<Embedding Model URL>")
    let tokenizer = Cl100kTokenizer("<Your TickToken File Location>")
    let config = MiniRagConfig(model, embed, tokenizer)
    MiniRagBuilder(config).build()
}
```

#### Knowledge Graph Construction
```cangjie
func buildGraph(): Unit {
    let miniRag:MiniRag = instantiateMiniRag()
    let content:String = "<Text Read From File>"
    miniRag.insert(content)
    miniRag.commit()
}
```

#### Knowledge Graph Querying
```cangjie
func search(query:String): String {
    let miniRag = instantiateMiniRag()
    let retriever = miniRag.asRetriever()
    let response = retriever.search(query)
    response.toPrompt()
}
```

[Example Usage](../src/examples/mini_rag/main.cj)
