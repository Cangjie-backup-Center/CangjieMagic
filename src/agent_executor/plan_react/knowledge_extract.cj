/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */
package magic.agent_executor.plan_react

import magic.core.agent.*
import magic.core.message.Message
import magic.prompt.Template
import magic.log.LogUtils
import magic.parser.OutputParserUtils
import magic.model.ModelUtils

private let KNOWLEDGE_EXTRACT_SYSTEM_PROMPT = """
# Instruction
Given a problem/question and some instructions to solve it, extract knowledge from them.
You only need to extract the knowledge from the content, without performing any additional reasoning or generation.

Knowledge has the following categories:
- Constraints for problem-solving
- Background knowledge necessary for solving the problem

IMPORTANT constraints you must obey:
- **NEVER** answer the question.
- Knowledge MUST be extracted from the section `# Question` and `# Extra Instruction`, and **NEVER** just copy descriptions from the sections.
- Knowledge should be clear and precise, so you can rewrite the extracted content to make it easier to understand.
- If the extracted knowledge contradicts common sense, then you should rewrite the knowledge more carefully, emphasizing their importance and making them easier to understand.

The output should be a list, enclosed with ```knowledge and ``` in the format like this:
```knowledge
- ...
- ...
```
If there is no useful knowledge, just output ```knowledge ```

# Question
{question}
-----

# Extra Instruction
{systemPrompt}
-----

Now, extract knowledge:
"""

func knowledgeExtract(agent: Agent, request: AgentRequest): String {
    let sysPrompt = KNOWLEDGE_EXTRACT_SYSTEM_PROMPT.format(
        ("question", request.question),
        ("systemPrompt", agent.systemPrompt),
    )
    let messages = [
        Message.system(sysPrompt)
    ]

    let knowledge = ModelUtils.agentMakeChatGet(agent, messages) {
        msg: Message => OutputParserUtils.extractLastCode(msg.content, "knowledge")
    }
    return knowledge ?? ""
}
