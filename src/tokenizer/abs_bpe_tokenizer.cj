package magic.tokenizer

internal import magic.core.tokenizer.Tokenizer
internal import magic.utils.readFile
internal import std.collection.*
internal import std.regex.*
internal import std.fs.*
internal import encoding.json.*
internal import std.collection.*
internal import std.fs.*
internal import std.io.*
internal import std.regex.*
internal import magic.utils.readFile
internal import magic.core.tokenizer.*
internal import serialization.serialization.*
internal import std.math.pow

public interface JsonDeserializable<T> <: Serializable<T> {
    func serialize(): DataModel {
        throw UnsupportedException()
    }
    static func fromJson(str: String) {
        let jv = JsonValue.fromStr(str)
        return deserialize(DataModel.fromJson(jv))
    }
}

struct Token <: JsonDeserializable<Token> {
    let _id: UInt32
    let _content: String
    let _single_word: Bool
    let _lstrip: Bool
    let _rstrip: Bool
    let _normalized: Bool
    let _special: Bool

    private init(
        id: UInt32,
        content: String,
        single_word: Bool,
        lstrip: Bool,
        rstrip: Bool,
        normalized: Bool,
        special: Bool
    ) {
        this._id = id
        this._content = content
        this._single_word = single_word
        this._lstrip = lstrip
        this._rstrip = rstrip
        this._normalized = normalized
        this._special = special
    }

    public static func deserialize(dm: DataModel): Token {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let id = UInt32.deserialize(dms.get("id"))
        let content = String.deserialize(dms.get("content"))
        let singleWord = Bool.deserialize(dms.get("single_word"))
        let lstrip = Bool.deserialize(dms.get("lstrip"))
        let rstrip = Bool.deserialize(dms.get("rstrip"))
        let normalized = Bool.deserialize(dms.get("normalized"))
        let special = Bool.deserialize(dms.get("special"))
        return Token(id, content, singleWord, lstrip, rstrip, normalized, special)
    }
}

struct Normalizer <: JsonDeserializable<Normalizer> {
    let _type: String

    private init(nType: String) {
        this._type = nType
    }

    public static func deserialize(dm: DataModel): Normalizer {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let nType = String.deserialize(dms.get("type"))
        return Normalizer(nType)
    }
}

struct Pattern <: JsonDeserializable<Pattern> {
    let _regex: String

    private init(pRegex: String) {
        this._regex = pRegex
    }

    public static func deserialize(dm: DataModel): Pattern {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let regex = String.deserialize(dms.get("Regex"))
        return Pattern(regex)
    }
}

struct Process <: JsonDeserializable<Process> {
    // Union ByteLevel and SplitTokenizer
    let _type: String
    // use for ByteLevel: decoder/post_processor
    let _add_prefix_space: Option<Bool>
    let _trim_offsets: Option<Bool>
    let _use_regex: Option<Bool>
    // actived when split tokenizer
    let _pattern: Option<Pattern>
    let _behavior: Option<String>
    let _invert: Option<Bool>

    // construct for decode/post_preprossor
    private init(
        p_type: String,
        add_prefix_space: Bool,
        trim_offsets: Bool,
        use_regex: Bool
    ) {
        this._type = p_type
        if (this._type != "ByteLevel") {
            throw Exception("this construction function only suppport ByteLevel type");
        }
        this._add_prefix_space = Some(add_prefix_space)
        this._trim_offsets = Some(trim_offsets)
        this._use_regex = Some(use_regex)
        this._pattern = None
        this._behavior = None
        this._invert = None
    }

    private init(
        p_type: String,
        pattern: Pattern,
        behavior: String,
        invert: Bool
    ) {
        this._type = p_type
        if (p_type != "Split") {
            throw Exception("this construction function only support Split type")
        }
        this._add_prefix_space = None
        this._trim_offsets = None
        this._use_regex = None
        this._pattern = Some(pattern)
        this._behavior = Some(behavior)
        this._invert = Some(invert)
    }

    public static func deserialize(dm: DataModel): Process {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let _type = String.deserialize(dms.get("type"))
        match (_type) {
            case "ByteLevel" =>
                let addPrefixSpace = Bool.deserialize(dms.get("add_prefix_space"))
                let trimOffsets = Bool.deserialize(dms.get("trim_offsets"))
                let useRegex = Bool.deserialize(dms.get("use_regex"))
                Process(
                    _type,
                    addPrefixSpace,
                    trimOffsets,
                    useRegex,
                );
            case "Split" =>
                let pattern = Pattern.deserialize(dms.get("pattern"))
                let behavior = String.deserialize(dms.get("behavior"))
                let invert = Bool.deserialize(dms.get("invert"))
                Process(
                    _type,
                    pattern,
                    behavior,
                    invert
                )
            case _ => throw Exception("unkonw process type ${_type}}")
        }
    }
}

