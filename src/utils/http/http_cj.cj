/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.utils.getEnv

import std.collection.HashMap
@When[cjc_version < "1.0.0"]
import std.socket.{SocketAddress, TcpSocket}
@When[cjc_version >= "1.0.0"]
import std.net.{SocketAddress, TcpSocket}
import std.io.StringReader
import stdx.net.tls.{TlsClientConfig, CertificateVerifyMode}
import stdx.net.http.*
import stdx.encoding.json.*
import stdx.encoding.url.URL

@When[cjc_version < "1.0.0"]
import std.time.Duration

private func buildHttpClient(url: String, verify: Bool): Client {
    let cb = ClientBuilder()
    cb.readTimeout(Duration.minute * 10)
    if (url.startsWith("https")) {
        var config = TlsClientConfig()
        if (!verify) {
            config.verifyMode = TrustAll
        }
        config.domain = URL.parse(url).hostName
        cb.tlsConfig(config)
    }
    let TcpSocketConnector = { sa: SocketAddress =>
        let socket = TcpSocket(sa)
        socket.readTimeout = Duration.second * 60
        socket.writeTimeout = Duration.second * 60
        socket.connect(timeout: Duration.second * 60)
        return socket
    }
    cb.connector(TcpSocketConnector)
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
        try {
            let respBody = readHttpBody(resp)
            if (resp.status != HttpStatusCode.STATUS_OK &&
                resp.status != HttpStatusCode.STATUS_ACCEPTED) {
                let msg = "Http status: ${resp.status}.\nHttp response: ${respBody}"
                LogUtils.error("Http ${method} ${url} with data: ${(body ?? JsonObject()).toJsonString()} failed")
                LogUtils.error(msg)
                throw HttpException(msg)
            }
            return respBody
        } finally {
            client.close()
        }
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
        if (resp.status != HttpStatusCode.STATUS_OK &&
            resp.status != HttpStatusCode.STATUS_ACCEPTED) {
            let err = readHttpBody(resp)
            LogUtils.error("Http ${method} ${url} with data: ${(body ?? JsonObject()).toJsonString()} failed")
            LogUtils.error("Error: ${err}; ${resp}")
            client.close()
            httpStream.markError()
        } else {
            spawn {
                let buffer = Array<Byte>(1024 * 10, { _ => 0})
                while (true) {
                    let length = resp.body.read(buffer)
                    if (length == 0) {
                        break
                    } else {
                        httpStream.put(buffer[..length])
                    }
                }
                client.close()
            }
        }
        return httpStream
    }
}