package magic

import magic.dsl.*
import magic.prelude.*
import magic.config.Config
import std.fs.{File, Path, exists, Directory, OpenMode, removeIfExists}
import std.io.StringWriter


@agent[model: "deepseek:deepseek-chat", executor: "naive"]
class FileImportAgent {
    @prompt(
        "You are a file processing assistant"
        "When users ask questions containing @<path> format, you can already see the file content"
        "Please answer user questions based on file content"
        "If the file content contains code, please analyze and provide improvement suggestions"
    )
}

func testImport() {
    // Create some example files
    createExampleFiles()

    let agent = FileImportAgent()

    // Example 1: Simple file import
    println("=== Example 1: Simple File Import ===")
    let result1 = agent.chat("Please analyze this file: @example_files/example.txt")
    println(result1)
    println()

    // Example 2: Code file analysis
    println("=== Example 2: Code File Analysis ===")
    let result2 = agent.chat("Please analyze this code file and provide improvement suggestions: @example_files/code.cj")
    println(result2)
    println()

    // Example 3: Multiple file imports
    println("=== Example 3: Multiple File Imports ===")
    let result3 = agent.chat("Please compare the content of these two files: @example_files/example.txt and @example_files/data.txt")
    println(result3)
    println()

    // Example 4: Nested file import
    println("=== Example 4: Nested File Import ===")
    let result4 = agent.chat("Please explain the content of this nested file: @example_files/nested.txt")
    println(result4)
    println()

    // Clean up example files
    cleanupExampleFiles()
}

private func createExampleFiles(): Unit {
    let exampleDir = Path("./example_files")
    if (!exists(exampleDir)) {
        Directory.create(exampleDir)
    }

    // Create example text file
    writeFile("./example_files/example.txt", """
This is an example file to demonstrate file import functionality.
The file contains some basic information that can be used to test the agent's file processing capabilities.
Main content:
1. File import function demonstration
2. Multi-file support
3. Nested file processing
""")

    // Create example code file
    writeFile("./example_files/code.cj", """
// Example code file
func calculateSum(numbers: Array<Int64>): Int64 {
    var sum = 0
    for (num in numbers) {
        sum += num
    }
    return sum
}

func findMax(arr: Array<Int64>): Int64 {
    if (arr.size == 0) {
        return 0
    }

    var max = arr[0]
    for (i in 1..arr.size) {
        if (arr[i] > max) {
            max = arr[i]
        }
    }
    return max
}
""")

    // Create data file
    writeFile("./example_files/data.txt", """
Data file content:
- Project A: 80% complete
- Project B: 65% complete
- Project C: 90% complete
- Project D: 45% complete
""")

    // Create nested file
    writeFile("./example_files/nested.txt", """
This is a nested file that references other files:
Basic information: @example.txt

Code analysis: @code.cj

Data statistics: @data.txt
""")
}

private func writeFile(path: String, content: String): Unit {
    try (file = File(path, OpenMode.Write)) {
        let writer = StringWriter(file)
        writer.write(content)
        writer.flush()
    }
}

private func cleanupExampleFiles(): Unit {
    let exampleDir = Path("./example_files")
    if (exists(exampleDir)) {
        removeIfExists(exampleDir, recursive: true)
    }
}