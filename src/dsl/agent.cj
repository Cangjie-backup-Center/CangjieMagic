/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.sort.SortExtension
import std.convert.Parsable
import std.collection.{ArrayList, HashMap}
import std.ast.*

class AgentAttr <: Attr {
    private static let ATTR_NAMES = [
        "model",
        "executor",
        "description",
        "temperature",
        "rag",
        "memory",
        "tools",
        "enableToolSearch",
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
        get() { getString("executor") ?? "react" }
    }

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
    private var _mcp: Option<Array<HashMap<String, Tokens>>> = None
    prop mcp: Array<HashMap<String, Tokens>> {
        get() {
            if (let Some(v) <- _mcp) {
                return v
            }
            if (let Some(tokens) <- getTokens("mcp")) {
                let result = ArrayList<HashMap<String, Tokens>>()
                for (mcpTokens in ArrayParser(tokens).parseArrayOfTokens()) {
                    result.append(MapParser(mcpTokens).parseMap())
                }
                _mcp = result.toArray()
                return _mcp.getOrThrow()
            }
            return []
        }
    }

    prop enableToolSearch: Bool {
        get() { getBool("enableToolSearch") }
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
        $modifier class $classNameToken $genericTypeParamTokens $genericConstraintTokens <: AgentProxy {
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

private struct McpAttr {
    McpAttr(
        let command: String,
        let args: ArrayList<Token>) { }

    static func parse(rawAttr: HashMap<String, Tokens>): McpAttr {
        McpAttr.checkAttr(rawAttr)
        let command: String = rawAttr.get("command").getOrThrow()[0].value
        let args = ArrayParser(rawAttr.get("args") ?? Tokens()).parseArrayOf(TokenKind.STRING_LITERAL)
        return McpAttr(command, args)
    }

    static func checkAttr(rawAttr: HashMap<String, Tokens>): Unit {
        if (!rawAttr.contains("command")) {
            throw DslException("MCP must has a command")
        }
        let commandAttr = rawAttr["command"]
        if (commandAttr.size != 1 || commandAttr[0].kind != TokenKind.STRING_LITERAL) {
            throw DslException("MCP command has invalid value `${commandAttr}`")
        }
    }
}

func buildAgentToolManagerProp(classDecl: ClassDecl, agentAttr: AgentAttr) {
    let addTools = Tokens()
    // Global tools
    for (toolTks in agentAttr.tools) {
        addTools.append(
            quote(
                tm.addTool($toolTks)
            )
        )
    }
    // Internal tools
    for (name in agentAttr.internalTools) {
        let funcName = newIdentifierToken(name)
        addTools.append(
            quote(
                tm.addTool($funcName)
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
        let mcpRawAttr = agentAttr.mcp[i]
        let mcpAttr = McpAttr.parse(mcpRawAttr)
        let command = newLiteralToken(mcpAttr.command)
        let args = joinTokens(mcpAttr.args, Token(TokenKind.COMMA))
        let client = newIdentifierToken("client_${i}")
        addTools.append(
            quote(
                let $client = MCPClient($command, [$args])
                tm.addTools($client.getTools())
            )
        )
    }

    return quote(
        private var __TOOL_MANAGER__: Option<ToolManager> = None
        public override prop toolManager: ToolManager {
            get() {
                match (__TOOL_MANAGER__) {
                    case Some(tm) => return tm
                    case None =>
                        let tm = SimpleToolManager([], enableToolSearch: $(newLiteralToken(agentAttr.enableToolSearch)))

                        $addTools

                        __TOOL_MANAGER__ = Some(tm)
                        return tm
                }
            }
        }
    )
}
