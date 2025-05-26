package magic.tokenizer

import magic.utils.{readFile, fileNameWithoutExt}
import magic.core.tokenizer.Tokenizer
import magic.config.Config
import std.fs.Path

public enum TokenizerType {
    | Cl100k
    | DeepSeek
    | Qwen

    public func toString() {
    }

    public static func fromString(ttype: String): TokenizerType {
        match (ttype.toAsciiLower()) {
            case "cl100k" => Cl100k
            case "deepseek" => DeepSeek
            case "qwen" => Qwen
            case _ => throw UnsupportedException(
                "Chat Model Tokenizer Type Error: Only [Cl100k, DeepSeek, Qwen] Supported.")
        }
    }
}

/**
 * Support Qwen/Deepseek/TickToken[cl100k] Only
 */
public class TokenizerLoader {
    
    public static func default(): Tokenizer {
        if (let Some(tk) <- Config.defaultTokenizer) {
            tk
        } else {
            UnicodeTokenizer()
        }
    }

    public static func load(tokenizerType: TokenizerType, vocabPath: String): Tokenizer {
        try {
            match (tokenizerType) {
                case Cl100k => Cl100kTokenizer(vocabPath)
                case DeepSeek | Qwen => BPETokenizer(vocabPath)
            }
        } catch (e: Exception) {
            throw UnsupportedException("Illegal Tokenizer Vocab ${vocabPath}")
        }
    }
}
