package magic.ohos

import std.collection.*
import std.collection.concurrent.{BlockingQueue, ConcurrentHashMap}
import std.convert.*
import std.os.process.*
import std.sync.{ReentrantMutex, Timer}
import std.time.*
@When[ohos == "true"]
import ohos.ark_interop.*
@When[ohos == "true"]
import ohos.base.{Main, BusinessException, AppLog}
@When[ohos == "true"]
import ohos.base.AsyncCallback

foreign func gettid(): Int64


class SyncResp<T> {
    var value: ?T
    var error: String
    init(value: ?T, error: String) {
        this.value = value
        this.error = error
    }
}
@When[ohos == "true"]
private type AsyncCallback<T> = (?BusinessException, ?T) -> Unit
@When[ohos == "true"]
private var mainThreadContext = None<JSContext>
@When[ohos == "true"]
private let REG_CTX = JSModule.registerModule {
    ctx, _ => mainThreadContext = ctx
}
@When[ohos == "true"]
public class ArkAPI {
    private static const JS_INTERNAL_ERROR = -1i32
    private static let MAIN_CONTEXT_MODULE_MAP = ConcurrentHashMap<String, JSObject>()
    private static var mainThreadRuntime = None<JSRuntime>
    private static var lock = ReentrantMutex()
    private static var mainThreadId = Process.current.pid

    private static func checkThreadAndCall<T>(ctx: JSContext, f: (JSContext) -> T): T {
        if (ctx.isInBindThread()) {
            f(ctx)
        } else {
            let fut = spawn (Main) {
                f(ctx)
            }
            fut.get()
        }
    }

    private static func getMainContext(): JSContext {
        // hybrid mode
        if (let Some(v) <- mainThreadContext) {
            return v
        }
        // pure cj, create js runtime in main thread
        // user may call this func in spawn
        func initJS(): JSContext {
            synchronized(lock) {
                if (let Some(v) <- mainThreadContext) {
                    v
                } else {
                    let rt = JSRuntime()
                    mainThreadRuntime = rt
                    mainThreadContext = rt.mainContext
                    rt.mainContext
                }
            }
        }

        let curTid = unsafe { gettid() }
        if (curTid == mainThreadId) {
            initJS()
        } else {
            let f = spawn (Main) {
                initJS()
            }
            f.get()
        }
    }

    private static func handleAsyncError(ctx: JSContext, err: JSValue): BusinessException {
        if (err.isObject()) {
            let errObj = err.asObject()
            let code = if (errObj["code"].isNumber()) {
                Int32.fromJSValue(ctx, errObj.getProperty("code"))
            } else if (errObj["code"].isString()) {
                Int32.tryParse(String.fromJSValue(ctx, errObj["code"])) ?? JS_INTERNAL_ERROR
            } else {
                JS_INTERNAL_ERROR
            }
            let msg = if (errObj["message"].isString()) {
                String.fromJSValue(ctx, errObj["message"])
            } else {
                "unknown exception occured"
            }
            BusinessException(code, msg)
        } else if (err.isNumber()) {
            let code = Int32.fromJSValue(ctx, err)
            BusinessException(JS_INTERNAL_ERROR, "unknown exception occured")
        } else {
            BusinessException(JS_INTERNAL_ERROR, "unknown exception occured")
        }
    }

    private static func getJSModule(ctx: JSContext, name: String, prefix: ?String, isHsp!: Bool = false): JSObject {
        match (MAIN_CONTEXT_MODULE_MAP.get(name)) {
            case Some(v) => v
            case None =>
                let module = if (isHsp) {
                    ctx.global[name.replace('.', "_")].asObject(ctx)
                } else {
                    ctx.requireSystemNativeModule(name, prefix: prefix).asObject(ctx)
                }
                MAIN_CONTEXT_MODULE_MAP.put(name, module)
                module
        }
    }

    private static func asyncToSyncCallback<T>(funcName: String): (BlockingQueue<SyncResp<T>>, AsyncCallback<T>) {
        let queue = BlockingQueue<SyncResp<T>>()
        let callback = {
            error: ?BusinessException, value: ?T => if (let Some(err) <- error) {
                AppLog.info("===> Execute method ${funcName} Failed, Reason: ${err.message}")
                queue.enqueue(SyncResp<T>(None, "Execute method ${funcName} Failed, Reason: ${err.message}"))
                throw err
            } else {
                if (let Some(v) <- value) {
                    AppLog.info("===> Execute method ${funcName} Sucess")
                    spawn {queue.enqueue(SyncResp<T>(v, ""))}
                    return
                } else {
                    AppLog.info("===> Execute method ${funcName} Failed, Reason: None Value")
                    queue.enqueue(SyncResp<T>(None, "Execute method ${funcName} Failed, Reason: None Value"))
                }
            }
        }
        return (queue, callback)
    }

