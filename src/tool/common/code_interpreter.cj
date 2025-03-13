/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool.common

import magic.dsl.tool
import magic.jsonable.*
import magic.tool.NativeFuncTool
import magic.log.LogUtils
import magic.config.Config
import magic.core.message.ChatMessage
import magic.model.ModelUtils
import magic.prompt.Template
import magic.parser.OutputParserUtils
import magic.utils.{newProcess, saveTempFile, removeIfExists}

import std.io.StringReader
import std.collection.{ArrayList, HashMap}
@When[cjc_version < "0.56.4"]
import std.time.Duration
import encoding.json.JsonValue

private let MAX_CODE_FIX_LOOP = 3

/**
 * The status of running code
 */
private enum Status {
    | Okay(String) // Content of stdout
    | Fail(String) // Error message
}

private func runCode(code: String): Status {
    // Save code as a script file
    let tempPath = saveTempFile(Config.codeInterpreterDir, code)
    let args = ArrayList([tempPath.toString()])
    LogUtils.info("Code Interpreter: [Code] ${code}")
    LogUtils.info("Code Interpreter: [RUN] python ${String.join(args.toArray(), delimiter: " ")}")
    let subProcess = newProcess("python", args.toArray())
    let stdOutReader = StringReader(subProcess.stdOut)
    let stdErrReader = StringReader(subProcess.stdErr)
    let stdOutContent = stdOutReader.readToEnd()
    let stdErrContent = stdErrReader.readToEnd()
    let retCode = subProcess.wait(timeout: Duration.minute * 10)
    if (!Config.saveCodeInterpreter) {
        removeIfExists(tempPath)
    }
    if (retCode != 0) {
        LogUtils.error("Run python code failed\n${stdErrContent}")
        return Status.Fail("Run Python code failed\n${stdErrContent}")
    }
    return Status.Okay(stdOutContent)
}

private let CODE_FIX_SYSTEM_PROMOT = """
# Instruction
You are a program fixer.
According to the error message, fix the code.
Wrap the output by ```python and ```, like:
```python
...
```

You must first follow the THOUGHT PROTOCOL to engage in a deliberate thought process before forming a response.
The reasoning is distinct from its response. It represents the internal result-checking process and MUST be expressed in multiline code blocks using thinking header:
```think
This is where internal reasoning would go
```

This internal reasoning should:

- Be conducted in an unstructured, natural manner, resembling a stream-of-consciousness.
- Break down complex tasks into manageable steps.
- Explore multiple interpretations, approaches, and perspectives.
- Verify the logic and factual correctness of ideas.

This is a non-negotiable requirement.

# THOUGHT PROTOCOL FOR THOUGHT PROCESS

1. Initial Engagement
  - Understand the original incorrect code
2. Analysis
  - Identify the root cause of the code error according to the error message
3. Exploration of Fixing
  - Explore approaches to fixing the code

# Incorrect Code

```python
{code}
```

# Error Message

```error_message
{error_msg}
```

Now, fix the code:
"""

private func fixCode(code: String, errorMsg: String): String {
    let messages = [
        ChatMessage.system(CODE_FIX_SYSTEM_PROMOT.format(
            ("code", code),
            ("error_msg", errorMsg)
        ))
    ]
    let model = Config.defaultChatModel.getOrThrow()
    let fixedCode = ModelUtils.makeChatGet("Code Interpreter", model, messages) { msg: ChatMessage =>
        return OutputParserUtils.extractLastCode(msg.content, "python")
    }
    return fixedCode.getOrThrow({ => Exception("Fail to get model response") })
}

@tool[
    description: """
    Evaluates python code in a sandbox environment.
    The environment resets on every execution.
    You must send the whole script code every time and print your outputs.
    Script should be pure python code that can be evaluated.
    It should be in python format NOT markdown. The code should NOT be wrapped in backticks.
    The code can import the Python stdlib, but it cannot import other libraries.
    """,
    parameters: {
        code: "The python code to execute. This argument is a string literal wraped by two \" marks. Never pass a multi-line string literal as the argument"
    },
    examples: [
        "codeInterperter(\"print(1+2)\")"
    ]
]
public func codeInterperter(code: String): String {
    // Handle escaped chars in the code
    var currCode = code.replace("\\n", "\n")
    for (_ in 0..MAX_CODE_FIX_LOOP) {
        match (runCode(currCode)) {
            case Status.Okay(content) =>
                if (content.isEmpty()) {
                    currCode = fixCode(currCode, "There are no result outputs")
                } else {
                    return content
                }
            case Status.Fail(errorMsg) =>
                currCode = fixCode(currCode, errorMsg)
        }
    }
    return "Run code failued"
}