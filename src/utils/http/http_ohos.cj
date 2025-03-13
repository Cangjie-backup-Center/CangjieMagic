/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils

import std.collection.HashMap
import encoding.json.JsonValue
import std.collection.concurrent.BlockingQueue
@When[ohos == "true"]
import ohos.net.http.*

//=====================================================================================

@When[ohos == "true"]
internal func httpPostOhos(url: String,
                           header: HashMap<String, String>,
                           body: JsonValue,
                           verify!: Bool = false): Option<String> {
    let httpRequest = createHttp()
    let httpOpt = HttpRequestOptions(
        method: RequestMethod.POST,
        extraData: HttpData.STRING_DATA(body.toJsonString()),
        expectDataType: HttpDataType.STRING,
        header: header
    )
    let queue = BlockingQueue<String>()
    httpRequest.request(
        url,
        { err, resp =>
            spawn {
                if (let Some(e) <- err) {
                    LogUtils.error("Request failed. Exception: ${e.message}")
                    queue.enqueue("[ERROR_request]")
                }
                if (let Some(r) <- resp){
                    match (r.result) {
                        case STRING_DATA(value) => queue.enqueue(value)
                        case ARRAY_DATA(value) => queue.enqueue(String.fromUtf8(value))
                    }
                }
                httpRequest.destroy()
            }
        },
        options: httpOpt
    )
    // Receive the response content
    let msg = queue.dequeue()
    if (msg == "[ERROR_request]") {
        throw HttpException("Http request error")
    }
    LogUtils.debug("Raw http response: ${msg}")
    return msg
}

@When[ohos == "true"]
internal func asyncHttpPostOhos(url: String,
                                header: HashMap<String, String>,
                                body: JsonValue,
                                verify!: Bool = false): HttpStream {
    let httpStream = HttpStream()
    let httpRequest = createHttp()
    // Register callbacks
    httpRequest.onDataReceive({ data: Array<Byte> =>
        let str = String.fromUtf8(data)
        LogUtils.debug("Receive http stream: ${str}")
        // Each line is a chunk response from chat models, so we split the data here
        for (lines in str.split("\n", removeEmpty: true)) {
            httpStream.put(lines)
        }
    })
    httpRequest.onDataEnd({ =>
        LogUtils.debug("End http stream")
        httpStream.markEOF()
        httpRequest.offDataReceive()
        httpRequest.offDataEnd()
        httpRequest.destroy()
    })
    // Make the request
    let httpOpt = HttpRequestOptions(
        method: RequestMethod.POST,
        extraData: HttpData.STRING_DATA(body.toJsonString()),
        expectDataType: HttpDataType.STRING,
        header: header
    )
    httpRequest.requestInStream(
        url,
        { err, code =>
            if (let Some(e) <- err) {
                LogUtils.error("Http stream request failed. Exception: ${e.message}")
                httpStream.markError()
                httpStream.markEOF()
            }
        },
        options: httpOpt
    )
    return httpStream
}
