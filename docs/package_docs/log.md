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
- 描述: 输出调试级别的日志信息
- 参数:
  - `msg`: `String`, 需要输出的调试信息

#### func debug
```
public static func debug(name: String, msg: String): Unit
```
- 描述: 输出带有名称的调试级别日志信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `String`, 需要输出的调试信息

#### func error
```
public static func error(msg: String): Unit
```
- 描述: 输出错误级别的日志信息
- 参数:
  - `msg`: `String`, 需要输出的错误信息

#### func error
```
public static func error(name: String, msg: String): Unit
```
- 描述: 输出带有名称的错误级别日志信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `String`, 需要输出的错误信息

#### func info
```
public static func info(msg: String): Unit
```
- 描述: 输出信息级别的日志信息
- 参数:
  - `msg`: `String`, 需要输出的信息

#### func info
```
public static func info(name: String, msg: String): Unit
```
- 描述: 输出带有名称的信息级别日志信息
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `String`, 需要输出的信息

#### func info
```
public static func info(msg: ChatMessage): Unit
```
- 描述: 输出聊天消息的信息级别日志
- 参数:
  - `msg`: `ChatMessage`, 需要输出的聊天消息

#### func info
```
public static func info(name: String, msg: ChatMessage): Unit
```
- 描述: 输出带有名称的聊天消息信息级别日志
- 参数:
  - `name`: `String`, 日志名称
  - `msg`: `ChatMessage`, 需要输出的聊天消息

#### func info
```
public static func info(history: Dialog): Unit
```
- 描述: 输出对话历史的信息级别日志
- 参数:
  - `history`: `Dialog`, 需要输出的对话历史

#### func info
```
public static func info(name: String, history: Dialog): Unit
```
- 描述: 输出带有名称的对话历史信息级别日志
- 参数:
  - `name`: `String`, 日志名称
  - `history`: `Dialog`, 需要输出的对话历史

#### func info
```
public static func info(messages: Array<ChatMessage>): Unit
```
- 描述: 输出聊天消息数组的信息级别日志
- 参数:
  - `messages`: `Array<ChatMessage>`, 需要输出的聊天消息数组

#### func info
```
public static func info(name: String, messages: Array<ChatMessage>): Unit
```
- 描述: 输出带有名称的聊天消息数组信息级别日志
- 参数:
  - `name`: `String`, 日志名称
  - `messages`: `Array<ChatMessage>`, 需要输出的聊天消息数组


### struct LogUtils
#### func debug
```
static func debug(msg: String): Unit
```
- 描述: 打印调试信息
- 参数:
  - `msg`: `String`, 需要打印的调试信息

#### func debug
```
static func debug(name: String, msg: String): Unit
```
- 描述: 打印带有名称的调试信息
- 参数:
  - `name`: `String`, 调试信息的名称
  - `msg`: `String`, 需要打印的调试信息

#### func debug
```
static func debug(ex: Exception): Unit
```
- 描述: 打印异常堆栈信息
- 参数:
  - `ex`: `Exception`, 需要打印的异常

#### func error
```
static func error(msg: String): Unit
```
- 描述: 打印错误信息
- 参数:
  - `msg`: `String`, 需要打印的错误信息

#### func error
```
static func error(name: String, msg: String): Unit
```
- 描述: 打印带有名称的错误信息
- 参数:
  - `name`: `String`, 错误信息的名称
  - `msg`: `String`, 需要打印的错误信息

#### func info
```
static func info(msg: String): Unit
```
- 描述: 打印普通信息
- 参数:
  - `msg`: `String`, 需要打印的信息

#### func info
```
static func info(name: String, msg: String): Unit
```
- 描述: 打印带有名称的普通信息
- 参数:
  - `name`: `String`, 信息的名称
  - `msg`: `String`, 需要打印的信息

#### func info
```
static func info(msg: ChatMessage): Unit
```
- 描述: 打印聊天消息
- 参数:
  - `msg`: `ChatMessage`, 需要打印的聊天消息

#### func info
```
static func info(name: String, msg: ChatMessage): Unit
```
- 描述: 打印带有名称的聊天消息
- 参数:
  - `name`: `String`, 聊天消息的名称
  - `msg`: `ChatMessage`, 需要打印的聊天消息

#### func info
```
static func info(history: Dialog): Unit
```
- 描述: 打印对话历史
- 参数:
  - `history`: `Dialog`, 需要打印的对话历史

#### func info
```
static func info(name: String, history: Dialog): Unit
```
- 描述: 打印带有名称的对话历史
- 参数:
  - `name`: `String`, 对话历史的名称
  - `history`: `Dialog`, 需要打印的对话历史

#### func info
```
static func info(messages: Array<ChatMessage>): Unit
```
- 描述: 打印聊天消息数组
- 参数:
  - `messages`: `Array<ChatMessage>`, 需要打印的聊天消息数组

#### func info
```
static func info(name: String, messages: Array<ChatMessage>): Unit
```
- 描述: 打印带有名称的聊天消息数组
- 参数:
  - `name`: `String`, 聊天消息数组的名称
  - `messages`: `Array<ChatMessage>`, 需要打印的聊天消息数组


