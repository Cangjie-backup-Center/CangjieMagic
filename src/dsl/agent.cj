/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.regex.Regex
import std.sort.SortExtension
import std.convert.Parsable
import std.collection.{ArrayList, HashMap, map, collectArrayList, collectArray}

struct StdioMcpAttr {
    StdioMcpAttr(
        let command: String,
        let args: Array<String>,
        let env: HashMap<String, Token>) {
    }
}

enum McpAttr {
    | Stdio(StdioMcpAttr)
    | Http(String)
    | Tools(Array<String>)

    static func parseStdioCommand(cmdArgs: String): Array<String> {
        // The regex matches:   letters | "..."         | '...'
        let regex = Regex(##"(?:[^\s"\']|"(?:\\.|[^"])*"|\'(?:\\.|[^\'])*\')+"##)
        let matcher = regex.matcher(cmdArgs)
        return (matcher.findAll() ?? []) |>
             map { md =>
                let s = md.matchStr()
                // Remove the quote marks if necessary
                if (s.startsWith('"') && s.startsWith('"') ||
                    s.startsWith("'") && s.startsWith("'")) {
                    return s[1..(s.size-1)]
                } else {
                    return s
                }
             } |>
             collectArray
    }

    /**
     * The first item is a string literal, followed by environment arguments,
     * like stdio("bash -c a.sh", PATH: "xxx", LD_PATH: "yyy", ...)
     */
    static func parseStdio(rawAttr: Tokens): McpAttr {
        if (rawAttr.size < 4 ||
            rawAttr[1].kind != TokenKind.LPAREN ||
            rawAttr[2].kind != TokenKind.STRING_LITERAL ||
            rawAttr[rawAttr.size-1].kind != TokenKind.RPAREN) {
            throw DslException("Invalid MCP stdio server config `${rawAttr}`")
        }
        let commandArgs = parseStdioCommand(rawAttr[2].value)
        // Reconstruct environment arguments as a map
        let mapAttr = Tokens([Token(TokenKind.LCURL)])
        // Skip the first four tokens: stdio ( "..." ,
        if (rawAttr.size > 4) {
            mapAttr.append(rawAttr[4..(rawAttr.size-1)])
        }
        mapAttr.append(Token(TokenKind.RCURL))
        let env = MapParser(mapAttr).parseMapOf(TokenKind.STRING_LITERAL)
        return McpAttr.Stdio(
            StdioMcpAttr(
                commandArgs[0],
                if (commandArgs.size > 1) { commandArgs[1..] } else { [] },
                env
            )
        )
    }

    /**
     * A single string literal, like http("https://...")
     */
    static func parseHttp(rawAttr: Tokens): McpAttr {
        let urls = ArrayParser(rawAttr[1..], beginSymbol: TokenKind.LPAREN, endSymbol: TokenKind.RPAREN)
            .parseArrayOf(TokenKind.STRING_LITERAL) |>
            map{ token: Token => token.value } |>
            collectArray
        if (urls.size != 1) {
            throw DslException("Invalid MCP http server config `${rawAttr}`")
        }
        return McpAttr.Http(urls[0])
    }

    /**
     * A list of tool names, like tools(ta, tb, tc, ...)
     */
    static func parseTools(rawAttr: Tokens): McpAttr {
        McpAttr.Tools(
            ArrayParser(rawAttr[1..], beginSymbol: TokenKind.LPAREN, endSymbol: TokenKind.RPAREN)
                .parseArrayOf(TokenKind.IDENTIFIER) |>
                map{ token: Token => token.value } |>
                collectArray
        )
    }

    /**
     * Deprecated syntax of specify MCP as a map
     */
    static func parse(rawMapAttr: HashMap<String, Tokens>): McpAttr {
        McpAttr.checkAttr(rawMapAttr)
        if (let Some(command) <- rawMapAttr.get("command")) {
            let args = ArrayParser(rawMapAttr.get("args") ?? quote([]))
                .parseArrayOf(TokenKind.STRING_LITERAL) |>
                map { token: Token => token.value } |>
                collectArray
            let env = MapParser(rawMapAttr.get("env") ?? quote({})).parseMapOf(TokenKind.STRING_LITERAL)
            return McpAttr.Stdio(StdioMcpAttr(command[0].value, args, env))
        } else {
            let url = rawMapAttr.get("url").getOrThrow()[0]
            return McpAttr.Http(url.value)
        }
    }

    static func checkAttr(rawMapAttr: HashMap<String, Tokens>): Unit {
        if (rawMapAttr.contains("command") && rawMapAttr.contains("url")) {
            throw DslException("MCP cannot have a command and a URL")
        } else if (!rawMapAttr.contains("command") && !rawMapAttr.contains("url")) {
            throw DslException("MCP must have a command or a URL")
        } else if (rawMapAttr.contains("command")) {
            let commandAttr = rawMapAttr["command"]
            if (commandAttr.size != 1 || commandAttr[0].kind != TokenKind.STRING_LITERAL) {
                throw DslException("MCP command has invalid value `${commandAttr}`")
            }
        } else if (rawMapAttr.contains("url")) {
            let urlAttr = rawMapAttr["url"]
            if (urlAttr.size != 1 || urlAttr[0].kind != TokenKind.STRING_LITERAL) {
                throw DslException("MCP url has invalid value `${urlAttr}`")
            }
        }
    }
}

class AgentAttr <: Attr {
    private static let ATTR_NAMES = [
        "model",
        "executor",
        "description",
        "temperature",
        "rag",
        "memory",
        "tools",
        "enableToolFilter",
        "mcp",
        "dump"
    ]

    AgentAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    static func parse(attrTokens: Tokens): AgentAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "agent",
            validKeys: AgentAttr.ATTR_NAMES
        )
        return AgentAttr(map)
    }

    var hasPrompt = false
    var solidPrompt = true

    prop model: String {
        get() { getString("model") ?? "deepseek:deepseek-chat" }
    }

    prop executor: String {
        get() {
            if (this.hasExecutionDSL) {
                return "dsl-executor"
            } else {
                getString("executor") ?? "react"
            }
        }
    }

    var hasExecutionDSL = false

    prop description: String {
        get() { getString("description") ?? "" }
    }

    prop temperature: Option<Float64> {
        get() {
            if (let Some(v) <- getLiteral("temperature")) {
                try {
                    return Float64.tryParse(v)
                } catch (_: IllegalArgumentException) {
                    throw DslException("Invalid temperature attribute")
                }
            }
            return 0.1
        }
    }

    private var _rag: Option<HashMap<String, Tokens>> = None

    /**
     * rag: {source:..., mode: ..., description: ...}
     */
    prop rag: HashMap<String, Tokens> {
        get() {
            if (let Some(v) <- _rag) { return v }

            let result = if (let Some(tokens) <- getTokens("rag")) {
                MapParser(tokens).parseMap()
            } else {
                HashMap<String, Tokens>()
            }
            _rag = Some(result)
            return result
        }
    }

    prop memory: Bool {
        get() { getBool("memory") }
    }

    /**
     * tools: [...]
     */
    prop tools: ArrayList<Tokens> {
        get() {
            if (let Some(tokens) <- getTokens("tools")) {
                return ArrayParser(tokens).parseArrayOfTokens()
            }
            return ArrayList<Tokens>()
        }
    }

    /**
     * mcp: [ {command: "...", args: [...]}]
     */
    private var _mcp: Option<Array<McpAttr>> = None
    prop mcp: Array<McpAttr> {
        get() {
            if (let Some(v) <- _mcp) {
                return v
            }
            if (let Some(tokens) <- getTokens("mcp")) {
                let result = ArrayList<McpAttr>()
                for (mcpTokens in ArrayParser(tokens).parseArrayOfTokens()) {
                    // The deprecated syntax of specifying the MCP as a map
                    if (mcpTokens[0].kind == TokenKind.LCURL) {
                        let rawMapAttr = MapParser(mcpTokens).parseMap()
                        result.append(McpAttr.parse(rawMapAttr))
                    } else {
                        let peekedToken = mcpTokens[0]
                        let mcpAttr = match (peekedToken.value) {
                            case "stdio" => McpAttr.parseStdio(mcpTokens)
                            case "http" => McpAttr.parseHttp(mcpTokens)
                            case "tools" => McpAttr.parseTools(mcpTokens)
                            case _ => throw DslException("Invalid syntax for MCP `${mcpTokens}`")
                        }
                        result.append(mcpAttr)
                    }
                }
                _mcp = result.toArray()
                return _mcp.getOrThrow()
            }
            return []
        }
    }

    prop enableToolFilter: Bool {
        get() { getBool("enableToolFilter") }
    }

    let internalTools = ArrayList<String>()
}

