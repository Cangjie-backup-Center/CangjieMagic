/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.ast.*
import std.collection.{ArrayList, map, collectArrayList}
import std.fs.File

/**
 * For each `@template` function, we transform string literals in its function body,
 * and replace it as an object that implements `operator func()`.
 * For example,
 * ```
 * @template
 * func foo(a: String, b: String) { ... }
 * ```
 * will be transformed as
 * ```
 * func foo_template__(...) { ... }
 * ```
 */
func transformTemplate(input: Tokens): Tokens {
    // Step 1: transform the function body
    let tokens = transformStringLiteral(input, isDecl: true)
    let decl: Decl = parseDecl(tokens)
    if (decl.isFuncDecl()) {
        let funcDecl = decl.asFuncDecl()
        // Step 2: transform the template function
        return transformTemplateFunc(funcDecl)
    } else {
        eprintln("@template should be called on function declarations")
        return input
    }
}

/**
 * 1. Find all independent string literals, which are top-level STRING_LITERAL tokens
 *    Since we cannot mutate AST in-place, we collect positions of these tokens
 * 2. Replace all these string literals (tokens) with a call of `prompt_builder`
 * 3. There is a corner case where we treat top-level function calling with dollar-identifiers like `$id(...)`
 *    as a syntax sugar of `"${id(...)}"` where `id` is a prompt function.
 */
func transformStringLiteral(input: Tokens, isDecl!: Bool): Tokens {
    // Desugar `$id(...)` as "id(...)"
    let tokens = transformTemplateFuncCall(input)
    let node: Node = if (isDecl) {
        parseDecl(tokens)
    } else {
        parseExpr(tokens)
    }
    let collector = collectIndependentStringLiteral(node)
    let transformedTokens = Tokens()
    for (token in tokens) {
        if ((token.kind == TokenKind.STRING_LITERAL ||
            token.kind == TokenKind.MULTILINE_STRING) &&
            collector.isIndependentStringLiteral(token)) {
            transformedTokens.append(quote(
                $PROMPT_BUILDER.append($token)
                $token
            ))
        } else {
            transformedTokens.append(token)
        }
    }
    return transformedTokens
}

/**
 * We treat the function call with a dollar-identifier like `$id(...)`
 * as a syntax sugar of `"${id(...)}"` where `id` is a prompt function.
 */
func transformTemplateFuncCall(input: Tokens): Tokens {
    let transformedTokens = Tokens()
    var currPos = 0
    while (currPos < input.size) {
        let token = input[currPos]
        if (token.kind == TokenKind.DOLLAR_IDENTIFIER) {
            let (argTokens, endPos) = extractFuncArguments(input, currPos)
            // The new function identifier should remove the `$` prefix
            let newToken = Token(TokenKind.IDENTIFIER, token.value[1..token.value.size])
            // Build the function call
            let callTokens = quote($newToken($argTokens))
            // Wrap it in a string literal
            let strLit = "\${" + callTokens.toString() + "}"
            transformedTokens.append(Token(TokenKind.STRING_LITERAL, strLit))
            currPos = endPos
        } else {
            transformedTokens.append(token)
        }
        currPos += 1
    }
    return transformedTokens
}

func extractFuncArguments(input: Tokens, begin: Int64): (Tokens, Int64) {
    var currPos = begin
    // For simplicity, we assume currPos is always valid
    let nextToken = input[currPos + 1]
    currPos += 1
    if (nextToken.kind != TokenKind.LPAREN) {
        throw DslException("A LPAREN is expected")
    }
    currPos += 1

    let result = Tokens()
    while (currPos < input.size && input[currPos].kind != TokenKind.RPAREN) {
        result.append(input[currPos])
        currPos += 1
    }
    return (result, currPos)
}

/**
 * Rename the template function
 * and insert a `StringBuilder` to the function body.
 */
func transformTemplateFunc(funcDecl: FuncDecl): Tokens {
    // Make sure that there is no `return`s in the template function.
    if (hasReturnExpr(funcDecl)) {
        eprintln("Template functions cannot contain return expressions.")
        return Tokens()
    }
    let modifier = funcDecl.modifiers
    let name = funcDecl.identifier
    let newName = newIdentifierToken("${name.value}${TEMPLATE_FUNC_NAME_POSTFIX}")
    let paramList = funcDecl.funcParams
    let retType = checkFuncRetString(funcDecl)
    let funcBody = funcDecl.block.nodes
    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)

    return quote (
        $modifier func $newName $genericTypeParam ( $paramList ): $retType $genericConstraint {
            let $PROMPT_BUILDER = StringBuilder()
            $funcBody
            return $PROMPT_BUILDER.toString()
        }
    )
}

/**
 * Check whether the return type of a functions is String.
 */
func checkFuncRetString(funcDecl: FuncDecl): Token {
    try {
        let ty = funcDecl.declType
        if (!ty.isRefType()) {
            eprintln("Function ${funcDecl.identifier.value} should return String")
            return Token(TokenKind.IDENTIFIER, "String")
        }
        let refTy: RefType = ty.asRefType()
        let id = refTy.identifier
        if (!(id.kind == TokenKind.IDENTIFIER && id.value == "String")) {
            eprintln("Prompt function should return String")
        }
        return Token(TokenKind.IDENTIFIER, "String")
    } catch (_: ASTException) {
        return Token(TokenKind.IDENTIFIER, "String")
    }
}

/**
 * Concatenate tokens of the included file and tokens of the function body
 */
func concatPromptTokens(input: Tokens, includeTokens: Tokens): Tokens {
    let funcDecl: FuncDecl = parseFuncDecl(input)
    let modifierTokens = funcDecl.modifiers
    let nameTokens = funcDecl.identifier
    let paramListTokens = funcDecl.funcParams
    let retTypeTokens = getRetTypeTokens(funcDecl)
    let funcBodyTokens = funcDecl.block
    let genericTypeParamTokens = getGenericTypeParamsTokens(funcDecl)
    let genericConstraintTokens = getGenericConstraintsTokens(funcDecl)

    return quote (
        $modifierTokens func $nameTokens $genericTypeParamTokens $paramListTokens: $retTypeTokens $genericConstraintTokens {
            $includeTokens
            $funcBodyTokens
        }
    )
}

func checkAllParamOfStringType(funcDecl: FuncDecl): Bool {
    let funcParamList: ArrayList<FuncParam> = funcDecl.funcParams
    // Iterate all parameters.
    for (param in funcParamList) {
        let paramTy = param.paramType
        if (!isString(paramTy)) {
            return false
        }
    }
    return true
}

func isString(ty: TypeNode): Bool {
    if (!ty.isRefType()) {
        return false
    }
    let refTy = ty.asRefType()
    let name = refTy.identifier
    return name.kind == TokenKind.IDENTIFIER && name.value == "String"
}

func getFuncParamNameList(funcDecl: FuncDecl): ArrayList<String> {
    let funcParamList: ArrayList<FuncParam> = funcDecl.funcParams
    let paramNames = ArrayList<String>()
    // Iterate all parameters.
    for (param in funcParamList) {
        let token = param.identifier
        paramNames.append(token.value)
    }
    return paramNames
}

func getFuncParamSize(funcDecl: FuncDecl): Int64 {
    return funcDecl.funcParams.size
}