struct PreTokenizer <: JsonDeserializable<PreTokenizer> {
    let _type: String
    let _pretokenizers: ArrayList<Process>
    private init(p_type: String, pretokenizers: ArrayList<Process>) {
        this._type = p_type
        this._pretokenizers = pretokenizers
    }

    private init() {
        this._type = ""
        this._pretokenizers = ArrayList<Process>()
    }

    public static func deserialize(dm: DataModel): PreTokenizer {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let _type = String.deserialize(dms.get("type"))
        let _pretokenizers = ArrayList<Process>.deserialize(dms.get("pretokenizers"))
        return PreTokenizer(_type, _pretokenizers)
    }
}

struct Model <: JsonDeserializable<Model> {
    let _type: String
    // perform no merges, so the result will just be characters.
    let _dropout: Option<Float32>
    // The unknown token to be used when we encounter an unknown char
    let _unk_token: Option<String>
    // An optional prefix to use on any subword that exist only behind another one
    let _continuing_subword_prefix: String
    // An optional suffix to caracterize and end-of-word subword
    let _end_of_word_suffix: String
    // Do multiple unk tokens get fused
    let _fuse_unk: Bool
    // Byte fallback from sentence pieces, instead of UNK, uses `"<0x00>"`
    // for each byte in the unk token
    let _byte_fallback: Bool
    let _vocab: HashMap<String, UInt32>
    let _merges: ArrayList<String>

    private init(
        _type: String,
        dropout: Option<Float32>,
        vocab: HashMap<String, UInt32>,
        merges: ArrayList<String>,
        unk_token!: Option<String> = None,
        continuing_subword_prefix!: String = "",
        end_of_word_suffix!: String = "",
        fuse_unk!: Bool = false,
        byte_fallback!: Bool = false
    ) {
        this._type = _type
        if (dropout.isSome()) {
            let dropout_value = dropout.getOrThrow();
            if (dropout_value < 0.0 || dropout_value > 1.0) {
                throw Exception("dropout can only between 0~1")
            }
        }
        this._dropout = dropout
        this._unk_token = unk_token
        this._continuing_subword_prefix = continuing_subword_prefix
        this._end_of_word_suffix = end_of_word_suffix
        this._fuse_unk = fuse_unk
        this._byte_fallback = byte_fallback
        this._vocab = vocab
        this._merges = merges
    }

    public static func deserialize(dm: DataModel): Model {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let _type = String.deserialize(dms.get("type"))
        let dropout = Option<Float32>.deserialize(dms.get("dropout"))
        let vocab = HashMap<String, UInt32>.deserialize(dms.get("vocab"))
        let merges = ArrayList<String>.deserialize(dms.get("merges"))
        let unkToken = Option<String>.deserialize(dms.get("unk_token"))
        let continuingSubwordPrefix = Option<String>.deserialize(dms.get("continuing_subword_prefix"))
        let endOfWordSuffix = Option<String>.deserialize(dms.get("end_of_word_suffix"))
        let fuseUnk = Bool.deserialize(dms.get("fuse_unk"))
        let byteFallback = Bool.deserialize(dms.get("byte_fallback"))
        return Model(_type, dropout, vocab, merges, unk_token: unkToken,
            continuing_subword_prefix: continuingSubwordPrefix.getOrDefault({=> ""}),
            end_of_word_suffix: endOfWordSuffix.getOrDefault({=> ""}), byte_fallback: byteFallback)
    }
}

public struct TokenizerJson <: JsonDeserializable<TokenizerJson> {
    let _version: String
    let _truncation: Option<String>
    let _padding: Option<String>
    let _added_tokens: ArrayList<Token>
    let _normalizer: Normalizer
    let _pre_tokenizer: PreTokenizer
    let _post_processor: Process
    let _decoder: Process
    let _model: Model

    init(
        version: String,
        truncation: Option<String>,
        padding: Option<String>,
        added_tokens: ArrayList<Token>,
        normalizer: Normalizer,
        pre_tokenizer: PreTokenizer,
        post_processor: Process,
        decoder: Process,
        model: Model
    ) {
        this._version = version
        this._truncation = truncation
        this._padding = padding
        this._added_tokens = added_tokens
        this._normalizer = normalizer
        this._pre_tokenizer = pre_tokenizer
        this._post_processor = post_processor
        this._decoder = decoder
        this._model = model
    }

