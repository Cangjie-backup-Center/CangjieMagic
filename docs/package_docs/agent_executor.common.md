## Package agent_executor.common
- [Package agent_executor.common](#package-agent_executor.common)
  - [class ConsolePrinter](#class-consoleprinter)
    - [func dump](#func-dump)
    - [func init](#func-init)
    - [func init](#func-init-1)
    - [func print](#func-print)

### class ConsolePrinter
#### func dump
```
dump(): Unit
```
- Description: Starts the dumping process of verbose information.

#### func init
```
init(chunks: Iterator<String>)
```
- Description: Constructor that initializes the ConsolePrinter with an iterator of strings.
- Parameters:
  - `chunks`: `Iterator<String>`, An iterator providing chunks of strings to be printed.

#### func init
```
init(asyncResponse: AsyncAgentResponse)
```
- Description: Constructor that initializes the ConsolePrinter with an asynchronous agent response.
- Parameters:
  - `asyncResponse`: `AsyncAgentResponse`, An asynchronous response containing verbose information for debugging.

#### func print
```
print(asyncResponse: AsyncAgentResponse, verbose: Bool = false): Unit
```
- Description: Prints the asynchronous response data, optionally including verbose debugging information.
- Parameters:
  - `asyncResponse`: `AsyncAgentResponse`, The asynchronous response to be printed.
  - `verbose`: `Bool`, If true, includes verbose debugging information in the output.


