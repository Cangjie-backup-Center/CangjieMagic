package magic.examples.doc_generator

import std.fs.{File, OpenOption, Directory, Path}
import std.io.{StringReader, StringWriter}
import log.LogLevel
import std.ast.*
import std.sort.SortExtension

import magic.dsl.*
import magic.prelude.*
import magic.utils.*
import magic.config.Config
import magic.utils.directoryOf

private let SRC_DIR = "./src"
private let OUT_DIR = "./temp-docs"

func readFile(path: Path): String {
    try (file = File(path, OpenOption.Open(true, false))) {
        let reader = StringReader(file)
        return reader.readToEnd()
    }
    throw UnsupportedException()
}

func readFile(path: String): String {
    return readFile(Path(path))
}

func writeFile(path: Path, content: String): Unit {
    let outfile: File = File(path, OpenOption.CreateOrTruncate(false))
    let writer = StringWriter(outfile)
    writer.write(content)
    writer.flush()
    outfile.close()
}

func isPublicDecl(decl: Decl): Bool {
    var isPublic = false
    for (m in decl.modifiers) {
        if (m.keyword.value == "public") {
            isPublic = true
        }
    }
    return isPublic
}

func isApiTypeDecl(decl: Decl): Bool {
    if (!isPublicDecl(decl)) {
        return false
    }
    if (decl.identifier.value.startsWith("__")) {
        return false
    }
    match (decl.keyword.value) {
        case "class" | "enum" | "struct" | "interface" => true
        case _ => false
    }
}

func isApiMemberDecl(decl: Decl): Bool {
    if (!isPublicDecl(decl)) {
        return false
    }
    match (decl.keyword.value) {
        case "func" | "prop" | "init" | "operator" | "let" | "var" => true
        case _ => false
    }
}

func splitDeclComment(lines: Array<String>, beginPos: Position): String {
    var beginLineNo = Int64(beginPos.line)
    // Check whether the decl has a comment prefix
    var curr = beginLineNo - 1
    if (lines[curr].trimAscii().endsWith("*/")) {
        while (!lines[curr].trimAscii().startsWith("/*")) {
            curr -= 1
        }
        // println("Decl comment: ${curr}, ${beginLineNo}")
        return String.join(lines[curr..beginLineNo], delimiter: "\n")
    } else if (lines[curr].trimAscii().startsWith("//")) {
        while (lines[curr].trimAscii().startsWith("//")) {
            curr -= 1
        }
        curr += 1
        // println("Decl comment: ${curr}, ${beginLineNo}")
        return String.join(lines[curr..beginLineNo], delimiter: "\n")
    }else {
        return ""
    }
}

func splitDeclComment(lines: Array<String>, decl: Decl): String {
    return splitDeclComment(lines, decl.beginPos)
}

func splitDeclContent(lines: Array<String>, decl: Decl): String {
    var beginLineNo = Int64(decl.beginPos.line)
    let endLineNo = Int64(decl.endPos.line)
    // println("Decl: ${beginLineNo}, ${endLineNo}")
    let comment = splitDeclComment(lines, decl)
    let declContent = String.join(lines[beginLineNo..(endLineNo+1)], delimiter: "\n")
    if (comment.isEmpty()) {
        return declContent
    } else {
        return comment + "\n" + declContent
    }
}

func splitMemberDecls(lines: Array<String>, body: Body, needCheck!: Bool): ArrayList<String> {
    return splitMemberDecls(lines, body.decls, needCheck: needCheck)
}

func splitMemberDecls(lines: Array<String>, decls: ArrayList<Decl>, needCheck!: Bool): ArrayList<String> {
    let buffer = ArrayList<String>()
    for (memberDecl in decls) {
        if (needCheck && !isApiMemberDecl(memberDecl)) {
            continue
        }
        let declContent = splitDeclContent(lines, memberDecl)
        buffer.append(declContent)
        buffer.append("")
    }
    return buffer
}

func readAndFilterCJFile(path: Path): String {
    let buffer = ArrayList<String>()
    let content = readFile(path)
    let program = parseProgram(cangjieLex(content))
    let lines = "\n${content}".split("\n") // File line number starts from 1, so adding an empty line here
    for (topDecl in program.decls) {
        if (!isApiTypeDecl(topDecl)) {
            continue
        }
        buffer.append(splitDeclComment(lines, topDecl))
        buffer.append(lines[Int64(topDecl.beginPos.line)])

        if (topDecl.keyword.value == "class") {
            let classDecl = (topDecl as ClassDecl).getOrThrow()
            buffer.appendAll(splitMemberDecls(lines, classDecl.body, needCheck: true))
        } else if (topDecl.keyword.value == "struct") {
            let structDecl = (topDecl as StructDecl).getOrThrow()
            buffer.appendAll(splitMemberDecls(lines, structDecl.body, needCheck: true))
        } else if (topDecl.keyword.value == "interface") {
            let interfaceDecl = (topDecl as InterfaceDecl).getOrThrow()
            buffer.appendAll(splitMemberDecls(lines, interfaceDecl.body, needCheck: false))
        } else if (topDecl.keyword.value == "enum") {
            let enumDecl = (topDecl as EnumDecl).getOrThrow()
            for (constructor in enumDecl.constructors) {
                let pos = constructor.toTokens()[0].pos
                // There is a bug of ast, we cannot use `constructor.beginPos` directly
                buffer.append(splitDeclComment(lines, pos))
                buffer.append(lines[Int64(pos.line)])
                buffer.append("")
            }
            buffer.appendAll(splitMemberDecls(lines, enumDecl.decls, needCheck: true))
        }

        buffer.append("}")
    }
    return String.join(buffer.toArray(), delimiter: "\n")
}