public macro agent(input: Tokens): Tokens {
    let agentAttr = AgentAttr()

    for (m in getChildMessages("tool")) {
        if (m.hasItem("internalTool")) {
            let name = m.getString("internalTool")
            agentAttr.internalTools.append(name)
        }
    }
    for (m in getChildMessages("prompt")) {
        if (m.hasItem("prompt:solid")) {
            agentAttr.solidPrompt = m.getBool("prompt:solid")
        }
        agentAttr.hasPrompt = true
    }
    for (m in getChildMessages("execution")) {
        if (m.hasItem("executionDSL")) {
            agentAttr.hasExecutionDSL = m.getBool("executionDSL")
        }
    }

    return transformAgent(input, agentAttr)
}

public macro agent(attr: Tokens, input: Tokens): Tokens {
    let agentAttr = AgentAttr.parse(attr)

    for (m in getChildMessages("tool")) {
        if (m.hasItem("internalTool")) {
            let name = m.getString("internalTool")
            agentAttr.internalTools.append(name)
        }
    }
    for (m in getChildMessages("prompt")) {
        if (m.hasItem("prompt:solid")) {
            agentAttr.solidPrompt = m.getBool("prompt:solid")
        }
        agentAttr.hasPrompt = true
    }
    for (m in getChildMessages("execution")) {
        if (m.hasItem("defineExecution")) {
            agentAttr.hasExecutionDSL = m.getBool("defineExecution")
        }
    }

    let content = transformAgent(input, agentAttr)
    if (agentAttr.dump) {
        printTokens(content)
    }
    return content
}

func transformAgent(input: Tokens, agentAttr: AgentAttr): Tokens {
    let decl = parseDecl(input)
    if (decl.isClassDecl()) {
        return transformAgentClass(decl.asClassDecl(), agentAttr)
    } else {
        throw DslException("@agent should be called on class declarations")
    }
}

/**
 * Transform the class as an agent class type
 */
func transformAgentClass(classDecl: ClassDecl, agentAttr: AgentAttr): Tokens {
    let modifier = classDecl.modifiers

    let genericTypeParamTokens = getGenericTypeParamsTokens(classDecl)
    let genericConstraintTokens = getGenericConstraintsTokens(classDecl)

    let classNameToken = classDecl.identifier
    let classDeclBody = classDecl.body.decls

    let systemPromptProp = buildAgentSystemPromptProp(classDecl, agentAttr)
    let modelProp = buildAgentModelProp(agentAttr)
    let executorProp = buildAgentExecutorProp(agentAttr)
    let toolManagerProp = buildAgentToolManagerProp(classDecl, agentAttr)
    let nameProp = buildAgentNameProp(classDecl)
    let descriptionProp = buildAgentDescriptionProp(agentAttr)
    let temperatureProp = buildAgentTemperatureProp(agentAttr)
    let retrieverProp = buildAgentRetrieverProp(agentAttr)
    let memoryProp = buildAgentMemoryProp(agentAttr)

    // Compose all `Tokens`
    return quote(
        $modifier class $classNameToken $genericTypeParamTokens $genericConstraintTokens <: UserDefinedAgent {
            $classDeclBody
            $systemPromptProp
            $modelProp
            $executorProp
            $nameProp
            $descriptionProp
            $temperatureProp
            $toolManagerProp
            $retrieverProp
            $memoryProp
        }
    )
}

