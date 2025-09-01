/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.agent_executor.react

import magic.core.*
import magic.core.agent.AgentRequestExtra
import magic.agent_executor.common.AgentTask
import magic.core.message.{Message, Conversation}
import magic.agent_executor.common.PromptBuilder
import magic.log.LogUtils
import magic.prompt.Template
import magic.parser.{Tag, WithTag}
import magic.jsonable.TypeSchema

import stdx.encoding.json.JsonObject

// Modified from https://smith.langchain.com/hub/hwchase17/react
// Prompts of parallel tool call is copied from https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use
protected let REACT_SYSTEM_PROMPT_PREFIX = """
# Guidelines
Use the following format to accomplish user's request:
${Tag.THOUGHT} think about what to do next to solve the question ${Tag.THOUGHT.close}
${Tag.ACTION} use tools, the action must be a Json array:
    [
        {
            "name": string, name of the tool, it must refer to one of available tools
            "arguments": { [key: string]: unknown }, arguments for the tool, each argument must be a valid json value required by the tool; it can be omitted, if the tool does not accept parameters
        }
    ]
    For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.
${Tag.ACTION.close}
${Tag.OBSERVATION} the result of the action ${Tag.OBSERVATION.close}
... (Thought/Action/Observation may repeat N times to accomplish user's request)
${Tag.ANSWER} the final answer to the original input question ${Tag.ANSWER.close}

NEVER generate ${Tag.OBSERVATION} yourself. This is an important requirement.
If there are no available tools, generate final answer directly.

You must generate either a pair of ${Tag.THOUGHT} and ${Tag.ACTION} or a single ${Tag.ANSWER}.
"""

private let ACTION_EXAMPLE = """
${Tag.THOUGHT} I need to search the web to get related knowledge ${Tag.THOUGHT.close}
${Tag.ACTION}
[
  {
      "name": "foo"
      "arguments": {
          "url": "http://example.com",
          "count": 3,
          "items": ["abc", "xyz"]
      }
  },
  {
      "name": "bar"
      "arguments": {
          "arg": "http://example.com",
      }
  }
]
${Tag.ACTION.close}
"""

protected let REACT_SYSTEM_PROMPT = """
${REACT_SYSTEM_PROMPT_PREFIX}
**Output Examples:**

Output-1:
${ACTION_EXAMPLE}
Output-2:
${Tag.ANSWER} <output result here> ${Tag.ANSWER.close}
"""

protected let REACT_SYSTEM_PROMPT_WITH_STRUCTURE_OUTPUT = """
${REACT_SYSTEM_PROMPT_PREFIX}

You MUST output a JSON value obey the schema as the answer. The schema to follow:
{output_schema}

**Output Examples:**
Output-1:
${ACTION_EXAMPLE}
Output-2:
${Tag.ANSWER} ```json <output a JSON value here as the answer> ``` ${Tag.ANSWER.close}
"""

private let REACT_SUMMARIZE_SYSTEM_PROMPT = """
# Instruction
Given a question and a solving procedure for it, you should summarize an answer from them.
The solving procedure consists of:
  - ${Tag.THOUGHT} think about what to do next to solve the task ${Tag.THOUGHT.close}
  - ${Tag.ACTION} use a tool, which is a function call ${Tag.ACTION.close}
  - ${Tag.OBSERVATION} the result of the action ${Tag.OBSERVATION.close}
  - ... (Thought/Action/Observation may repeat N times)

The answer should be wrapped by ${Tag.ANSWER} and ${Tag.ANSWER.close} like
${Tag.ANSWER}
Cat is the answer, and ...
${Tag.ANSWER.close}

# Question
{question}
-----

# Solving Procedure
{procedure}
-----

# Some extra context to help answer the question
{systemPrompt}

{retrieval}

{memory}
"""

private let REACT_SUMMARIZE_USER_PROMPT = """
Now, summarize the answer. Remember you should wrap the output by ${Tag.ANSWER} and ${Tag.ANSWER.close}
"""

let REACT_STEP_PROMPT = """
Decide what to do next.
Output either a pair of ${Tag.THOUGHT} and ${Tag.ACTION}, or a single ${Tag.ANSWER}.
"""

protected struct ReactPromptUtils {
    private static func buildReactSystemPrompt(task: AgentTask): String {
        return task.request.extra.get(AgentRequestExtra.OUTPUT_SCHEMA)
            .map { schema =>
                REACT_SYSTEM_PROMPT_WITH_STRUCTURE_OUTPUT.format([
                    ("output_schema", (schema as TypeSchema).getOrThrow())
                ])
            }
            .getOrDefault({ => REACT_SYSTEM_PROMPT.trimAscii() })
    }

    static func buildReactPrompt(task: AgentTask): Array<Message> {
        PromptBuilder()
            .system(ReactPromptUtils.buildReactSystemPrompt(task))
            .tool(PromptBuilder.buildAgentToolsPrompt(task))
            .system(task.agent.systemPrompt)
            .retrieval(PromptBuilder.buildAgentRetrievalPrompt(task))
            .memory(PromptBuilder.buildAgentMemoryPrompt(task))
            .conversation(task.request.conversation)
            .buildFor(task.agent.executor, keepStepMessage: true)
    }

    static func buildReactSummarizePrompt(task: AgentTask): Array<Message> {
        let strBuilder = StringBuilder()
        for (msg in task.execution.stepMessages) {
            // Only add messages with tags, like [Action]
            if (msg.content.startsWith("[")) {
                strBuilder.append("${msg.content}\n")
            }
        }
        let sys = REACT_SUMMARIZE_SYSTEM_PROMPT.format(
            ("question", task.request.question),
            ("procedure", strBuilder.toString()),
            ("retrieval", PromptBuilder.buildAgentRetrievalPrompt(task)),
            ("systemPrompt", task.agent.systemPrompt),
            ("memory", PromptBuilder.buildAgentMemoryPrompt(task))
        ).trimAscii()
        return [
            Message.system(sys),
            Message.user(REACT_SUMMARIZE_USER_PROMPT.trimAscii())
        ]
    }
}
