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
import encoding.json.JsonValue
@When[cjc_version < "0.56.4"]
import std.time.Duration

private func prepareCurlArgs(url: String, header: HashMap<String, String>, body: JsonValue, verify: Bool): Array<String> {
    let args = ArrayList<String>()
    args.append("-fsSL")
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
    args.append("--data")
    // Since the length limiation of the argument passed to the Process.start,
    // we save the http body in a file and pass its path.
    // This argument must be the last one
    let tempPath = saveTempFile(Config.modelRequestDir, body.toJsonString())
    args.append("@${tempPath}")
    return args.toArray()
}

//=====================================================================================

internal func httpPostCurl(url: String,
                           header: HashMap<String, String>,
                           body: JsonValue,
                           verify!: Bool = false): Option<String> {
    let args = prepareCurlArgs(url, header, body, verify)
    let subProcess = newProcess("curl", args)
    let outReader = StringReader<InputStream>(subProcess.stdOut)
    let errReader = StringReader<InputStream>(subProcess.stdErr)
    let out = outReader.readToEnd()
    let err = errReader.readToEnd()
    let rtnCode = subProcess.wait(timeout: Duration.minute * 10)
    if (!Config.saveModelRequest) {
        let tempPath = args[args.size-1].removePrefix("@")
        removeIfExists(tempPath)
    }
    if (rtnCode != 0) {
        LogUtils.error("curl ${url} with data :${body.toJsonString()} failed")
        LogUtils.error("Error: ${err}")
        return None
    } else {
        LogUtils.debug("Raw http response: ${out}")
        return out
    }
}

//=====================================================================================

internal func asyncHttpPostCurl(url: String,
                                header: HashMap<String, String>,
                                body: JsonValue,
                                verify!: Bool = false): HttpStream {
    let httpStream = HttpStream()
    let fut = spawn {
        let args = prepareCurlArgs(url, header, body, verify)
        let subProcess = newProcess("curl", args.toArray())
        let outReader = StringReader<InputStream>(subProcess.stdOut)
        let errReader = StringReader<InputStream>(subProcess.stdErr)
        // Each line is a chunk response from chat models
        while (let Some(line) <- outReader.readln()) {
            LogUtils.debug("Receive http stream: `${line}`")
            httpStream.put(line)
        }
        let rtnCode = subProcess.wait(timeout: Duration.minute * 10)
        if (!Config.saveModelRequest) {
            let tempPath = args[args.size-1].removePrefix("@")
            removeIfExists(tempPath)
        }
        if (rtnCode != 0) {
            let err = errReader.readToEnd()
            LogUtils.error("curl ${url} with data :${body.toJsonString()} failed")
            LogUtils.error(err)
            httpStream.markError()
        }
        // Put the termination mark
        httpStream.markEOF()
        LogUtils.debug("End http stream")
    }
    return httpStream
}