    // --------------------------------------- PROPERTY -------------------------------------//
    public static func getModuleProperty(moduleName: String, propertyName: String, prefix!: ?String = None): JSValue {
        let context = getMainContext()
        getJSModule(context, moduleName, prefix).getProperty(propertyName)
    }

    // --------------------------------------- BASIC TYPE -------------------------------------//
    public static func toJSArray<T>(ctx: JSContext, cjArr: ?Array<T>): JSValue where T <: JSInteropType<T> {
        toJSArray<T>(ctx, cjArr) {ctx, item => item.toJSValue(ctx)}
    }

    public static func toJSArray<T>(ctx: JSContext, cjArr: ?Array<T>, constructor: (JSContext, T) -> JSValue): JSValue {
        if (let Some(arr) <- cjArr) {
            let jsArr = Array<JSValue>(arr.size) {
                i => constructor(ctx, arr[i])
            }
            ctx.array(jsArr).toJSValue()
        } else {
            ctx.undefined().toJSValue()
        }
    }

    // --------------------------------------- ABILITY CONTEXT -------------------------------------//
    private static func getAbilityContext(): JSValue {
        let context = getMainContext()
        getAbilityContext(context)
    }

    public static func getAbilityContext(context: JSContext): JSValue {
        AppLog.info("==>getAbilityContext1")
        let g = context.global
        AppLog.info("==>getAbilityContext2")
        //context.clazz(context.undefined().toJSValue())
        //let c = g.instanceOf(JSUndefined)
        //AppLog.info("==>getAbilityContext7")
        let a = g.callMethod('getContext')
        AppLog.info("==>getAbilityContext4")
        let b = a.asObject(context).toJSValue()
        AppLog.info("==>getAbilityContext3")
        b
    }

