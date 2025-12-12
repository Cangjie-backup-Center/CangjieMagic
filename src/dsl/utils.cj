/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package magic.dsl

import std.collection.{ArrayList, map, collectArray}
import std.ast.*
@When[cjc_version >= "1.0.0"]
internal import std.fs.exists

import std.fs.{File, OpenMode}
import std.io.StringReader

@When[cjc_version < "1.0.0"]
protected func exists(path: String): Bool {
    return File.exists(path) || Directory.exists(path)
}

protected func readFile(path: String): String {
    try (file = File(path, OpenMode.Read)) {
        let reader = StringReader(file)
        return reader.readToEnd()
    }
    throw UnsupportedException()
}

protected func newIdentifierToken(id: String): Token {
    return Token(TokenKind.IDENTIFIER, id)
}

protected func newArrayOfIdentifierToken(ids: Array<String>): Array<Token> {
    let result = ArrayList<Token>()
    for (id in ids) {
        result.add(newIdentifierToken(id))
    }
    return result.toArray()
}

protected func newLiteralToken(v: Bool): Token {
    return Token(TokenKind.BOOL_LITERAL, v.toString())
}

protected func newLiteralToken(v: Int64): Token {
    return Token(TokenKind.INTEGER_LITERAL, v.toString())
}

protected func newLiteralToken(v: String): Token {
    if (v.contains("\n")) {
        return Token(TokenKind.MULTILINE_STRING, v)
    } else {
        return Token(TokenKind.STRING_LITERAL, v)
    }
}

protected func newArrayOfLiteralToken(values: Array<String>): Array<Token> {
    let result = ArrayList<Token>()
    for (v in values) {
        result.add(newLiteralToken(v))
    }
    return result.toArray()
}

protected func newMultilineStringLiteralToken(v: String): Token {
    return Token(TokenKind.MULTILINE_STRING, v)
}

protected func newLiteralToken(v: Float64): Token {
    return Token(TokenKind.FLOAT_LITERAL, v.toString())
}

protected func concatTokens(tokensList: ArrayList<Tokens>): Tokens {
    var ret: Tokens = Tokens()
    for (tokens in tokensList) {
        ret = ret + tokens
    }
    return ret
}

protected func joinTokens(tokensList: Array<Tokens>, separator: Token): Tokens {
    if (tokensList.isEmpty()) {
        return Tokens()
    } else if (tokensList.size == 1) {
        return tokensList[0]
    } else {
        var ret = tokensList[0]
        for (i in 1..tokensList.size) {
            ret = ret + separator + tokensList[i]
        }
        return ret
    }
}

protected func joinTokens(tokensList: ArrayList<Tokens>, separator: Token): Tokens {
    return joinTokens(tokensList.toArray(), separator)
}

protected func joinTokens(tokenList: Array<Token>, separator: Token): Tokens {
    if (tokenList.isEmpty()) {
        return Tokens()
    } else if (tokenList.size == 1) {
        return Tokens() + tokenList[0]
    } else {
        var ret = Tokens() + tokenList[0]
        for (i in 1..tokenList.size) {
            ret = ret + separator + tokenList[i]
        }
        return ret
    }
}

protected func joinTokens(tokenList: ArrayList<Token>, separator: Token): Tokens {
    return joinTokens(tokenList.toArray(), separator)
}

protected func isTokenOfKind(token: Token, kinds: Array<TokenKind>): Bool {
    for (kind in kinds) {
        if (token.kind == kind) {
            return true
        }
    }
    return false
}

protected func isTokenLiteral(token: Token): Bool {
    return isTokenOfKind(token, [
        TokenKind.STRING_LITERAL,  TokenKind.MULTILINE_STRING,
        TokenKind.INTEGER_LITERAL, TokenKind.BOOL_LITERAL,
        TokenKind.FLOAT_LITERAL
    ])
}

protected func isTokenStringLiteral(token: Token): Bool {
    return isTokenOfKind(token, [
        TokenKind.STRING_LITERAL,  TokenKind.MULTILINE_STRING
    ])
}

protected func printTokens(tokens: Tokens): Unit {
    let s = tokens.toString()
    println(s)
}

protected func getGenericTypeParamsTokens(decl: Decl): Tokens {
    try {
        let generic = decl.genericParam
        return generic.toTokens()
    } catch(_: ASTException) {
        return Tokens()
    }
}

protected func getGenericConstraintsTokens(decl: Decl): Tokens {
    let tokens = Tokens()
    for (c in decl.genericConstraint) {
        tokens.append(c.toTokens())
    }
    return tokens
}