//============================================================================================

func buildAgentSystemPromptProp(classDecl: ClassDecl, agentAttr: AgentAttr) {
    if (!agentAttr.hasPrompt) {
        return quote (
            private var __SYSTEM_PROMPT__: String = ""
            public override mut prop systemPrompt: String {
                get() { return __SYSTEM_PROMPT__ }
                set(v) { __SYSTEM_PROMPT__ = v }
            }
        )
    }
    return quote(
        private var __SYSTEM_PROMPT__: String = ""
        private var __IS_SYSTEM_PROMPT_INIT__ = false
        private var __IS_SYSTEM_PROMPT_SOLID__ = $(newLiteralToken(agentAttr.solidPrompt))
        public override mut prop systemPrompt: String {
            get() {
                if (__IS_SYSTEM_PROMPT_INIT__ && __IS_SYSTEM_PROMPT_SOLID__) {
                    return __SYSTEM_PROMPT__
                }
                __IS_SYSTEM_PROMPT_INIT__ = true
                __SYSTEM_PROMPT__ = $(newIdentifierToken(SYSTEM_PROMPT_FUNC))()
                return __SYSTEM_PROMPT__
            }
            set(v) {
                __IS_SYSTEM_PROMPT_INIT__ = true
                __IS_SYSTEM_PROMPT_SOLID__ = true
                __SYSTEM_PROMPT__ = v
            }
        }
    )
}

//============================================================================================

func buildAgentNameProp(classDecl: ClassDecl) {
    let tokens = newLiteralToken(classDecl.identifier.value)
    return quote(
        public override prop name: String {
            get() { $tokens }
        }
    )
}

//============================================================================================

func buildAgentModelProp(agentAttr: AgentAttr): Tokens {
    let tokens = newLiteralToken(agentAttr.model)
    return quote(
        private var __IS_MODEL_INIT__ = false
        private var __MODEL__: Option<ChatModel> = None
        public override mut prop model: ChatModel {
            get() {
                if (!__IS_MODEL_INIT__) {
                    __MODEL__ = ModelManager.createChatModel($tokens, temperature: this.temperature)
                    __IS_MODEL_INIT__ = true
                }
                return __MODEL__.getOrThrow()
            }
            set(v) {
                __IS_MODEL_INIT__ = true
                __MODEL__ = v
            }
        }
    )
}

//============================================================================================

func buildAgentExecutorProp(agentAttr: AgentAttr): Tokens {
    let tokens = newLiteralToken(agentAttr.executor)
    return quote(
        private var __IS_EXECUTOR_INIT__ = false
        private var __EXECUTOR__: Option<AgentExecutor> = None
        public override mut prop executor: AgentExecutor {
            get() {
                if (!__IS_EXECUTOR_INIT__) {
                    __EXECUTOR__ = AgentExecutorManager.create($tokens)
                    __IS_EXECUTOR_INIT__ = true
                }
                return __EXECUTOR__.getOrThrow()
            }
            set(v) {
                __EXECUTOR__ = v
                __IS_EXECUTOR_INIT__ = true
            }
        }
    )
}

//============================================================================================

func buildAgentDescriptionProp(agentAttr: AgentAttr): Tokens {
    let tokens = newLiteralToken(agentAttr.description)
    return quote(
        public override prop description: String {
            get() { $tokens }
        }
    )
}

//============================================================================================

