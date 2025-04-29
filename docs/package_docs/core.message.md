## Package core.message
- [Package core.message](#package-core.message)
  - [class ChatMessage](#class-chatmessage)
    - [func assistant](#func-assistant)
    - [let content](#let-content)
    - [let image](#let-image)
    - [func init](#func-init)
    - [let name](#let-name)
    - [let reason](#let-reason)
    - [let role](#let-role)
    - [func system](#func-system)
    - [func toLogString](#func-tologstring)
    - [func toString](#func-tostring)
    - [func user](#func-user)
  - [enum ChatMessageRole](#enum-chatmessagerole)
    - [func !=](#func-!=)
    - [func ==](#func-==)
    - [enumeration Assistant](#enumeration-assistant)
    - [enumeration System](#enumeration-system)
    - [enumeration Unknown](#enumeration-unknown)
    - [enumeration User](#enumeration-user)
    - [func fromStr](#func-fromstr)
    - [func toString](#func-tostring-1)
  - [class Dialog](#class-dialog)
    - [func addMessage](#func-addmessage)
    - [func addMessage](#func-addmessage-1)
    - [func clear](#func-clear)
    - [func clone](#func-clone)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [func init](#func-init-1)
    - [func isEmpty](#func-isempty)
    - [func iterator](#func-iterator)
    - [func operator func[]](#func-operator-func[])
    - [func removeLast](#func-removelast)
    - [prop size](#prop-size)
    - [func toString](#func-tostring-1)

### class ChatMessage
#### func assistant
```
static func assistant(content: String, name: String = ""): ChatMessage
```
- 描述: 创建助手消息
- 参数:
  - `content`: `String`, 消息内容
  - `name`: `String`, 发送者名称

#### let content
```
let content: String
```
- 描述: 消息内容

#### let image
```
let image: Option<String>
```
- 描述: 图片URL或Base64编码

#### func init
```
init(role: ChatMessageRole, content: String, name: String = "", image: Option<String> = None, reason: Option<String> = None)
```
- 描述: 初始化聊天消息
- 参数:
  - `role`: `ChatMessageRole`, 发送者角色
  - `content`: `String`, 消息内容
  - `name`: `String`, 发送者名称
  - `image`: `Option<String>`, 图片URL或Base64编码
  - `reason`: `Option<String>`, 推理内容

#### let name
```
let name: String
```
- 描述: 发送者名称

#### let reason
```
let reason: Option<String>
```
- 描述: 推理内容

#### let role
```
let role: ChatMessageRole
```
- 描述: 发送者角色

#### func system
```
static func system(content: String): ChatMessage
```
- 描述: 创建系统消息
- 参数:
  - `content`: `String`, 消息内容

#### func toLogString
```
func toLogString(): String
```
- 描述: 将消息转换为日志字符串

#### func toString
```
func toString(): String
```
- 描述: 将消息转换为字符串

#### func user
```
static func user(content: String, image: Option<String> = None): ChatMessage
```
- 描述: 创建用户消息
- 参数:
  - `content`: `String`, 消息内容
  - `image`: `Option<String>`, 图片URL或Base64编码


### enum ChatMessageRole
#### func operator !=
```
operator func !=(other: ChatMessageRole): Bool
```
- 描述: 比较两个角色是否不相等
- 参数:
  - `other`: `ChatMessageRole`, 另一个角色

#### func operator ==
```
operator func ==(other: ChatMessageRole): Bool
```
- 描述: 比较两个角色是否相等
- 参数:
  - `other`: `ChatMessageRole`, 另一个角色

####  Assistant
```
Assistant
```
- 描述: 助手角色

####  System
```
System
```
- 描述: 系统角色

####  Unknown
```
Unknown
```
- 描述: 未知角色

####  User
```
User
```
- 描述: 用户角色

#### func fromStr
```
static func fromStr(str: String): ChatMessageRole
```
- 描述: 从字符串转换为角色
- 参数:
  - `str`: `String`, 表示角色的字符串

#### func toString
```
func toString(): String
```
- 描述: 将角色转换为字符串


### class Dialog
#### func addMessage
```
public func addMessage(msg: ChatMessage): Unit
```
- 描述: 添加一条聊天消息到对话集合中
- 参数:
  - `msg`: `ChatMessage`, 要添加的聊天消息

#### func addMessage
```
public func addMessage(messages: Array<ChatMessage>): Unit
```
- 描述: 添加多条聊天消息到对话集合中
- 参数:
  - `messages`: `Array<ChatMessage>`, 要添加的聊天消息数组

#### func clear
```
public func clear(): Unit
```
- 描述: 清空对话集合中的所有消息

#### func clone
```
public func clone(): Dialog
```
- 描述: 克隆当前的对话集合

#### func init
```
public init()
```
- 描述: 初始化一个空的对话集合

#### func init
```
public init(messages: ArrayList<ChatMessage>)
```
- 描述: 使用已有的ArrayList<ChatMessage>初始化对话集合
- 参数:
  - `messages`: `ArrayList<ChatMessage>`, 包含聊天消息的ArrayList

#### func init
```
public init(messages: Array<ChatMessage>)
```
- 描述: 使用已有的Array<ChatMessage>初始化对话集合
- 参数:
  - `messages`: `Array<ChatMessage>`, 包含聊天消息的Array

#### func isEmpty
```
public func isEmpty(): Bool
```
- 描述: 检查对话集合是否为空

#### func iterator
```
public func iterator(): Iterator<ChatMessage>
```
- 描述: 返回对话集合的迭代器

#### func operator operator func[]
```
public operator func[](index: Int64): ChatMessage
```
- 描述: 通过索引获取对话集合中的消息
- 参数:
  - `index`: `Int64`, 消息的索引位置

#### func removeLast
```
public func removeLast(): ChatMessage
```
- 描述: 移除并返回对话集合中的最后一条消息

#### prop size
```
public prop size: Int64
```
- 描述: 获取对话集合中消息的数量

#### func toString
```
public func toString(): String
```
- 描述: 将对话集合中的所有消息转换为字符串


