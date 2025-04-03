package magic.tokenizer

import magic.utils.readFile
import magic.core.tokenizer.Tokenizer
import std.fs.Path

/**
 * Support Qwen/Deepseek/TickToken[cl100k] Only
 */
public class TokenizerLoader {
    private static let tiktokens: Array<String> = ["cl100k"]
    public static func load(modelNameOrPath: String): Tokenizer {
        try {
            if (tiktokens.contains(Path(modelNameOrPath).fileNameWithoutExtension)) {
                return Cl100kTokenizer(modelNameOrPath)
            } else {
                return BPETokenizer(modelNameOrPath)
            }
        } catch (e: Exception) {
            throw UnsupportedException("Unsupported model ${modelNameOrPath}")
        }
    }
}