/**
 * Check whether the return type of a function is String.
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
            eprintln("Function ${funcDecl.identifier.value} should return String")
        }
        return Token(TokenKind.IDENTIFIER, "String")
    } catch (_: ASTException) {
        return Token(TokenKind.IDENTIFIER, "String")
    }
}

//=====================================================================
// Auxiliary protected functions to help modify protected function decls
//=====================================================================
protected func renameFunction(funcDecl: FuncDecl, newName: Token): Tokens {
    let modifier = funcDecl.modifiers
    let paramList = funcDecl.funcParams
    let retType: TypeNode = try {
        funcDecl.declType
    } catch (_: ASTException) {
        PrimitiveType(quote(Unit))
    }
    let funcBody = funcDecl.block
    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)

    return quote (
        $modifier func $newName $genericTypeParam ( $paramList ): $retType $genericConstraint
            $funcBody
    )
}

protected func renameFunctionAsOperator(funcDecl: FuncDecl): Tokens {
    let modifier = funcDecl.modifiers
    let paramList = funcDecl.funcParams
    let retType: TypeNode = try {
        funcDecl.declType
    } catch (_: ASTException) {
        PrimitiveType(quote(Unit))
    }
    let funcBody = funcDecl.block
    let genericTypeParam = getGenericTypeParamsTokens(funcDecl)
    let genericConstraint = getGenericConstraintsTokens(funcDecl)

    return quote (
        $modifier operator func() $genericTypeParam ( $paramList ): $retType $genericConstraint
            $funcBody
    )
}

/**
 * Get the names of all parameters in a function declaration.
 */
protected func getFuncParamNames(funcDecl: FuncDecl): Array<String> {
    return funcDecl.funcParams |>
        map { param: FuncParam => param.identifier.value } |>
        collectArray
}

/**
 * Get the types of all parameters in a function declaration.
 */
protected func getFuncParamTypes(funcDecl: FuncDecl): Array<Tokens> {
    return funcDecl.funcParams |>
        map { param: FuncParam => param.paramType.toTokens() } |>
        collectArray
}

protected func getRetTypeTokens(funcDecl: FuncDecl): Tokens {
    try {
        let ty = funcDecl.declType
        return ty.toTokens()
    } catch (_: ASTException) {
        return Tokens([Token(TokenKind.UNIT)])
    }
}

protected func isRetUnit(funcDecl: FuncDecl): Bool {
    try {
        let ty = funcDecl.declType
        if (ty.isPrimitiveType()) {
            return ty.asPrimitiveType().keyword.kind == TokenKind.UNIT
        } else {
            return false
        }
    } catch (_: ASTException) {
        return true
    }
}

func isOption(typeNode: TypeNode): Bool {
    if (let Some(varType) <- (typeNode as RefType)) {
        return varType.identifier.value == "Option"
    }
    return false
}

class ReturnVisitor <: Visitor {
    var visited = false

    override public func visit(expr: ReturnExpr) {
        visited = true
    }
}

protected func hasReturnExpr(node: Node): Bool {
    let visitor = ReturnVisitor()
    node.traverse(visitor)
    return visitor.visited
}

protected func parseFuncDecl(tokens: Tokens): FuncDecl {
    match (parseDecl(tokens) as FuncDecl) {
        case Some(f) => return f
        case None => throw DslException("Expected FuncDecl")
    }
}

protected func getTypeName(ty: TypeNode): String {
    if (ty is PrimitiveType) {
        return (ty as PrimitiveType).getOrThrow().keyword.value
    } else if (ty is RefType) {
        return (ty as RefType).getOrThrow().identifier.value
    } else {
        return "Error"
    }
}

protected interface NodeExt { }

