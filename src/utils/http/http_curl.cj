/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.config.Config
import magic.utils.{saveTempFile, newProcess, removeIfExists, StringExt}

import std.io.InputStream
import std.io.StringReader
import std.collection.HashMap
import std.collection.ArrayList
import encoding.json.*
@When[cjc_version < "0.56.4"]
import std.time.Duration

private func prepareCurlArgs(method: String, url: String, header: HashMap<String, String>, body: Option<JsonObject>, verify: Bool): Array<String> {
    let args = ArrayList<String>()
    args.append("-X")
    args.append(method)
    args.append("--write-out")  // Defines a custom output format
    args.append("\n%{http_code}")
    args.append("--no-buffer")  // Disable output buffering
    args.append("--silent")     // Disables curl's default progress
    args.append("--show-error") // Show error messages (but keeps other output silent)
    // args.append("--connect-timeout") // Do not set the timeout currently
    // args.append("${Config.httpConnectTimeout / 1000}")
    // args.append("--max-time")
    // args.append("${(Config.httpConnectTimeout + Config.httpReadTimeout) / 1000}")
    args.append("--location")
    args.append("${url}")
    args.append("--noproxy")
    args.append("localhost,127.0.0.1")
    for ((k, v) in header) {
        args.append("--header")
        args.append("${k}: ${v}")
    }
    if (!verify) {
        args.append("--insecure")
    }
    if (let Some(b) <- body) {
        args.append("--data")
        // Since the length of the argument passed to the Process.start is limited,
        // we save the http body in a file and pass its path.
        // This argument must be the last one
        let tempPath = saveTempFile(Config.modelRequestDir, b.toJsonString())
        args.append("@${tempPath}")
    }
    return args.toArray()
}

//=====================================================================================

@When[ohos != "true" && http == "curl"]
protected struct HttpUtilsImpl {

    static private func parseOutput(output: String): (String, String) {
        // Split the last line (status code) from the rest (response body)
        let lines = output.trimAscii().split("\n")
        let response = String.join(lines[0..(lines.size-1)], delimiter: "\n") // All lines except last
        let status = lines[lines.size-1].trimAscii()  // Last line is the status code
        return (response, status)
    }

    static protected func send(method: String,
                               url: String,
                               header: HashMap<String, String>,
                               body: Option<JsonObject>,
                               verify!: Bool): Option<String> {
        logHttpInfo(method, url, header, body, async: false)
        let args = prepareCurlArgs(method, url, header, body, verify)
        let subProcess = newProcess("curl", args)
        let outReader = StringReader<InputStream>(subProcess.stdOut)
        let out = outReader.readToEnd()
        subProcess.wait(timeout: Duration.minute * 1)
        if (body.isSome() && !Config.saveModelRequest) {
            let tempPath = args[args.size-1].removePrefix("@")
            removeIfExists(tempPath)
        }
        let (resp, status) = HttpUtilsImpl.parseOutput(out)
        LogUtils.debug("Raw http response: ${out}")
        if (status != "200" && status != "202") {
            LogUtils.error("curl ${url} with data: ${(body ?? JsonObject()).toJsonString()} failed")
            LogUtils.error("Status: ${status}. Response: ${resp}")
            return None
        } else {
            return resp
        }
    }

    static protected func asyncSend(method: String,
                                    url: String,
                                    header: HashMap<String, String>,
                                    body: Option<JsonObject>,
                                    verify!: Bool): HttpStream {
        logHttpInfo(method, url, header, body, async: true)
        let httpStream = HttpStream()
        let fut = spawn {
            let args = prepareCurlArgs(method, url, header, body, verify)
            let subProcess = newProcess("curl", args.toArray())
            let outReader = StringReader<InputStream>(subProcess.stdOut)
            // Each line is a chunk response from chat models
            // The last line is the status code
            var prevLine: Option<String> = None
            while (let Some(line) <- outReader.readln()) {
                LogUtils.debug("Receive http stream: `${line}`")
                if (let Some(l) <- prevLine) {
                    httpStream.put("${l}\n".toArray())
                }
                prevLine = line
            }
            subProcess.wait(timeout: Duration.minute * 1)
            if (body.isSome() && !Config.saveModelRequest) {
                let tempPath = args[args.size-1].removePrefix("@")
                removeIfExists(tempPath)
            }
            let status = prevLine.getOrThrow() // The last line is the status code
            if (status.trimAscii() != "200" && status.trimAscii() != "202") {
                LogUtils.error("curl ${url} failed. Data :${(body ?? JsonObject()).toJsonString()}")
                httpStream.markError()
            } else {
                // Put the termination mark
                httpStream.markEOF()
                LogUtils.debug("End http stream. Status: ${status}")
            }
        }
        return httpStream
    }
}