    // --------------------------------------- GLOBAL CUSTOM FUNC -------------------------------------//
    /*
    * 调用arkts全局自定义函数(即混合工程中使用globalThis暴露的函数)
    */
    private static func arkGlobalCustomFunc<T>(funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T {
        func call(context: JSContext): T {
            try {
                let jsRet = context.global.callMethod(funcName, args(context))
                onResolve(context, jsRet)
            } catch (e: JSCodeError) {
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        checkThreadAndCall<T>(getMainContext(), call)
    }

    /*
    * 调用arkts全局自定义函数(即混合工程中使用globalThis暴露的函数)
    */
    public static func arkGlobalCustomFunc<T>(funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalCustomFunc(funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 调用arkts全局自定义异步函数(即混合工程中使用globalThis暴露的函数)
    * 通过callback回调
    */
    private static func arkGlobalCustomFunc<T>(funcName: String, callback: AsyncCallback<T>, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): Unit {
        func call(context: JSContext): Unit {
            try {
                let jsRet = context.global.callMethod(funcName, args(context))
                let promise = jsRet.asPromise(context)
                let onResolved = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        var result = None<T>
                        try {
                            result = onResolve(ctx, callInfo[0])
                        } catch (e: BusinessException) {
                            callback(e, None)
                        } catch (e: Exception) {
                            callback(BusinessException(JS_INTERNAL_ERROR, e.message), None)
                        }
                        if (let Some(v) <- result) {
                            callback(None, v)
                        }
                        ctx.null().toJSValue()
                    }
                )
                let onRejected = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        callback(handleAsyncError(ctx, callInfo[0]), None)
                        ctx.null().toJSValue()
                    }
                )
                promise.then(onResolved, onRejected: onRejected)
            } catch (e: JSCodeError) {
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        checkThreadAndCall<Unit>(getMainContext(), call)
    }

    /*
    * 调用arkts全局自定义异步函数(即混合工程中使用globalThis暴露的函数)
    * 通过callback回调
    */
    public static func arkGlobalCustomFunc<T>(funcName: String, callback: AsyncCallback<T>, args: (JSContext) -> Array<JSValue>): Unit where T <: JSInteropType<T> {
        arkGlobalCustomFunc(funcName, callback, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 调用arkts全局自定义异步函数(即混合工程中使用globalThis暴露的函数)转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    private static func arkGlobalCustomFuncSync<T>(funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T {
        let (queue, callback) = asyncToSyncCallback<T>(funcName)
        arkGlobalCustomFunc<T>(funcName, callback, args, onResolve)
        let syncResp = queue.dequeue()
        if (let Some(v) <- syncResp.value) {
            v
        } else {
            throw Exception(syncResp.error)
        }
    }

    /*
    * 调用arkts全局自定义异步函数(即混合工程中使用globalThis暴露的函数)转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    private static func arkGlobalCustomFuncSync<T>(funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        let (queue, callback) = asyncToSyncCallback<T>(funcName)
        arkGlobalCustomFunc<T>(funcName, callback, args) {ctx, jv => T.fromJSValue(ctx, jv)}
        let syncResp = queue.dequeue()
        if (let Some(v) <- syncResp.value) {
            v
        } else {
            throw Exception(syncResp.error)
        }
    }

    // --------------------------------------- GLOBAL FUNC -------------------------------------//
    /*
    * 调用arkts全局同步函数
    */
    private static func arkGlobalFunc<T>(moduleName: String, modulePrefix: ?String, funcName: String,
        args: (JSContext) -> Array<JSValue>, onResolve: (JSContext, JSValue) -> T): T {
        func call(context: JSContext): T {
            try {
                let jsModule = getJSModule(context, moduleName, modulePrefix)
                let jsRet = jsModule.callMethod(funcName, args(context))
                onResolve(context, jsRet)
            } catch (e: JSCodeError) {
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        checkThreadAndCall<T>(getMainContext(), call)
    }

    /*
    * 调用arkts全局同步函数
    */
    private static func arkGlobalFunc<T>(moduleName: String, modulePrefix: ?String, funcName: String,
        args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalFunc(moduleName, modulePrefix, funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 调用arkts全局异步, 通过callback回调
    */
    private static func arkGlobalFunc<T>(moduleName: String, modulePrefix: ?String, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>, onResolve: (JSContext, JSValue) -> T): Unit {
        AppLog.info("==>arkGlobalFunc0")
        func call(context: JSContext): Unit {
            try {
                AppLog.info("==>arkGlobalFunc13")
                let x = getJSModule(context, moduleName, modulePrefix)
                AppLog.info("==>arkGlobalFunc113")
                let a = args(context)
                AppLog.info("==>arkGlobalFunc114")
                let jsRet = x.callMethod(funcName, a)
                AppLog.info("==>arkGlobalFunc14")
                let promise = jsRet.asPromise(context)
                AppLog.info("==>arkGlobalFunc15")
                let onResolved = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        var result = None<T>
                        AppLog.info("==>arkGlobalFunc1")
                        try {
                            result = onResolve(ctx, callInfo[0])
                            AppLog.info("==>arkGlobalFunc2")
                        } catch (e: BusinessException) {
                            AppLog.info("==>arkGlobalFunc3")
                            callback(e, None)
                        } catch (e: Exception) {
                            AppLog.info("==>arkGlobalFunc4")
                            callback(BusinessException(JS_INTERNAL_ERROR, e.message), None)
                        }
                        AppLog.info("==>arkGlobalFunc5")
                        if (let Some(v) <- result) {
                            AppLog.info("==>arkGlobalFunc6")
                            callback(None, v)
                        }
                        AppLog.info("==>arkGlobalFunc7")
                        ctx.null().toJSValue()
                    }
                )
                let onRejected = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        AppLog.info("==>arkGlobalFunc8")
                        callback(handleAsyncError(ctx, callInfo[0]), None)
                        AppLog.info("==>arkGlobalFunc9")
                        ctx.null().toJSValue()
                    }
                )
                AppLog.info("==>arkGlobalFunc12")
                promise.then(onResolved, onRejected: onRejected)
            } catch (e: JSCodeError) {
                AppLog.info("==>arkGlobalFunc10")
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        AppLog.info("==>arkGlobalFunc11")
        checkThreadAndCall<Unit>(getMainContext(), call)
    }

    /*
    * 调用arkts全局异步, 通过callback回调
    */
    private static func arkGlobalFunc<T>(moduleName: String, modulePrefix: ?String, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>): Unit where T <: JSInteropType<T> {
        arkGlobalFunc(moduleName, modulePrefix, funcName, callback, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 将arkts全局异步函数转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    private static func arkGlobalFuncSync<T>(moduleName: String, modulePrefix: ?String, funcName: String,
        args: (JSContext) -> Array<JSValue>, onResolve: (JSContext, JSValue) -> T): T {
        AppLog.info("==>arkGlobalFuncSync0")
        let (queue, callback) = asyncToSyncCallback<T>(funcName)
        AppLog.info("==>arkGlobalFuncSync1")
        arkGlobalFunc<T>(moduleName, modulePrefix, funcName, callback, args, onResolve)
        AppLog.info("==>arkGlobalFuncSync2")
        let syncResp = queue.dequeue()
        if (let Some(v) <- syncResp.value) {
            v
        } else {
            throw Exception(syncResp.error)
        }
    }

    /*
    * 将arkts全局异步函数转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    private static func arkGlobalFuncSync<T>(moduleName: String, modulePrefix: ?String, funcName: String,
        args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalFuncSync(moduleName, modulePrefix, funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 调用arkts全局同步函数
    */
    public static func ohosGlobalFunc<T>(moduleName: String, funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T {
        arkGlobalFunc<T>(moduleName, None, funcName, args, onResolve)
    }

    /*
    * 调用arkts全局同步函数
    */
    public static func ohosGlobalFunc<T>(moduleName: String, funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalFunc<T>(moduleName, None, funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 调用arkts全局异步, 通过callback回调
    */
    private static func ohosGlobalFunc<T>(moduleName: String, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>, onResolve: (JSContext, JSValue) -> T): Unit {
        arkGlobalFunc<T>(moduleName, None, funcName, callback, args, onResolve)
    }

    /*
    * 调用arkts全局异步, 通过callback回调
    */
    private static func ohosGlobalFunc<T>(moduleName: String, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>): Unit where T <: JSInteropType<T> {
        arkGlobalFunc<T>(moduleName, None, funcName, callback, args)
    }

    /*
    * 调用arkts全局同步函数
    */
    private static func ohosGlobalFunc<T>(moduleName: String, modulePrefix: ?String, funcName: String,
        args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalFunc<T>(moduleName, None, funcName, args)
    }

    /*
    * 将arkts全局异步函数转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    public static func ohosGlobalFuncSync<T>(moduleName: String, funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkGlobalFuncSync<T>(moduleName, None, funcName, args)
    }

    /*
    * 将arkts全局异步函数转为同步函数
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    public static func ohosGlobalFuncSync<T>(moduleName: String, funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T where T <: JSInteropType<T> {
        AppLog.info("==>queryContacts ohosGlobalFuncSync")
        arkGlobalFuncSync<T>(moduleName, None, funcName, args, onResolve)
    }

    // --------------------------------------- ARK OBJ FUNC -------------------------------------//
    /*
    * 将arkts对象的同步函数
    */
    private static func arkObjectFunc<T>(obj: JSObject, funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T {
        func call(context: JSContext): T {
            try {
                let jsRet = obj.callMethod(funcName, args(context))
                onResolve(context, jsRet)
            } catch (e: JSCodeError) {
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        checkThreadAndCall<T>(getMainContext(), call)
    }

    /*
    * 将arkts对象的同步函数
    */
    public static func arkObjectFunc<T>(obj: JSObject, funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkObjectFunc(obj, funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 将arkts对象的异步, 通过callback回调
    */
    private static func arkObjectFunc<T>(obj: JSObject, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>, onResolve: (JSContext, JSValue) -> T): Unit {
        func call(context: JSContext): Unit {
            try {
                let jsRet = obj.callMethod(funcName, args(context))
                let promise = jsRet.asPromise(context)
                let onResolved = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        var result = None<T>
                        try {
                            result = onResolve(ctx, callInfo[0])
                        } catch (e: BusinessException) {
                            callback(e, None)
                        } catch (e: Exception) {
                            callback(BusinessException(JS_INTERNAL_ERROR, e.message), None)
                        }
                        if (let Some(v) <- result) {
                            callback(None, v)
                        }
                        ctx.null().toJSValue()
                    }
                )
                let onRejected = context.function(
                    {
                        ctx: JSContext, callInfo: JSCallInfo =>
                        callback(handleAsyncError(ctx, callInfo[0]), None)
                        ctx.null().toJSValue()
                    }
                )
                promise.then(onResolved, onRejected: onRejected)
            } catch (e: JSCodeError) {
                throw BusinessException(e.code.getOrDefault({=> 0}), e.jsError)
            }
        }
        checkThreadAndCall<Unit>(getMainContext(), call)
    }

    /*
    * 将arkts对象的异步, 通过callback回调
    */
    private static func arkObjectFunc<T>(obj: JSObject, funcName: String, callback: AsyncCallback<T>,
        args: (JSContext) -> Array<JSValue>): Unit where T <: JSInteropType<T> {
        arkObjectFunc(obj, funcName, callback, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }

    /*
    * 将arkts对象的异步, 通过callback回调
    * 注意: 该函数不能在页面主函数中直接调用, 调用栈最外层必须使用spawn包裹
    */
    public static func arkObjectFuncSync<T>(obj: JSObject, funcName: String, args: (JSContext) -> Array<JSValue>,
        onResolve: (JSContext, JSValue) -> T): T {
        let (queue, callback) = asyncToSyncCallback<T>(funcName)
        arkObjectFunc<T>(obj, funcName, callback, args, onResolve)
        let syncResp = queue.dequeue()
        if (let Some(v) <- syncResp.value) {
            v
        } else {
            throw Exception(syncResp.error)
        }
    }

    public static func arkObjectFuncSync<T>(obj: JSObject, funcName: String, args: (JSContext) -> Array<JSValue>): T where T <: JSInteropType<T> {
        arkObjectFuncSync<T>(obj, funcName, args) {ctx, jv => T.fromJSValue(ctx, jv)}
    }
}
