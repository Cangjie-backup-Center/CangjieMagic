/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tests

import magic.core.{Interceptor, InterceptorMode}
import magic.agent.HumanAgent
import std.unittest.testmacro.PowerAssert
import std.unittest.testmacro.PowerAssert

func mockUI(q: String): String {
    return "MOCK RESPONSE"
}

@Test
func testHumanIntercept() {
    let ag = Foo()
    let human = HumanAgent(qaFunc: mockUI)
    ag.interceptor = Interceptor(human, mode: InterceptorMode.Periodic(2))

    println(ag.chat("hello"))
    println(ag.chat("What's your name"))
    @Assert(ag.chat("How old are you"), "MOCK RESPONSE")

    println(ag.chat("Apple or orange?"))
    println(ag.chat("Nice to meet you"))
    @Assert(ag.chat("How old are you"), "MOCK RESPONSE")
}