func buildAgentTemperatureProp(agentAttr: AgentAttr): Tokens {
    let tokens = if (let Some(t) <- agentAttr.temperature) {
        let token = newLiteralToken(t)
        quote(Some($token))
    } else {
        quote(None)
    }
    return quote(
        private var __TEMPERATURE__ = $tokens
        public override mut prop temperature: Option<Float64> {
            get() { __TEMPERATURE__ }
            set(v) { __TEMPERATURE__ = v }
        }
    )
}

//============================================================================================

private enum RagSource {
    | Path(String)
    | Expr(Tokens)
}

private struct RagAttr {
    RagAttr(
        let source: RagSource,
        let mode: Option<String>,
        let description: Option<String>) { }

    static func parse(rawAttr: HashMap<String, Tokens>): RagAttr {
        RagAttr.checkAttr(rawAttr)
        let sourceAttr: Tokens = rawAttr.get("source").getOrThrow()
        let source = if (sourceAttr.size == 1 && sourceAttr[0].kind == TokenKind.STRING_LITERAL) {
            RagSource.Path(sourceAttr[0].value)
        } else {
            RagSource.Expr(sourceAttr)
        }

        let mode = (rawAttr.get("mode")?[0])?.value
        let desc = (rawAttr.get("description")?[0])?.value
        return RagAttr(source, mode, desc)
    }

    static func checkAttr(rawAttr: HashMap<String, Tokens>): Unit {
        if (!rawAttr.contains("source")) {
            throw DslException("Rag must has a source")
        }
        if (rawAttr.contains("mode")) {
            let modeAttr = rawAttr["mode"]
            if (modeAttr.size != 1 || modeAttr[0].kind != TokenKind.STRING_LITERAL) {
                throw DslException("Rag mode has invalid value `${modeAttr}`")
            }
        }
        if (rawAttr.contains("description")) {
            let descAttr = rawAttr["description"]
            if (descAttr.size != 1 || descAttr[0].kind != TokenKind.STRING_LITERAL) {
                throw DslException("Rag description has invalid value `${descAttr}`")
            }
        }
    }
}

func buildAgentRetrieverProp(agentAttr: AgentAttr): Tokens {
    let retrieverInitTokens = if (agentAttr.rag.isEmpty()) {
        quote(None)
    } else {
        let ragAttr = RagAttr.parse(agentAttr.rag)
        let mode = if (let Some(v) <- ragAttr.mode) {
            if (v == "static") {
                quote(RetrieverMode.Static)
            } else {
                quote(RetrieverMode.Dynamic)
            }
        } else {
            quote(None)
        }
        let desc = if (let Some(v) <- ragAttr.description) {
            quote($(newLiteralToken(v)))
        } else {
            quote(None)
        }
        match (ragAttr.source) {
            case RagSource.Expr(expr) =>
                quote(RetrieverUtils.createRetriever(this, $expr, $mode, $desc))
            case RagSource.Path(p) =>
                let path = newLiteralToken(p)
                quote(RetrieverUtils.createRetriever(this, $path, $mode, $desc))
        }
    }

    return quote(
        private var __IS_RETRIEVER_INIT__ = false
        private var __RETRIEVER__: Option<Retriever> = None
        public override mut prop retriever: Option<Retriever> {
            get() {
                if (!__IS_RETRIEVER_INIT__) {
                    __RETRIEVER__ = $retrieverInitTokens
                    __IS_RETRIEVER_INIT__ = true
                    if (let Some(rt) <- __RETRIEVER__) {
                        if (rt.mode == RetrieverMode.Dynamic) {
                            this.toolManager.addTool(RetrieverTool(rt))
                        }
                    }
                }
                return __RETRIEVER__
            }
            set(v) {
                // If the last retriever is of dynamic mode, del it
                if (let Some(rt) <- __RETRIEVER__) {
                    if (rt.mode == RetrieverMode.Dynamic) {
                        this.toolManager.delTool(RetrieverTool(rt))
                    }
                }
                // If the assigned retriever is of dynamic mode, add it
                if (let Some(rt) <- v) {
                    if (rt.mode == RetrieverMode.Dynamic) {
                        this.toolManager.addTool(RetrieverTool(rt))
                    }
                }
                __RETRIEVER__ = v
                __IS_RETRIEVER_INIT__ = true
            }
        }
    )
}