//------------------------------------------------------------------------

func checkFile(path: Path): Bool {
    let content = readFile(path)
    let targets = ["public enum", "public class", "public struct", "public interface"]
    for (target in targets) {
        if (content.contains(target)) {
            return true
        }
    }
    return false
}

let blacklist = [
    "openai", "ollama", "zhipuai", "dashscope", "siliconflow",
    "llamacpp", "main", "prompt", "tests", "examples", "dsl", "utils"
]

func getAllFiles(dirPath: Path, allFiles: ArrayList<Path>): Unit  {
    let dir = Directory(dirPath)
    for (fileInfo in dir.entryList()) {
        let filePath = canonicalize(fileInfo.path)
        println(filePath)
        if (blacklist.contains(fileNameWithoutExt(filePath))) {
            continue
        }
        if (isRegularFile(fileInfo) && fileExt(filePath) == "cj") {
            if (checkFile(filePath)) {
                allFiles.append(fileInfo.path)
            }
        } else if (fileInfo.isDirectory()) {
            getAllFiles(filePath, allFiles)
        }
    }
}

//------------------------------------------------------------------------

@jsonable
class Doc <: ToString {
    @field["Name of the package"]
    var packageName: String

    let typeDefs: Array<TypeDef>

    override public func toString(): String {
        let sb = StringBuilder()
        sb.append("## Package ${packageName}\n")
        for (t in typeDefs) {
            sb.append("${t}\n")
        }
        return sb.toString()
    }
}

@jsonable
class TypeDef <: ToString {
    @field["Available values: enum, class, struct, interface"]
    let kind: String

    @field["Name of the type definition"]
    let name: String

    @field["A list of member definition"]
    let memberDefs: Array<MemberDef>

    override public func toString(): String {
        let sb = StringBuilder()
        sb.append("### ${kind} ${name}\n")
        for (m in this.sortedMemberDefs) {
            sb.append("${m}\n\n")
        }
        return sb.toString()
    }

    prop sortedMemberDefs: Array<MemberDef> {
        get() {
            let members = ArrayList(this.memberDefs)
            members.sortBy(comparator: { m1, m2 =>
                return m1.name.compare(m2.name)
            })
            return members.toArray()
        }
    }
}

@jsonable
class MemberDef <: ToString {
    @field["Available values: prop, func, let, var, enumeration (for enum types)"]
    let kind: String

    @field["Name of the definition"]
    let name: String

    @field["Complete signature of the definition."
           "For example,"
           "- function signature: func foo(arg: String): Int64"
           "- operator function signature: operator func[](idx: Int64): String"
           "- prop signature: prop bar: Int64"
           "- variable signature: let a: Int64"
           "- enumeration signature: B(String)"]
    let signature: String

    @field["Functionality description of the member. It must be In Chinese. For example, description: 根据用户问题，在内存中查找相关内容"]
    let description: String

    @field["If kind is func, parameter descriptions are provided"]
    let parameters: Array<Parameter>

    private func getModifier(): String {
        if (kind == "enumeration") {
            return ""
        }
        return kind
    }

    private func getName(): String {
        if (kind == "func") {
            if (signature.contains("operator")) {
                return "operator ${name}"
            }
        }
        return name
    }

    override public func toString(): String {
        let s = ArrayList([
            "#### ${this.getModifier()} ${this.getName()}",
            "```",
            "${signature}",
            "```",
            "- 描述: ${description}"
        ])
        if (!parameters.isEmpty()) {
            s.append("- 参数:")
        }
        for (p in parameters) {
            s.append("  - ${p}")
        }
        return String.join(s.toArray(), delimiter: "\n")
    }
}

@jsonable
class Parameter <: ToString {
    @field["Name of the parameter"]
    let name: String
    @field["Type name of the parameter"]
    let typeName: String
    @field["Description of the parameter. In Chinese"]
    let description: String

    override public func toString(): String {
        return "`${name}`: `${typeName}`, ${description}"
    }
}

@agent[
    model: "ark:deepseek-v3-250324",
    executor: "naive",
]
class DocAgent {
    @prompt(
        """
        # Background
        ${readFile("./src/examples/doc_generator/cj-lang.md")}

        # Instruction
        Given a Cangjie program, you are required to generate API documents for it.
        Only generate documents for public type definitions and public member definitions.
        This is an import requirement.
        You must follow Cangjie syntax, e.g., function definition, class definition.
        Function descriptions and parameter descriptions are in Chinese.
        """
    )
    @user(
        """
        This is the program.
        ```cangjie
        {program}
        ```
        Generate the document now.
        Descriptions and parameter descriptions must be in Chinese.
        """
    )
}