    public static func deserialize(dm: DataModel): TokenizerJson {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let version = String.deserialize(dms.get("version"))
        let truncation = Option<String>.deserialize(dms.get("truncation"))
        let padding = Option<String>.deserialize(dms.get("padding"))
        let addedTokens = ArrayList<Token>.deserialize(dms.get("added_tokens"))
        let normalizer = Normalizer.deserialize(dms.get("normalizer"))
        let preTokenizer = PreTokenizer.deserialize(dms.get("pre_tokenizer"))
        let postProcessor = Option<Process>.deserialize(dms.get("post_processor"))
        let decoder = Option<Process>.deserialize(dms.get("decoder"))
        let model = Option<Model>.deserialize(dms.get("model"))

        return TokenizerJson(version, truncation, padding, addedTokens, normalizer, preTokenizer,
            postProcessor.getOrThrow(), decoder.getOrThrow(), model.getOrThrow())
    }
}

public struct BPETokenizerConfig <: JsonDeserializable<BPETokenizerConfig> {
    let _add_bos_token: Bool
    let _add_eos_token: Bool
    let _bos_token: Option<String>
    let _eos_token: Option<String>
    let _pad_token: Option<String>
    let _unk_token: Option<String>
    let _model_max_length: UInt32
    let _tokenizer_class: String

    private init(
        add_bos_token: Bool,
        add_eos_token: Bool,
        bos_token: Option<String>,
        eos_token: Option<String>,
        pad_token: Option<String>,
        unk_token: Option<String>,
        model_max_length: UInt32,
        tokenizer_class: String
    ) {
        this._add_bos_token = add_bos_token
        this._add_eos_token = add_eos_token
        this._bos_token = bos_token
        this._eos_token = eos_token
        this._pad_token = pad_token
        this._unk_token = unk_token
        this._model_max_length = model_max_length
        this._tokenizer_class = tokenizer_class
    }

    public static func deserialize(dm: DataModel): BPETokenizerConfig {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let add_bos_token = Option<Bool>.deserialize(dms.get("add_bos_token"))
        let add_eos_token = Option<Bool>.deserialize(dms.get("add_eos_token"))
        let _ = Option<Bool>.deserialize(dms.get("_"))
        let bos_token: Option<String> = match (dms.get("bos_token")) {
            case data: DataModelString => Option<String>.deserialize(data)
            case data: DataModelStruct => match (data.get("content")) {
                case innerData: DataModelString => Option<String>.deserialize(innerData)
                case _ => None
            }
            case _ => None
        }
        let eos_token: Option<String> = match (dms.get("eos_token")) {
            case data: DataModelString => Option<String>.deserialize(data)
            case data: DataModelStruct => match (data.get("content")) {
                case innerData: DataModelString => Option<String>.deserialize(innerData)
                case _ => None
            }
            case _ => None
        }
        let pad_token: Option<String> = match (dms.get("pad_token")) {
            case data: DataModelString => Option<String>.deserialize(data)
            case data: DataModelStruct => match (data.get("content")) {
                case innerData: DataModelString => Option<String>.deserialize(innerData)
                case _ => None
            }
            case _ => None
        }
        let unk_token: Option<String> = match (dms.get("unk_token")) {
            case data: DataModelString => Option<String>.deserialize(data)
            case data: DataModelStruct => match (data.get("content")) {
                case innerData: DataModelString => Option<String>.deserialize(innerData)
                case _ => None
            }
            case _ => None
        }
        let model_max_length = UInt32.deserialize(dms.get("model_max_length"))
        let tokenizer_class = String.deserialize(dms.get("tokenizer_class"))

        return BPETokenizerConfig(add_bos_token.getOrDefault({=> false}), add_eos_token.getOrDefault({=> false}),
            bos_token, eos_token, pad_token, unk_token, model_max_length, tokenizer_class)
    }
}

public class Pair<T> <: Hashable & Equatable<Pair<T>> where T <: Hashable & Equatable<T> {
    let _left: T
    let _right: T

    public init(left: T, right: T) {
        this._left = left
        this._right = right
    }

    public prop left: T {
        get() {
            this._left
        }
    }

    public prop right: T {
        get() {
            this._right
        }
    }

    public func hashCode(): Int64 {
        let hash1: Int64 = this._left.hashCode()
        let hash2: Int64 = this._right.hashCode()
        // If hash1 == hash2, their XOR is zero.
        if (hash1 != hash2) {
            return hash1 ^ hash2
        } else {
            return hash1
        }
    }

