## Package rag.splitter
- [Package rag.splitter](#package-rag.splitter)
  - [class CharacterTextSplitter](#class-charactertextsplitter)
    - [func split](#func-split)
  - [class DocumentLoader](#class-documentloader)
    - [func load](#func-load)
    - [func loadSplit](#func-loadsplit)
  - [class MarkdownSplitter](#class-markdownsplitter)
    - [func init](#func-init)
    - [func split](#func-split-1)
  - [class RecursiveCharacterTextSplitter](#class-recursivecharactertextsplitter)
    - [func init](#func-init-1)
    - [func split](#func-split-1)
  - [interface Splitter](#interface-splitter)
    - [func split](#func-split-1)

### class CharacterTextSplitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将文本分割成多个文档
- 参数:
  - `text`: `String`, 需要分割的文本


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
public init(headersToSplit!: Array<(String, String)> = DEFAULT_HEADERS_TO_SPLIT, returnEachLine!: Bool = false, stripHeader!: Bool = true)
```
- 描述: 初始化 MarkdownSplitter 类
- 参数:
  - `headersToSplit`: `Array<(String, String)>`, 需要跟踪的标题
  - `returnEachLine`: `Bool`, 是否返回每行及其关联的标题
  - `stripHeader`: `Bool`, 是否从块内容中去除分割标题

#### func split
```
override public func split(text: String): Array<Document>
```
- 描述: 分割 Markdown 文件
- 参数:
  - `text`: `String`, Markdown 文件内容


### class RecursiveCharacterTextSplitter
#### func init
```
init(separators!: Array<String> = ["\n\n", "\n", " ", ""], chunkSize!: Int64 = 1024, chunkOverlap!: Int64 = 256, keepSeparator!: Bool = false)
```
- 描述: 初始化递归字符文本分割器
- 参数:
  - `separators`: `Array<String>`, 分隔符数组，默认为["\n\n", "\n", " ", ""]
  - `chunkSize`: `Int64`, 块大小，默认为1024
  - `chunkOverlap`: `Int64`, 块重叠大小，默认为256
  - `keepSeparator`: `Bool`, 是否保留分隔符，默认为false

#### func split
```
split(text: String): Array<Document>
```
- 描述: 分割文本为文档数组
- 参数:
  - `text`: `String`, 待分割的文本


### interface Splitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将文本分割成文档数组
- 参数:
  - `text`: `String`, 需要分割的文本