//------------------------------------------------------------------------

@When[os != "Windows"]
const SEPARATOR = "/"
@When[os == "Windows"]
const SEPARATOR = "\\"

/**
 * Input: <path>/src/a/b/c/d.cj
 * Output: a.b.c
 */
func getPackageName(path: Path): String {
    let pkgPath = directoryOf(canonicalize(path)).toString()
    let target = "${SEPARATOR}src${SEPARATOR}"
    let idx = pkgPath.indexOf(target).getOrThrow()
    return pkgPath[(idx + target.size)..].replace(SEPARATOR, ".")
}

func buildFileDoc(allFiles: ArrayList<Path>): Unit {
    let agent = DocAgent()
    for (path in allFiles) {
        let pkgName = getPackageName(path)
        println(path.toString())
        // println(pkgName)
        let content = readAndFilterCJFile(path)
        let result = agent.chatGet<Doc>(("program", content))
        if (let Some(doc) <- result) {
            doc.packageName = pkgName
            let docPath = Path(OUT_DIR).join("${pkgName}.${path.fileNameWithoutExtension}.json")
            writeFile(docPath, doc.toJsonValue().toJsonString())
            println(doc.toJsonValue().toJsonString())
        }
        println("------------------------")
    }
}

func buildPackageToc(packageName: String, typeDefs: ArrayList<TypeDef>): String {
    let linkNameCount = HashMap<String, Int64>()
    let createLinkName = { title: String =>
        var linkName = "#" + title.toAsciiLower().replace(" ", "-")
        if (linkNameCount.contains(linkName)) {
            let count = linkNameCount[linkName]
            linkName = "${linkName}-${count}"
            linkNameCount.put(linkName, count + 1)
        } else {
            linkNameCount.put(linkName, 1)
        }
        return linkName
    }

    let sb = StringBuilder()
    let packageTitle = "Package ${packageName}"
    let packageLinkName = createLinkName(packageTitle)
    sb.append("- [${packageTitle}](${packageLinkName})\n")

    for (typeDef in typeDefs) {
        let typeTitle = "${typeDef.kind} ${typeDef.name}"
        let typeLinkName = createLinkName(typeTitle)
        sb.append("  - [${typeTitle}](${typeLinkName})\n")
        for (memberDef in typeDef.sortedMemberDefs) {
            let memberTitle = "${memberDef.kind} ${memberDef.name}"
            let memberLinkName = createLinkName(memberTitle)
            sb.append("    - [${memberTitle}](${memberLinkName})\n")
        }
    }
    return sb.toString()
}

func mergeDocs(dirPath: Path): Unit  {
    // Merge all type definitions according to their package names
    let allDocs = HashMap<String, ArrayList<TypeDef>>()
    let dir = Directory(dirPath)
    for (fileInfo in dir.fileList()) {
        if (isRegularFile(fileInfo) && fileExt(fileInfo.path) == "json") {
            let content = readFile(fileInfo.path)
            let doc = Doc.fromJsonValue(JsonValue.fromStr(content))
            if (!allDocs.contains(doc.packageName)) {
                allDocs.put(doc.packageName, ArrayList<TypeDef>())
            }
            allDocs[doc.packageName].appendAll(doc.typeDefs)
        }
    }
    // Dump as markdown file
    try (outfile = File(dirPath.join("api_reference.md"),
                        OpenOption.CreateOrTruncate(false))) {
        let packageDocDir = dirPath.join("./package_docs")
        if (!exists(packageDocDir)) {
            Directory.create(packageDocDir, recursive: true)
        }
        let writer = StringWriter(outfile)
        writer.write("# API Reference\n\n")
        let allPackageNames = allDocs.keys().toArray()
        allPackageNames.sort()
        for (packageName in allPackageNames) {
            let packageDocPath = packageDocDir.join("${packageName}.md")
            let typeDefs = allDocs[packageName]
            typeDefs.sortBy(comparator: { t1, t2 =>
                return t1.name.compare(t2.name)
            })

            try (outfile2 = File(packageDocPath, OpenOption.CreateOrTruncate(false))) {
                let writer2 = StringWriter(outfile2)
                writer2.write("## Package ${packageName}\n")
                writer2.write(buildPackageToc(packageName, typeDefs))
                writer2.write("\n")
                for (typeDef in typeDefs) {
                    writer2.write(typeDef.toString())
                    writer2.write("\n")
                }
                writer2.flush()
            }
            writer.write("- 📁 [${packageName}](./package_docs/${packageName}.md)\n")
            writer.flush()
        }
    }
}

main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/abc.log"

    if (!exists(OUT_DIR)) {
        Directory.create(OUT_DIR, recursive: true)
    }

    let allFiles = ArrayList<Path>()
    getAllFiles(Path(SRC_DIR), allFiles)
    buildFileDoc(allFiles)
    mergeDocs(Path(OUT_DIR))
}