    public operator func ==(other: Pair<T>): Bool {
        if (this._left == other._left && this._right == other._right) {
            return true;
        } else {
            return false;
        }
    }
}

type BPERanks = HashMap<String, UInt32>

public type MergeMap = HashMap<Pair<UInt32>, (UInt32, UInt32)>

public abstract class AbstractBPETokenizer <: Tokenizer {
    // The _vocabulary assigns a number to each token.
    var _vocab: HashMap<String, UInt32> = HashMap()
    // Reversed _vocabulary, to rebuild sentences.
    var _vocab_r: HashMap<UInt32, String> = HashMap()
    // Contains the mapping between Pairs and their (rank, new_id).
    var _merges: MergeMap = MergeMap()
    var _bpe_ranks: BPERanks = BPERanks()
    var _unk_token_id: Option<UInt32> = None
    /// Whether or not to direct output words if they are part of the _vocab.
    var _ignore_merges: Bool = false;
    // cache
    var _cache: HashMap<String, Array<String>> = HashMap()
    // the key is uniformed special token, and value is the origin token
    // See - func unexpectedNormalize and unexpectedRestore
    var _special_tokens: HashMap<String, String> = HashMap()
    var _special_ids: HashSet<UInt32> = HashSet()
    var _byte2rune: HashMap<UInt8, Rune> = HashMap()
    var _rune2byte: HashMap<Rune, UInt8> = HashMap()
    var _special_regex: Regex = Regex("")
    // use fix pre_split_regex as default
    // same reason as func unexpectedNormalize and unexpectedRestore
    var _pre_split_regex: Regex = Regex(
        "('s|'t|'re|'ve|'m|'ll|'d| ?[[:punct:]]?[[:alpha:]]+| ?[[:punct:]]?[[:digit:]]+| ?[[:punct:]]?[^\\s\\w]+|\\s+)")
    var _add_bos_token: Bool = false
    var _add_eos_token: Bool = false
    var _bos_token: Option<String> = None
    var _eos_token: Option<String> = None

    private func uniformSpecial(token: Token): String {
        var content = unexpectedNormalize(token._content)
        if (token._lstrip) {
            content = content.trimAsciiStart()
        }
        if (token._rstrip) {
            content = content.trimAsciiEnd()
        }
        return content
    }

    /**
     * Due to the weak support for Regex in the current version, replace the common word segmentation symbols.
     * Sometimes it makes the encoded result a little different when there are special UTF - 8 characters in the input.
     * This function should be removed in future versions.
     */
    func unexpectedNormalize(token: String): String {
        return token.replace("▁", "_").replace("｜", "|")
    }

    /**
     * Due to the weak support for Regex in the current version, replace the common word segmentation symbols.
     * This function is opposed to the  function "unexpectedNormalize". it makes tokens go back to unnormalized.
     * This function should be removed in the future.
     */
    func unexpectedRestore(token: String): String {
        return this._special_tokens.get(token).getOrDefault({=> token})
    }

    func buildSepcialRegex() {
        var sb: StringBuilder = StringBuilder()
        sb.append("(")
        for ((i, spToken) in enumerate(this._special_tokens.keys())) {
            if (i < this._special_tokens.size - 1) {
                sb.append(spToken.replace("|", "\\|") + "|")
            } else {
                sb.append(spToken.replace("|", "\\|") + ")")
            }
        }
        this._special_regex = Regex(sb.toString())
    }

    public func decode(tokens: Array<UInt32>): String {
        let strList = ArrayList<String>()
        for ((i, tokenId) in enumerate(tokens)) {
            strList.append(this._vocab_r.get(tokenId).getOrThrow())
        }
        let datas = ArrayList<UInt8>()
        for (str in strList) {
            for (rune in str.toRuneArray()) {
                let byte: UInt8 = this._rune2byte[rune];
                datas.append(byte)
            }
        }
        return String.fromUtf8(datas.toArray())
    }

