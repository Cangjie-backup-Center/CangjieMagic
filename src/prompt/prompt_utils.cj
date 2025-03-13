package magic.prompt

import magic.utils.exists

import std.fs.{Path, File, FSException, OpenOption}
import std.io.StringReader

public struct PromptUtils {
    public static func readPromptFile(path: String): String {
        if (!exists(path)) {
            throw FSException("Prompt file ${path} does not exist.")
        }
        try (file = File(path, OpenOption.Open(true, false))) {
            let reader = StringReader(file)
            return reader.readToEnd()
        }
        throw UnsupportedException()
    }
}