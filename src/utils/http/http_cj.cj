/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.getEnv

import net.http.{Client, ClientBuilder, HttpRequest, HttpResponse, HttpRequestBuilder, HttpStatusCode}
import net.tls.TlsClientConfig
import net.tls.CertificateVerifyMode
import std.io.StringReader
import std.collection.HashMap
import encoding.json.JsonValue

@When[cjc_version < "0.56.4"]
import std.time.Duration

private func buildHttpClient(url: String, verify: Bool): Client {
    let cb = ClientBuilder()
    cb.readTimeout(Duration.minute * 10)
    if (url.startsWith("https")) {
        var config = TlsClientConfig()
        if (!verify) {
            config.verifyMode = TrustAll
        }
        cb.tlsConfig(config)
    }
    // if (let Some(proxy) <- getEnv("http_proxy")) {
    //     cb.httpProxy(proxy)
    // }
    // if (let Some(proxy) <- getEnv("https_proxy")) {
    //     cb.httpProxy(proxy)
    // }
    return cb.build()
}

private func prepareHttpRequest(url: String,
                                header: HashMap<String, String>,
                                body: JsonValue): HttpRequest {
    let rb = HttpRequestBuilder()
        .url(url)
        .body(body.toJsonString())
        .post()
    for ((k, v) in header) {
        rb.header(k, v)
    }
    return rb.build()
}

private func sendHttpPost(url: String,
                         header: HashMap<String, String>,
                         body: JsonValue,
                         verify: Bool): (Client, HttpResponse) {
    let client = buildHttpClient(url, verify)
    let req = prepareHttpRequest(url, header, body)
    return (client, client.send(req))
}

private func readHttpBody(resp: HttpResponse): String {
    let reader = StringReader(resp.body)
    return reader.readToEnd()
}

//=====================================================================================

internal func httpPostCJ(url: String,
                         header: HashMap<String, String>,
                         body: JsonValue,
                         verify!: Bool = false): Option<String> {
    header.put("Accept", "application/json")
    let (client, resp) = sendHttpPost(url, header, body, verify)
    if (resp.status != HttpStatusCode.STATUS_OK) {
        let err = readHttpBody(resp)
        LogUtils.error("Http post ${url} with data: ${body.toJsonString()} failed")
        LogUtils.error("Error: ${err}")
        client.close()
        return None
    }
    let respBody = readHttpBody(resp)
    client.close()
    return respBody
}

internal func asyncHttpPostCJ(url: String,
                              header: HashMap<String, String>,
                              body: JsonValue,
                              verify!: Bool = false): HttpStream {
    header.put("Accept", "text/event-stream")
    let (client, resp) = sendHttpPost(url, header, body, verify)
    let httpStream = HttpStream()
    if (resp.status != HttpStatusCode.STATUS_OK) {
        let err = readHttpBody(resp)
        LogUtils.error("Http post ${url} with data: ${body.toJsonString()} failed")
        LogUtils.error("Error: ${err}")
        client.close()
        httpStream.markError()
    } else {
        spawn {
            let reader = StringReader(resp.body)
            while (let Some(line) <- reader.readln()) {
                LogUtils.debug("Receive http stream: `${line}`")
                httpStream.put(line)
            }
            client.close()
        }
    }
    return httpStream
}
