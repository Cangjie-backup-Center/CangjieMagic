/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

@When[cjc_version < "0.56.4"]
import std.time.Duration
@When[cjc_version < "0.56.4"]
import std.sync.sleep

@When[cjc_version < "0.56.4"]
import std.os.process.{Process, ProcessRedirect, SubProcess}
//--------------------------------------------------------
@When[cjc_version >= "0.56.4"]
import std.process.{Process, ProcessRedirect, SubProcess}
//======================================================

@When[cjc_version < "0.56.4"]
import std.os.getEnv as stdGetEnv
@When[cjc_version < "0.56.4"]
import std.os.setEnv as stdSetEnv

import std.collection.HashMap

@When[cjc_version < "0.56.4"]
protected func getEnv(envVarName: String): Option<String> {
    stdGetEnv(envVarName)
}
@When[cjc_version >= "0.56.4"]
protected func getEnv(envVarName: String): Option<String> {
    Process.current.getEnv(envVarName)
}

@When[cjc_version < "0.56.4"]
protected func setEnv(envVarName: String, value: String): Unit {
    stdSetEnv(envVarName, value)
}
@When[cjc_version >= "0.56.4"]
protected func setEnv(envVarName: String, value: String): Unit {
    Process.current.setEnv(envVarName, value)
}

protected func newProcess(name: String, args: Array<String>, env!: Array<(String, String)> = [], redirectErr!: Bool = true): SubProcess {
    let allEnv = HashMap(Process.current.environment)
    allEnv.putAll(env)
    if (redirectErr) {
        return Process.start(
            name, args,
            environment: allEnv,
            stdIn: ProcessRedirect.Pipe,
            stdOut: ProcessRedirect.Pipe,
            stdErr: ProcessRedirect.Pipe
        )
    } else {
        return Process.start(
            name, args,
            environment: allEnv,
            stdIn: ProcessRedirect.Pipe,
            stdOut: ProcessRedirect.Pipe
        )
    }
}

protected func sleep2(ms: Int64): Unit {
    sleep(Duration.millisecond * ms)
}