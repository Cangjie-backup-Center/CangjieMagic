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
import encoding.json.*

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

private func prepareHttpRequest(method: String,
                                url: String,
                                header: HashMap<String, String>,
                                body: Option<JsonObject>): HttpRequest {
    let rb = HttpRequestBuilder().url(url)
    if (let Some(b) <- body) {
        rb.body(b.toJsonString())
    }
    if (method == "POST") {
        rb.post()
    } else if (method == "GET") {
        rb.get()
    }
    for ((k, v) in header) {
        rb.header(k, v)
    }
    return rb.build()
}

private func sendHttp(method: String,
                      url: String,
                      header: HashMap<String, String>,
                      body: Option<JsonObject>,
                      verify: Bool): (Client, HttpResponse) {
    let client = buildHttpClient(url, verify)
    let req = prepareHttpRequest(method, url, header, body)
    return (client, client.send(req))
}

private func readHttpBody(resp: HttpResponse): String {
    let reader = StringReader(resp.body)
    return reader.readToEnd()
}

//=====================================================================================

@When[ohos != "true" && http != "curl"]
protected struct HttpUtilsImpl {
    static protected func send(method: String,
                               url: String,
                               header: HashMap<String, String>,
                               body: Option<JsonObject>,
                               verify!: Bool): Option<String> {
        // header.put("Accept", "application/json")
        logHttpInfo(method, url, header, body, async: false)
        let (client, resp) = sendHttp(method, url, header, body, verify)
        if (resp.status != HttpStatusCode.STATUS_OK) {
            let err = readHttpBody(resp)
            LogUtils.error("Http ${method} ${url} with data: ${(body ?? JsonObject()).toJsonString()} failed")
            LogUtils.error("Error: ${err}")
            client.close()
            return None
        }
        let respBody = readHttpBody(resp)
        client.close()
        return respBody
    }

    static protected func asyncSend(method: String,
                                    url: String,
                                    header: HashMap<String, String>,
                                    body: Option<JsonObject>,
                                    verify!: Bool): HttpStream {
        // header.put("Accept", "text/event-stream")
        logHttpInfo(method, url, header, body, async: true)
        let (client, resp) = sendHttp(method, url, header, body, verify)
        let httpStream = HttpStream()
        if (resp.status != HttpStatusCode.STATUS_OK) {
            let err = readHttpBody(resp)
            LogUtils.error("Http ${method} ${url} with data: ${(body ?? JsonObject()).toJsonString()} failed")
            LogUtils.error("Error: ${err}; ${resp}")
            client.close()
            httpStream.markError()
        } else {
            spawn {
                let reader = StringReader(resp.body)
                while (let Some(line) <- reader.readln()) {
                    LogUtils.debug("Receive http stream: `${line}`")
                    httpStream.put(line.toArray())
                }
                client.close()
            }
        }
        return httpStream
    }
}