    public func encode(input: String): Array<UInt32> {
        // find special tokens
        var uniformed = unexpectedNormalize(input)
        let specialTokenMap = HashMap<Int64, UInt32>()
        let specialTokenIndexes = HashSet<Pair<Int64>>()
        let specMathDatas = this._special_regex.matcher(uniformed).findAll() ?? Array<MatchData>()
        var text = uniformed;
        // replace special tokens with empty blank
        for (specMd in specMathDatas) {
            let specialToken = specMd.matchStr()
            specialTokenMap.put(
                specMd.matchPosition().start,
                this._vocab.get(specialToken).getOrThrow()
            )
            specialTokenIndexes.put(Pair(specMd.matchPosition().start, specMd.matchPosition().end))
            var space = "";
            var i = 0;
            while (i < specialToken.size) {
                space += " "
                i++;
            }
            text = text.replace(specialToken, space)
        }

        let matchDatas = this._pre_split_regex.matcher(text).findAll() ?? Array<MatchData>()
        var ids = ArrayList<UInt32>()
        if (this._add_bos_token && let Some(bosToken) <- this._bos_token && let Some(bosId) <- this
            ._vocab
            .get(bosToken)) {
            ids.append(bosId)
        }
        for (matchData in matchDatas) {
            let ms = matchData.matchPosition().start;
            let me = matchData.matchPosition().end;
            let orgStr = uniformed[ms..me]
            // find special token
            if (this._special_tokens.contains(orgStr)) {
                ids.append(this._vocab[orgStr])
                continue
            }
            let matchedStr = matchData.matchStr()
            var runeLevelStr: String
            var runeList = ArrayList<String>()
            if (this._vocab.contains(matchedStr)) {
                runeList.append(matchedStr)
                runeLevelStr = matchedStr
            } else {
                for (b in matchedStr.toArray()) {
                    let rune = this._byte2rune[b];
                    runeList.append(rune.toString())
                }
                runeLevelStr = String.join(runeList.toArray())
            }

            if (this._cache.contains(runeLevelStr)) {
                let cacheLst = this._cache[runeLevelStr];
                for (cache in cacheLst) {
                    ids.append(this._vocab[cache])
                }
                continue;
            }
            let mergeVocabs = this.bpe(runeList.toArray())
            // update cache
            this._cache.put(runeLevelStr, mergeVocabs)
            for (mv in mergeVocabs) {
                try {
                    let id = this._vocab.get(mv).getOrDefault({=> this._unk_token_id.getOrThrow()})
                    ids.append(id)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        if (this._add_eos_token && let Some(eosToken) <- this._eos_token && let Some(eosId) <- this
            ._vocab
            .get(eosToken)) {
            ids.append(eosId)
        }
        return ids.toArray()
    }

    /**
     *  merge tokens and find the best tokens to get
     */
    private func bpe(tokens: Array<String>): Array<String> {
        if (tokens.size == 0) {
            return []
        }
        var finalTokens = ArrayList<String>(tokens)
        // records indices in pairs that were merged.
        while (finalTokens.size > 1) {
            let pairs: ArrayList<Pair<String>> = this.buildAdjacentConcatenations(finalTokens)
            var minScore: UInt32 = UInt32.Max;
            var toMerge: Int64 = -1;
            for ((i, pair) in enumerate(pairs)) {
                // if pair i is not merged.
                let score = this._bpe_ranks.get(pair.left + pair.right).getOrDefault({=> UInt32.Max})
                if (score < minScore) {
                    minScore = score
                    toMerge = i
                }
            }
            if (toMerge == -1) {
                break;
            }
            let bestTokens: ArrayList<String> = ArrayList<String>()
            let left = pairs[toMerge].left;
            let right = pairs[toMerge].right;
            // find all meged tokens and merge
            var i = 0
            while (i < finalTokens.size) {
                let j = find<String>(finalTokens, i, pairs[toMerge])
                if (j >= 0) {
                    bestTokens.appendAll(finalTokens[i..j])
                    bestTokens.append(left + right)
                    i = j + 2
                } else {
                    bestTokens.appendAll(finalTokens[i..])
                    break;
                }
            }
            finalTokens = bestTokens
        }
        return finalTokens.toArray()
    }

    private func find<T>(arr: ArrayList<T>, index: Int64, target: Pair<T>): Int64 where T <: Hashable & Equatable<T> {
        for (i in index..arr.size - 1) {
            if (arr[i] == target.left && arr[i + 1] == target.right) {
                return i;
            }
        }
        return -1;
    }

    /**
     *  ['a','b','c'] -> [('a','b'),('b','c')]
     */
    private func buildAdjacentConcatenations(tokens: ArrayList<String>): ArrayList<Pair<String>> {
        var pairs: ArrayList<Pair<String>> = ArrayList<Pair<String>>()
        if (tokens.size <= 1) {
            return pairs
        }
        for (i in 0..tokens.size - 1) {
            pairs.append(Pair<String>(tokens[i].toString(), tokens[i + 1].toString()))
        }
        return pairs;
    }
}
