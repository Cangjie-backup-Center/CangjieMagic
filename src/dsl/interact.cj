/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*

class InteractAttr <: Attr {
    private static let ATTR_NAMES = [
        "agent",
        "request",
        "dump"
    ]

    InteractAttr(map: AttrMap) { super(map) }

    init() { super(AttrMap()) }

    static func parse(attrTokens: Tokens): InteractAttr {
        let map = AttrParser(attrTokens).parseAttr(
            macroName: "interact",
            validKeys: InteractAttr.ATTR_NAMES
        )
        return InteractAttr(map)
    }

    prop agent: Tokens {
        get() {
            getTokens("agent").getOrThrow({ =>
                DslException("@interact must have an `agent` attribute")
            })
        }
    }

    prop request: Tokens {
        get() {
            getTokens("request").getOrThrow({ =>
                DslException("@interact must have an `request` attribute")
            })
        }
    }
}

public macro interact(attrTokens: Tokens, input: Tokens): Tokens {
    let attr = InteractAttr.parse(attrTokens)
    let content = transformInteract(input, attr)
    if (attr.dump) {
        printTokens(content)
    }
    return content
}

/**
 * Transform
 * @interact[agent: <expr>, request: <expr>](
 *   case evt: ABCEvent => ...
 *   case evt: XYZEvent => ...
 * )
 * as
 * { =>
 *    let manager = EventHandlerManager()
 *    manager.addHandler({evt: ABCEvent => ... })
 *    manager.addHandler({evt: XYZEvent => ... })
 *    return interaction(agent, request: <expr>, manager: manager)
 * }()
 */
func transformInteract(input: Tokens, attr: InteractAttr): Tokens {
    let matchExpr = try {
        // Wrap the input tokens as a match expr for easily parsing
        let expr = parseExpr(quote(match(_fake_var) { $input }))
        (expr as MatchExpr).getOrThrow({ =>
            DslException("Failed to parse @interact body: \n```\n${input.toString()}```")
        })
    } catch (_: ParseASTException) {
        throw DslException("Failed to parse @interact body: \n```\n${input.toString()}```")
    }
    let body = quote(
        let manager = EventHandlerManager()
    )
    for (caseClause in matchExpr.matchCases) {
        checkInteractCase(caseClause)
        body.append(quote(
            manager.addHandler({
                $( caseClause.patterns[0] ) => $( caseClause.block )
            })
        ))
    }
    return quote(
        {=> $body
            return interaction($(attr.agent), request: $(attr.request), manager: manager)
        }()
    )
}

private func checkInteractCase(caseClause: MatchCase): Unit {
    if (caseClause.patterns.size != 1) {
        throw DslException("Only one pattern is allowed in @interact case clause, but got ${caseClause.patterns.size}")
    }
    let pattern = (caseClause.patterns[0] as TypePattern).getOrThrow({ =>
        DslException("Only type patterns are allowed in @interact case clause, but got ${caseClause.patterns[0].toTokens()}")
    })
    if (!(pattern.pattern is VarPattern)) {
        throw DslException("Only variable pattern (in type patterns) are allowed in @interact case clause, but got ${pattern.pattern.toTokens()}")
    }
    let typeOfPattern = (pattern.patternType as RefType).getOrThrow({ =>
        DslException("Only RefType (in type patterns) are allowed in @interact case clause, but got ${pattern.patternType.toTokens()}")
    })
    if (!typeOfPattern.identifier.value.endsWith("Event")){
        throw DslException("Invalid Event type ${typeOfPattern.identifier.value} is used in @interact case clause}")
    }
}