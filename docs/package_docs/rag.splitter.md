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
  - [interface Splitter](#interface-splitter)
    - [func split](#func-split-1)

### class CharacterTextSplitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将输入的文本按照指定的大小分割成多个文档
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
- 描述: 加载文档内容并使用分割器进行分割，返回分割后的文档数组
- 参数:
  - `splitter`: `Splitter`, 用于分割文档的分割器


### class MarkdownSplitter
#### func init
```
public init(headersToSplit!: Array<(String, String)> = DEFAULT_HEADERS_TO_SPLIT, returnEachLine!: Bool = false, stripHeader!: Bool = true)
```
- 描述: 初始化MarkdownSplitter类
- 参数:
  - `headersToSplit`: `Array<(String, String)>`, 需要跟踪的标题列表
  - `returnEachLine`: `Bool`, 是否返回每行及其关联的标题
  - `stripHeader`: `Bool`, 是否从块内容中去除分割标题

#### func split
```
override public func split(text: String): Array<Document>
```
- 描述: 分割Markdown文件
- 参数:
  - `text`: `String`, Markdown文件内容


### interface Splitter
#### func split
```
func split(text: String): Array<Document>
```
- 描述: 将文本分割成文档数组
- 参数:
  - `text`: `String`, 需要分割的文本


