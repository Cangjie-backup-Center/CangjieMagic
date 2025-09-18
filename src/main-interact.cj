/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic

import magic.dsl.*
import magic.prelude.*
import magic.agent.ConversationAgent
import magic.interaction.ConsolePrinter
import magic.interaction.*
import magic.core.interaction.*

func testInteract(): Unit {
    EventHandlerManager.global.addHandler { evt: ToolCallStartEvent =>
        eprintln("Global before tool call ${evt.agent.name} --> ${evt.toolRequest}")
        return EventResponse.Continue
    }

    EventHandlerManager.global.addHandler { evt: ToolCallEndEvent =>
        eprintln("Global after tool call ${evt.agent.name} --> ${evt.toolRequest}")
    }

    let resp = @asyncInteract[
        agent: AbcAgent(),
        request: AgentRequest("Search content about Kobe, and read detailed results")] (
        case evt: ToolCallStartEvent =>
            eprintln("Before tool call: ${evt.toolRequest}")
            return EventResponse.Continue
        case evt: ToolCallEndEvent =>
            eprintln("After Tool call: ${evt.toolRequest}")

        case evt: AgentStartEvent =>
            eprintln("Before Agent: ${evt.agentRequest.question}")
            return EventResponse.Continue
        case evt: AgentEndEvent =>
            eprintln("After Agent: ${evt.agentRequest.question}")

        case evt: ChatModelStartEvent =>
            eprintln("Before model: ${evt.agent.name}")
            return EventResponse.Continue
        case evt: ChatModelEndEvent =>
            eprintln("After Model: ${evt.agent.name}")

        case evt: ChatModelFailureEvent =>
            eprintln("Chat model failure: ${evt.error}")
            return EventResponse.Continue(ChatResponse("fake-model", Message.assistant("fake response")))
    )

    sleep(Duration.second * 1)
    eprintln("  >>> Cancelled the interaction now")
    resp.cancel()
    println(resp.content)

    return ()
}