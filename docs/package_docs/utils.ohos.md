## Package utils.ohos
- [Package utils.ohos](#package-utils.ohos)
  - [interface CJ2JS](#interface-cj2js)
    - [func toJS](#func-tojs)
  - [interface JS2CJ<T>](#interface-js2cj<t>)
    - [func fromJS](#func-fromjs)

### interface CJ2JS
#### func toJS
```
func toJS(context: JSContext): JSValue
```
- 描述: 将当前对象转换为JavaScript对象
- 参数:
  - `context`: `JSContext`, JavaScript上下文环境


### interface JS2CJ<T>
#### func fromJS
```
static func fromJS(jsValue: JSValue): T
```
- 描述: 将JSValue转换为泛型类型T
- 参数:
  - `jsValue`: `JSValue`, 需要转换的JSValue对象


