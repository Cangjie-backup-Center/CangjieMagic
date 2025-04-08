package magic.tokenizer

public class BPETokenizer <: AbstractBPETokenizer {
    let _tokenizer_json: TokenizerJson
    let _tokenizer_config: BPETokenizerConfig

    public init(modelPath: String) {
        // load config from tokenizer.json
        if (!exists(modelPath)) {
            throw Exception("modelPath file:${modelPath} dos not exists")
        }
        this._tokenizer_json = TokenizerJson.fromJson(String.fromUtf8(readFile(Path(modelPath).join("tokenizer.json"))))
        this._tokenizer_config = BPETokenizerConfig.fromJson(
            String.fromUtf8(readFile(Path(modelPath).join("tokenizer_config.json"))))
        this._add_bos_token = this._tokenizer_config._add_bos_token
        this._add_eos_token = this._tokenizer_config._add_eos_token
        this._bos_token = this._tokenizer_config._bos_token
        this._eos_token = this._tokenizer_config._eos_token
        this.popRuneBiMapping()
        this.popVocab()
        this.popMergesAndBpeRanks()
        this.buildSepcialRegex()
    }

    /**
     *  get Byte <=> Rune bidirectional mapping
     */
    func popRuneBiMapping(): Unit {
        var bs: ArrayList<UInt8> = ArrayList<UInt8>()
        var cs: ArrayList<UInt32> = ArrayList<UInt32>()
        var ts: Rune = '!';
        var te: Rune = '~';
        for (x in UInt32(ts)..=UInt32(te)) {
            bs.append(UInt8(x))
            cs.append(x)
        }
        ts = '\u{A1}'
        te = '\u{AC}'
        for (x in UInt32(ts)..=UInt32(te)) {
            bs.append(UInt8(x))
            cs.append(x)
        }
        ts = '\u{AE}'
        te = '\u{FF}'
        for (x in UInt32(ts)..=UInt32(te)) {
            bs.append(UInt8(x))
            cs.append(x)
        }
        var n: UInt32 = 0;
        for (b in 0_u8..=255_u8) {
            if (!bs.contains(b)) {
                bs.append(b)
                cs.append(UInt32(pow(2.0, 8)) + n)
                n += 1
            }
        }
        var result: HashMap<UInt8, Rune> = HashMap<UInt8, Rune>()
        var resultR: HashMap<Rune, UInt8> = HashMap<Rune, UInt8>()
        for ((k, v) in bs.iterator().zip(cs.iterator())) {
            result.put(k, Rune(v))
            resultR.put(Rune(v), k)
        }
        this._byte2rune = result
        this._rune2byte = resultR
    }

    private func popVocab(): Unit {
        this._vocab = this._tokenizer_json._model._vocab
        for (add_token in this._tokenizer_json._added_tokens) {
            this._vocab.put(uniformSpecial(add_token), add_token._id)
            // All add tokens are seemed as special in current version
            this._special_tokens.put(uniformSpecial(add_token), add_token._content)
            this._special_ids.put(add_token._id)
        }
        if (let Some(unkToken) <- this._tokenizer_json._model._unk_token) {
            this._unk_token_id = this._vocab.get(unkToken)
        }

        for ((token, id) in this._tokenizer_json._model._vocab) {
            this._vocab_r.put(id, token)
        }
    }

    private func popMergesAndBpeRanks(): Unit {
        let mergeList: ArrayList<(String, String)> = ArrayList<(String, String)>()
        for (line in this._tokenizer_json._model._merges) {
            let tokenPair = line.split(" ")
            if (tokenPair.size != 2) {
                throw Exception("merge line size must be two")
            }
            mergeList.append((tokenPair[0], tokenPair[1]))
        }
        let prefixLen = this._tokenizer_json._model._continuing_subword_prefix.size;
        for ((i, (left, right)) in enumerate(mergeList)) {
            let iU = UInt32(i)
            let lId: UInt32 = this._vocab.get(left).getOrThrow()
            let rId: UInt32 = this._vocab.get(right).getOrThrow()
            let mergedToken: String = "${left}${right[prefixLen..]}";
            let mergedId: UInt32 = this._vocab.get(mergedToken).getOrThrow()
            this._merges.put(Pair<UInt32>(lId, rId), (iU, mergedId))
            this._bpe_ranks.put(left + right, iU)
        }
    }

    private func uniformSpecial(token: Token): String {
        var content = unexpectedNormalize(token._content)
        if (token._lstrip) {
            content = content.trimAsciiLeft()
        }
        if (token._rstrip) {
            content = content.trimAsciiRight()
        }
        return content
    }
}
