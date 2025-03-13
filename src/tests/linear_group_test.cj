/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tests

import magic.prelude.*
import magic.dsl.*
import magic.log.LogUtils
import magic.config.Config
import std.unittest.testmacro.PowerAssert
import std.unittest.testmacro.BeforeAll

import log.LogLevel

@agent[executor: "naive", model: "${CHAT_MODEL}"]
class T1 {
    @prompt(
        "Translate the input into English"
    )
}

@agent[executor: "naive", model: "${CHAT_MODEL}"]
class T2 {
    @prompt(
        "Translate the input into French"
    )
}

@agent[executor: "naive", model: "${CHAT_MODEL}"]
class T3 {
    @prompt(
        "Translate the input into Chinese"
    )
}

@Test
class TestLinearGroup {
    @BeforeAll
    func setup() {
        Config.logLevel = LogLevel.INFO
    }
    @TestCase
    func test1() {
        let group = T1() |> T2() |> T3()
        @Assert(group.chat(AgentRequest("苹果")).content.contains("苹果"))
    }
}