/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.tool.common

import magic.core.agent.*
import magic.dsl.tool
import magic.core.model.ChatModel
import magic.model.ModelUtils
import magic.agent.BaseAgent
import magic.jsonable.*
import magic.tool.NativeFuncTool
import magic.log.LogUtils
import magic.parser.OutputParserUtils
import magic.prompt.Template
import magic.config.Config
import magic.core.message.ChatMessage
import magic.utils.newProcess

import std.io.StringReader
import std.fs.Path
import std.collection.{ArrayList, HashMap}
import encoding.json.JsonValue
@When[cjc_version < "0.56.4"]
import std.time.Duration

private let EXTRACT_ANSWER_USER_PROMPT = """
# Task

According the content in the section # Content, answer the user query.
If you cannot answer the query, just return Unknown

# Content
{content}
-----

# Query
{query}
"""

private let GENERATE_QUERY_TERM_SYSTEM_PROMPT = """
# Instruction

You are a wikipedia search assistant.
The wikipedia search engine accepts a term as the search input.
IMPORTANT: The term usually refers to the name of a specific entity, such as a person name, an animal name, the name of an event, etc.

Given a user query, your task is to generate the target search term.
First, you must understand what the search target is and rephrase the query.
Then, You need to think about what information you need to know in order answer the query and use this to generate search keywords.

Output the final answer with required format:
Wrap the rephrased query with ```query and ```.
Wrap the term with ```term and ```.

# Examples
Query: basketball origination
Rephrased Query: when did backetball originate?
Thought: To find out when basketball originated, we can check the information about basketball.
Result:
```query when did backetball originate? ```
```term backetball ```

Query: superman birthday
Rephrased Query: What's the birthday of superman?
Thought: To find out the birthday of superman, we can check the information about superman.
Result:
```query What's the birthday of superman? ```
```term superman ```

# Query
{query}
"""

@tool[
    description: "Do a Wikipedia search for query to get related content",
    parameters: {
        query: "The input query"
    }
]
public func wikiSearch(query: String): String {
    let wikiAgent = BaseAgent(
        name: "Wiki Agent",
        model: Config.defaultChatModel.getOrThrow({ => Exception("Default chat model is not set")}),
        executor: WikiExecutor()
    )
    return wikiAgent.chat(query)
}

class WikiExecutor <: AgentExecutor {
    public override func run(agent: Agent, request: AgentRequest): AgentResponse {
        let (query, term) = match (rephraseQuery(agent.model, request.question)) {
            case Some(tup) => tup
            case None => (request.question, request.question)
        }
        for (mode in [/*"summary",*/ "content"/*, "html"*/]) {
            let result = doWikiSearch(term, mode: mode)
            if (let Some(answer) <- extractAnswer(agent.model, query, result)) {
                return AgentResponse(answer)
            }
        }
        return AgentResponse("Nothing Found")
    }

    override public func asyncRun(agent: Agent, request: AgentRequest): AsyncAgentResponse {
        throw UnsupportedException()
    }

    private func doWikiSearch(query: String, mode!: String) {
        let scriptPath = Path(Config.externalScriptDir).join("wiki_search_impl.py")
        let args = ArrayList([
            scriptPath.toString(),
            "--query",
            query,
            "--mode",
            mode
        ])
        LogUtils.info("Wiki Agent", "[RUN] python ${String.join(args.toArray(), delimiter: " ")}")
        let subProcess = newProcess("python", args.toArray())
        let strReader = StringReader(subProcess.stdOut)
        let ret = strReader.readToEnd()
        let retCode = subProcess.wait(timeout: Duration.minute * 10)
        if (retCode != 0) {
            LogUtils.error("Run python script failed")
            return "Nothing Found"
        }
        return ret
    }

    private func rephraseQuery(model: ChatModel, query: String): Option<(String, String)> {
        let messages = [
            ChatMessage.system(GENERATE_QUERY_TERM_SYSTEM_PROMPT.format(
                ("query", query)
            ))
        ]
        return ModelUtils.makeChatGet("Wiki Agent", model, messages) { msg: ChatMessage =>
            let rephrasedQuery = OutputParserUtils.extractLastCode(msg.content, "query")
            let term = OutputParserUtils.extractLastCode(msg.content, "term")
            return match ((rephrasedQuery, term)) {
                case (Some(q), Some(t)) => return Some((q, t))
                case (None, Some(t)) => return Some((query, t)) // If the rephrased query non-exist, reuse the original query
                case _ => return None
            }
        }
    }

    private func extractAnswer(model: ChatModel, query: String, searchResult: String): Option<String> {
        let messages = [
            ChatMessage.user(EXTRACT_ANSWER_USER_PROMPT.format(
                ("content", searchResult),
                ("query", query)
            ))
        ]
        return ModelUtils.makeChatGet("Wiki Agent", model, messages) { msg: ChatMessage =>
            if (msg.content == "Unknown") {
                return None
            } else {
                return Some(msg.content)
            }
        }
    }
}