extend Node <: NodeExt {
    protected func isDecl(): Bool {
        match (this as Decl) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isFuncDecl(): Bool {
        match (this as FuncDecl) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isClassDecl(): Bool {
        match (this as ClassDecl) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isVarDecl(): Bool {
        match (this as VarDecl) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isExpr(): Bool {
        match (this as Expr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isLambdaExpr(): Bool {
        match (this as LambdaExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isRefExpr(): Bool {
        match (this as RefExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isCallExpr(): Bool {
        match (this as CallExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isMemberAccess(): Bool {
        match (this as MemberAccess) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isRefType(): Bool {
        match (this as RefType) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isPrimitiveType(): Bool {
        match (this as PrimitiveType) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isLitConstExpr(): Bool {
        match (this as LitConstExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isStringLiteral(): Bool {
        match (this as LitConstExpr) {
            case Some(lit) =>
                lit.literal.kind == TokenKind.STRING_LITERAL ||
                lit.literal.kind == TokenKind.MULTILINE_STRING
            case None => false
        }
    }

    protected func isBinaryExpr(): Bool {
        match (this as BinaryExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func isTrailingClosureExpr(): Bool {
        match (this as TrailingClosureExpr) {
            case Some(_) => true
            case None => false
        }
    }

    protected func asDecl() {
        (this as Decl).getOrThrow()
    }

    protected func asLitConstExpr() {
        (this as LitConstExpr).getOrThrow()
    }

    protected func asBinaryExpr() {
        (this as BinaryExpr).getOrThrow()
    }

    protected func asRefExpr() {
        (this as RefExpr).getOrThrow()
    }

    protected func asVarDecl() {
        (this as VarDecl).getOrThrow()
    }

    protected func asFuncDecl() {
        (this as FuncDecl).getOrThrow()
    }

    protected func asClassDecl() {
        (this as ClassDecl).getOrThrow()
    }

    protected func asExpr() {
        (this as Expr).getOrThrow()
    }

    protected func asCallExpr() {
        (this as CallExpr).getOrThrow()
    }

    protected func asMemberAccess() {
        (this as MemberAccess).getOrThrow()
    }

    protected func asLambdaExpr() {
        (this as LambdaExpr).getOrThrow()
    }

    protected func asRefType() {
        (this as RefType).getOrThrow()
    }

    protected func asPrimitiveType() {
        (this as PrimitiveType).getOrThrow()
    }

    protected func asTrailingClosureExpr() {
        (this as TrailingClosureExpr).getOrThrow()
    }
}


protected const moreResumeButtonCss = '''
		.custom-dialog-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.5);
            align-items: center;
            justify-content: center;
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s, visibility 0.3s;
        }

        .custom-dialog-overlay.active {
            display: flex; /* 关键：添加flex显示 */
            opacity: 1;
            visibility: visible;
        }

		.custom-dialog {
            background-color: hsl(0, 0%, 100%);
            padding: 1.5rem;
            border-radius: 0.5rem;
            width: 90%;
            max-width: 400px;
            box-shadow: 0 4px 12px hsl(0, 0%, 0%, 0.15);
        }

        .dialog-message {
            margin-bottom: 1.5rem;
            color: hsl(0, 0%, 20%);
            line-height: 1.5;
        }

        .dialog-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
        }

        .dialog-btn {
            padding: 0.5rem 1rem;
            border-radius: 0.25rem;
            border: none;
            cursor: pointer;
            font-size: 0.875rem;
            transition: background-color 0.2s;
        }

        .dialog-cancel {
            background-color: hsl(0, 0%, 90%);
            color: hsl(0, 0%, 20%);
        }

        .dialog-cancel:hover {
            background-color: hsl(0, 0%, 80%);
        }

        .dialog-confirm {
            background-color: hsl(0, 100%, 60%);
            color: hsl(0, 0%, 100%);
        }

        .dialog-confirm:hover {
            background-color: hsl(0, 100%, 50%);
        }

        /* 更多模板按钮样式 */
        .more-templates {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            width: 3rem;
            height: 3rem;
            border-radius: 50%;
            background-color: hsl(217, 91%, 60%);
            color: white;
            border: none;
            font-size: 1.25rem;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s, transform 0.2s;
            z-index: 900;
        }

        .more-templates:hover {
            background-color: hsl(221, 70%, 33%);
            transform: scale(1.05);
        }

        /* 更多模板按钮样式 */
        .more-templates {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            width: 3rem;
            height: 3rem;
            border-radius: 50%;
            background-color: hsl(217, 91%, 60%);
            color: white;
            border: none;
            font-size: 1.25rem;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s, transform 0.2s;
            z-index: 900;
        }

        .more-templates:hover {
            background-color: hsl(221, 70%, 33%);
            transform: scale(1.05);
        }

        /* 模板列表对话框样式 */
        .templates-modal .dialog-content {
            margin-bottom: 1rem;
        }

        /* 水平滚动容器 */
        .templates-scroll-container {
            position: relative;
            overflow: hidden;
            padding: 1rem 0;
        }

        .templates-slider {
            display: flex;
            gap: 1.5rem;
            padding: 1rem 0;
            overflow-x: auto;
            scroll-behavior: smooth;
            scrollbar-width: thin;
            scrollbar-color: hsl(217, 91%, 60%) hsl(0, 0%, 90%);
            padding-bottom: 2rem; /* 为滚动条预留空间 */
        }

        /* 自定义滚动条 */
        .templates-slider::-webkit-scrollbar {
            height: 6px;
        }

        .templates-slider::-webkit-scrollbar-track {
            background: hsl(0, 0%, 90%);
            border-radius: 10px;
        }

        .templates-slider::-webkit-scrollbar-thumb {
            background-color: hsl(217, 91%, 60%);
            border-radius: 10px;
        }

        /* 模板缩略图样式 */
        .template-item {
            min-width: 240px;
            border: 1px solid hsl(0, 0%, 93%);
            border-radius: 0.5rem;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .template-item:hover {
            border-color: hsl(217, 91%, 60%);
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        }

        .template-thumbnail {
            height: 200px;
            background-color: hsl(0, 0%, 96%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .template-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .template-item:hover .template-thumbnail img {
            transform: scale(1.05);
        }

        .template-info {
            padding: 1rem;
        }

        .template-title {
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: hsl(221, 70%, 33%);
            font-size: 1rem;
        }

        .template-desc {
            font-size: 0.875rem;
            color: hsl(0, 0%, 50%);
            line-height: 1.4;
        }

        /* 滚动控制按钮 */
        .scroll-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 50%;
            background-color: white;
            border: 1px solid hsl(0, 0%, 93%);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            z-index: 10;
            transition: all 0.2s ease;
        }

        .scroll-btn:hover {
            background-color: hsl(217, 91%, 60%);
            color: white;
        }

        /* 提示文字 */
        .scroll-hint {
            text-align: center;
            font-size: 0.875rem;
            color: hsl(0, 0%, 50%);
            margin-top: 0.5rem;
        }'''
protected const moreResumeButtonBody = '''
    <button class="more-templates" id="moreTemplatesBtn">...</button>

    <!-- 模板列表对话框 -->
   <div class="custom-dialog-overlay templates-modal" id="templatesModal">
        <div class="custom-dialog">
            <h3 class="section-title" style="margin-bottom: 1rem;">
                <i class="fa fa-th-large"></i>更多简历模板
            </h3>
            <div class="dialog-content">
                <div class="templates-scroll-container">
                    <div class="templates-slider">
                        {% for metadata in thumbnails %}
                            {% if (title != metadata.title) %}
                            <div class="template-item" data-template="modern">
                                <div class="template-thumbnail">
                                    <img src={% metadata.thumbnail %}>
                                </div>
                                <div class="template-info">
                                    <div class="template-title">{% metadata.title %}</div>
                                    <div class="template-desc">{% metadata.desc %}</div>
                                </div>
                            </div>
                            {% /if %}
                        {% /for %}
                    </div>
                </div>
                <p class="scroll-hint">可左右滑动查看更多模板，点击模板即可切换</p>
            </div>
            <div class="dialog-buttons">
                <button class="dialog-btn dialog-cancel" id="templatesModalCancel">关闭</button>
            </div>
        </div>
    </div>

    <!-- 通用确认对话框 -->
    <div class="custom-dialog-overlay" id="confirmDialog">
        <div class="custom-dialog">
            <div class="dialog-message" id="dialogMessage"></div>
            <div class="dialog-buttons">
                <button class="dialog-btn dialog-cancel" id="dialogCancel">取消</button>
                <button class="dialog-btn dialog-confirm" id="dialogConfirm">确认</button>
            </div>
        </div>
    </div>
    '''
protected const moreResumeButtonScript = '''
        // 获取对话框元素
        const confirmDialog = document.getElementById('confirmDialog');
        const dialogMessage = document.getElementById('dialogMessage');
        const dialogCancel = document.getElementById('dialogCancel');
        const dialogConfirmBtn = document.getElementById('dialogConfirm');

        // 模板选择处理
        const templateItems = document.querySelectorAll('.template-item');
        const templatesModal = document.getElementById('templatesModal');

        // 取消删除
        dialogCancel.addEventListener('click', function() {
            confirmDialog.classList.remove('active');
            moduleToDelete = null;
        });
        var resumeType = ""
        // 确认删除
        dialogConfirmBtn.addEventListener('click', function() {
            agentCallbackObject.sendMessageByUI("请帮我切换为"+resumeType+"，简历内容保持不变");
        });

        // 取消按钮通用处理
        document.getElementById('dialogCancel').addEventListener('click', function() {
            document.getElementById('confirmDialog').classList.remove('active');
        });

        // 模板选择功能
        document.getElementById('moreTemplatesBtn').addEventListener('click', function() {
            document.getElementById('templatesModal').classList.add('active');
        });

        document.getElementById('templatesModalCancel').addEventListener('click', function() {
            document.getElementById('templatesModal').classList.remove('active');
        });

        templateItems.forEach(item => {
            item.addEventListener('click', function() {
                const templateType = this.getAttribute('data-template');
                const templateName = this.querySelector('.template-title').textContent;

                // 设置确认对话框内容
                dialogMessage.textContent = `您选择了"\\\${templateName}"，切换模板将保留您的内容但更改样式，是否继续？`;
                confirmDialog.classList.add('active');
                resumeType = templateName
            });
        });

        // 点击对话框外部关闭
        document.querySelectorAll('.custom-dialog-overlay').forEach(overlay => {
            overlay.addEventListener('click', function(e) {
                if (e.target === this) {
                    this.classList.remove('active');
                }
            });
        });
    '''