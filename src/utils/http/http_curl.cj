/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils.http

import magic.log.LogUtils
import magic.config.Config
import magic.utils.{saveTempFile, newProcess, removeIfExists}

import std.io.InputStream
import std.io.StringReader
import std.collection.{ArrayList, HashMap}
import std.process.SubProcess
import std.regex.Regex
import std.convert.Parsable

import stdx.encoding.json.*
import stdx.net.http.HttpHeaders
@When[cjc_version < "1.0.0"]
import std.time.Duration

private func prepareCurlArgs(method: String, url: String, header: HashMap<String, String>, body: Option<JsonObject>, verify: Bool): Array<String> {
    let args = ArrayList<String>()
    args.add("-X")
    args.add(method)
    args.add("-v") // Get response headers
    args.add("--write-out")  // Defines a custom output format
    args.add("\n%{http_code}")
    args.add("--no-buffer")  // Disable output buffering
    args.add("--silent")     // Disables curl's default progress
    args.add("--show-error") // Show error messages (but keeps other output silent)
    // args.add("--connect-timeout") // Do not set the timeout currently
    // args.add("${Config.httpConnectTimeout / 1000}")
    // args.add("--max-time")
    // args.add("${(Config.httpConnectTimeout + Config.httpReadTimeout) / 1000}")
    args.add("--location")
    args.add("${url}")
    args.add("--noproxy")
    args.add("localhost,127.0.0.1")
    for ((k, v) in header) {
        args.add("--header")
        args.add("${k}: ${v}")
    }
    if (!verify) {
        args.add("--insecure")
    }
    if (let Some(b) <- body) {
        args.add("--data")
        // Since the length of the argument passed to the Process.start is limited,
        // we save the http body in a file and pass its path.
        // This argument must be the last one
        let tempPath = saveTempFile(Config.modelRequestDir, b.toJsonString())
        args.add("@${tempPath}")
    }
    return args.toArray()
}

//=====================================================================================

@When[ohos != "true" && http == "curl"]
protected struct HttpUtilsImpl {
    static private func newCurlProcess(method: String,
                                       url: String,
                                       header: HashMap<String, String>,
                                       body: Option<JsonObject>,
                                       verify: Bool,
                                       async!: Bool): SubProcess {
        logHttpInfo(method, url, header, body, async: async)
        let args = prepareCurlArgs(method, url, header, body, verify)
        try {
            let subProcess = newProcess("curl", args)
            let errReader = StringReader<InputStream>(subProcess.stdErr)
            let _ = errReader.readln() // Wait until the first line is read
            return subProcess
        } finally {
            if (body.isSome() && !Config.saveModelRequest) {
                let tempPath = args[args.size-1].removePrefix("@")
                removeIfExists(tempPath)
            }
        }
    }

    static protected func send(method: String,
                               url: String,
                               header: HashMap<String, String>,
                               body: Option<JsonObject>,
                               verify!: Bool): Option<String> {
        let subProcess = newCurlProcess(method, url, header, body, verify, async: false)

        let errReader = StringReader<InputStream>(subProcess.stdErr)
        let err = errReader.readToEnd()
        LogUtils.trace("Raw http response headers: ${err}")
        return processJson(subProcess)
    }

    /**
     * Process the http response json output
     */
    static private func processJson(subProcess: SubProcess): String {
        let outReader = StringReader<InputStream>(subProcess.stdOut)
        let out = outReader.readToEnd()
        subProcess.wait(timeout: Duration.millisecond * Config.httpReadWriteTimeout)

        let (resp, status) = HttpUtilsImpl.parseCurlOutput(out)
        LogUtils.trace("Raw http response: ${out}")
        if (status != "200" && status != "202") {
            let msg = "Http status: ${status}.\nHttp response: ${resp}"
            LogUtils.error("curl failed")
            LogUtils.error(msg)
            throw HttpException(msg)
        } else {
            return resp
        }
    }

    static protected func asyncSend(method: String,
                                    url: String,
                                    header: HashMap<String, String>,
                                    body: Option<JsonObject>,
                                    verify!: Bool): HttpStream {
        let httpStream = HttpStream()
        let fut = spawn {
            let subProcess = newCurlProcess(method, url, header, body, verify, async: true)
            processStream(subProcess, httpStream)
        }
        return httpStream
    }

    static private func processStream(subProcess: SubProcess, httpStream: HttpStream): Unit {
        let outReader = StringReader<InputStream>(subProcess.stdOut)
        // Each line is a chunk response from chat models
        // The last line is the status code
        var prevLine: Option<String> = None
        while (let Some(line) <- outReader.readln()) {
            // LogUtils.debug("Receive http stream: `${line}`")
            if (let Some(l) <- prevLine) {
                httpStream.put("${l}\n".toArray())
            }
            prevLine = line
        }
        subProcess.wait(timeout: Duration.minute * 1)

        let status = prevLine.getOrThrow() // The last line is the status code
        if (status.trimAscii() != "200" && status.trimAscii() != "202") {
            LogUtils.error("curl failed")
            httpStream.markError()
        } else {
            // Put the termination mark
            LogUtils.debug("End http stream. Status: ${status}")
            httpStream.markEOF()
        }
    }

    static protected func hybridSend(method: String,
                                     url: String,
                                     header: HashMap<String, String>,
                                     body: Option<JsonObject>,
                                     verify!: Bool): HttpResult {
        let subProcess = newCurlProcess(method, url, header, body, verify, async: false)

        let errReader = StringReader<InputStream>(subProcess.stdErr)
        let err = errReader.readToEnd()
        LogUtils.trace("Raw http response headers: ${err}")
        let (status, respHeader) = parseCurlVerboseMessage(err)

        if ((respHeader.getFirst("Content-Type") ?? "") == "text/event-stream") {
            let httpStream = HttpStream()
            spawn {
                processStream(subProcess, httpStream)
            }
            return HttpResult(
                status: status,
                header: respHeader,
                value: HttpResultOption.Stream(httpStream)
            )
        } else {
            return HttpResult(
                status: status,
                header: respHeader,
                value: HttpResultOption.Json(processJson(subProcess))
            )
        }
    }

    /**
     * Parse the curl output to get the status code and headers.
     */
    protected static func parseCurlVerboseMessage(curlOutput: String): (Int64, HttpHeaders) {
        // Extract status line (e.g., "< HTTP/1.1 200 OK")
        var status = 200
        let header = HttpHeaders()
        for (line in curlOutput.split("\n")) {
            if (line.startsWith("< HTTP/")) {
                let regex = Regex("^< HTTP/\\d\\.\\d (\\d{3}) .+$")
                if (let Some(md) <- regex.find(line, group: true)) {
                    status = Int64.parse(md.matchString(1))
                }
            } else if (line.startsWith("< ")) {
                let regex = Regex("^< ([^:]+): (.+)$")
                if (let Some(md) <- regex.find(line, group: true)) {
                    header.add(md.matchString(1), md.matchString(2))
                }
            }
        }
        return (status, header)
    }

    /**
     * Parse the curl output to get the response body and status code.
     */
    static private func parseCurlOutput(output: String): (String, String) {
        // Split the last line (status code) from the rest (response body)
        let lines = output.trimAscii().split("\n")

        // Handle empty output case
        if (lines.size == 0) {
            throw HttpException("Empty response from curl command")
        }

        // Handle case with only status code
        if (lines.size == 1) {
            return ("", lines[0].trimAscii())
        }

        let response = String.join(lines[0..(lines.size-1)], delimiter: "\n") // All lines except last
        let status = lines[lines.size-1].trimAscii()  // Last line is the status code
        return (response, status)
    }
}