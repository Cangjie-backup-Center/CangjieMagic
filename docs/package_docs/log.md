## Package log
- [Package log](#package-log)
  - [struct LogUtils](#struct-logutils)
    - [func debug](#func-debug)
    - [func debug](#func-debug-1)
    - [func error](#func-error)
    - [func error](#func-error-1)
    - [func info](#func-info)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
  - [struct LogUtils](#struct-logutils-1)
    - [func debug](#func-debug-1)
    - [func debug](#func-debug-1)
    - [func debug](#func-debug-1)
    - [func error](#func-error-1)
    - [func error](#func-error-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)
    - [func info](#func-info-1)

### struct LogUtils
#### func debug
```
public static func debug(msg: String): Unit
```
- Description: Logs a debug message.
- Parameters:
  - `msg`: `String`, The debug message to log.

#### func debug
```
public static func debug(name: String, msg: String): Unit
```
- Description: Logs a debug message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the debug message.
  - `msg`: `String`, The debug message to log.

#### func error
```
public static func error(msg: String): Unit
```
- Description: Logs an error message.
- Parameters:
  - `msg`: `String`, The error message to log.

#### func error
```
public static func error(name: String, msg: String): Unit
```
- Description: Logs an error message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the error message.
  - `msg`: `String`, The error message to log.

#### func info
```
public static func info(msg: String): Unit
```
- Description: Logs an info message.
- Parameters:
  - `msg`: `String`, The info message to log.

#### func info
```
public static func info(name: String, msg: String): Unit
```
- Description: Logs an info message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the info message.
  - `msg`: `String`, The info message to log.

#### func info
```
public static func info(msg: Message): Unit
```
- Description: Logs an info message for a chat message.
- Parameters:
  - `msg`: `Message`, The chat message to log.

#### func info
```
public static func info(name: String, msg: Message): Unit
```
- Description: Logs an info message for a chat message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the info message.
  - `msg`: `Message`, The chat message to log.

#### func info
```
public static func info(history: MessageList): Unit
```
- Description: Logs info messages for a list of chat messages.
- Parameters:
  - `history`: `MessageList`, The list of chat messages to log.

#### func info
```
public static func info(name: String, history: MessageList): Unit
```
- Description: Logs info messages for a list of chat messages with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the info messages.
  - `history`: `MessageList`, The list of chat messages to log.

#### func info
```
public static func info(messages: Array<Message>): Unit
```
- Description: Logs info messages for an array of chat messages.
- Parameters:
  - `messages`: `Array<Message>`, The array of chat messages to log.

#### func info
```
public static func info(name: String, messages: Array<Message>): Unit
```
- Description: Logs info messages for an array of chat messages with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the info messages.
  - `messages`: `Array<Message>`, The array of chat messages to log.


### struct LogUtils
#### func debug
```
public static func debug(msg: String): Unit
```
- Description: Logs a debug message.
- Parameters:
  - `msg`: `String`, The debug message to log.

#### func debug
```
public static func debug(name: String, msg: String): Unit
```
- Description: Logs a debug message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the debug message.
  - `msg`: `String`, The debug message to log.

#### func debug
```
public static func debug(ex: Exception): Unit
```
- Description: Logs the stack trace of an exception as debug messages.
- Parameters:
  - `ex`: `Exception`, The exception whose stack trace is to be logged.

#### func error
```
public static func error(msg: String): Unit
```
- Description: Logs an error message.
- Parameters:
  - `msg`: `String`, The error message to log.

#### func error
```
public static func error(name: String, msg: String): Unit
```
- Description: Logs an error message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the error message.
  - `msg`: `String`, The error message to log.

#### func info
```
public static func info(msg: String): Unit
```
- Description: Logs an informational message.
- Parameters:
  - `msg`: `String`, The informational message to log.

#### func info
```
public static func info(name: String, msg: String): Unit
```
- Description: Logs an informational message with a name prefix.
- Parameters:
  - `name`: `String`, The name prefix for the informational message.
  - `msg`: `String`, The informational message to log.

#### func info
```
public static func info(msg: Message): Unit
```
- Description: Logs a chat message as an informational message.
- Parameters:
  - `msg`: `Message`, The chat message to log.

#### func info
```
public static func info(name: String, msg: Message): Unit
```
- Description: Logs a chat message with a name prefix as an informational message.
- Parameters:
  - `name`: `String`, The name prefix for the chat message.
  - `msg`: `Message`, The chat message to log.

#### func info
```
public static func info(history: MessageList): Unit
```
- Description: Logs a list of chat messages as informational messages.
- Parameters:
  - `history`: `MessageList`, The list of chat messages to log.

#### func info
```
public static func info(name: String, history: MessageList): Unit
```
- Description: Logs a list of chat messages with a name prefix as informational messages.
- Parameters:
  - `name`: `String`, The name prefix for the chat messages.
  - `history`: `MessageList`, The list of chat messages to log.

#### func info
```
public static func info(messages: Array<Message>): Unit
```
- Description: Logs an array of chat messages as informational messages.
- Parameters:
  - `messages`: `Array<Message>`, The array of chat messages to log.

#### func info
```
public static func info(name: String, messages: Array<Message>): Unit
```
- Description: Logs an array of chat messages with a name prefix as informational messages.
- Parameters:
  - `name`: `String`, The name prefix for the chat messages.
  - `messages`: `Array<Message>`, The array of chat messages to log.