//============================================================================================

func buildAgentMemoryProp(agentAttr: AgentAttr): Tokens {
    let tokens = if (agentAttr.memory) {
        quote(Some(ShortMemory()))
    } else {
        quote(None)
    }
    return quote(
        private var __IS_MEMORY_INIT__ = false
        private var __MEMORY__: Option<Memory> = None
        public override mut prop memory: Option<Memory> {
            get() {
                if (!__IS_MEMORY_INIT__) {
                    __MEMORY__ = $tokens
                    __IS_MEMORY_INIT__ = true
                }
                return __MEMORY__
            }
            set(v) {
                __MEMORY__ = v
                __IS_MEMORY_INIT__ = true
            }
        }
    )
}

//============================================================================================

func buildAgentToolManagerProp(classDecl: ClassDecl, agentAttr: AgentAttr) {
    let addTools = Tokens()
    // Internal tools
    for (name in agentAttr.internalTools) {
        let funcName = newIdentifierToken(name)
        addTools.append(
            quote(
                tm.addTool($funcName)
            )
        )
    }
    // Global tools
    for (toolTks in agentAttr.tools) {
        addTools.append(
            quote(
                tm.addTool($toolTks)
            )
        )
    }
    // The retriever may be a tool
    addTools.append(
        quote(
            if (let Some(rt) <- this.retriever) {
                // If retriever is of dynamic mode, add it as a tool
                if (rt.mode == RetrieverMode.Dynamic) {
                    tm.addTool(RetrieverTool(rt))
                }
            }
        )
    )
    // MCP tools
    for (i in 0..agentAttr.mcp.size) {
        match (agentAttr.mcp[i]) {
            case McpAttr.Stdio(mcpAttr) =>
                let command = newLiteralToken(mcpAttr.command)
                let args = joinTokens(newArrayOfLiteralToken(mcpAttr.args), Token(TokenKind.COMMA))
                let env = joinTokens(
                    mcpAttr.env.iterator() |>
                        map { tuple: (String, Token) =>
                            let key = newLiteralToken(tuple[0])
                            let value = tuple[1]
                            return quote( ($key, $value) )
                        } |>
                        collectArrayList,
                    Token(TokenKind.COMMA))
                let client = newIdentifierToken("client_${i}")
                addTools.append(
                    quote(
                        let $client = StdioMCPClient($command, [$args], env: [$env])
                        tm.addTools($client.getTools())
                    )
                )
            case McpAttr.Http(_url) =>
                let url = newLiteralToken(_url)
                let client = newIdentifierToken("client_${i}")
                addTools.append(
                    quote(
                        let $client = SseMCPClient($url)
                        tm.addTools($client.getTools())
                    )
                )
            case McpAttr.Tools(_tools) =>
                let tools = joinTokens(newArrayOfIdentifierToken(_tools), Token(TokenKind.COMMA))
                addTools.append(
                    quote(
                        tm.addTools([$tools])
                    )
                )
        }
    }

    return quote(
        private var __TOOL_MANAGER__: Option<ToolManager> = None
        public override prop toolManager: ToolManager {
            get() {
                match (__TOOL_MANAGER__) {
                    case Some(tm) => return tm
                    case None =>
                        let tm = SmartToolManager([], enableFilter: $(newLiteralToken(agentAttr.enableToolFilter)))

                        $addTools

                        __TOOL_MANAGER__ = Some(tm)
                        return tm
                }
            }
        }
    )
}
