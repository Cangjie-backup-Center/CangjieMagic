## Package core.tokenizer
- [Package core.tokenizer](#package-core.tokenizer)
  - [interface Tokenizer](#interface-tokenizer)
    - [func decode](#func-decode)
    - [func encode](#func-encode)

### interface Tokenizer
#### func decode
```
func decode(tokens: Array<UInt32>): String
```
- 描述: 将无符号32位整数数组解码为字符串
- 参数:
  - `tokens`: `Array<UInt32>`, 需要解码的无符号32位整数数组

#### func encode
```
func encode(input: String): Array<UInt32>
```
- 描述: 将输入的字符串编码为无符号32位整数数组
- 参数:
  - `input`: `String`, 需要编码的字符串


