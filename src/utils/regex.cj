package magic.utils

import std.regex.*
import std.collection.*

public func splitByMarkers(content: String, markers: Array<String>): Array<String> {
    if (markers.isEmpty()) {
        return [content]
    }
    let re = Regex(String.join(markers |> map({marker => escape(marker)})|> collectArray, delimiter: "|"))
    let matches = re.matcher(content).findAll() ?? Array<MatchData>()
    let splits = ArrayList<String>()
    var index = 0
    for (md in matches) {
        let position = md.matchPosition()
        splits.append(content[index..position.start])
        index = position.end
    }
    let lastSplit = content[index..content.size]
    if (lastSplit.size > 0) {
        splits.append(lastSplit)
    }
    splits.toArray()
}

public func escape(input: String): String {
    var specialCharacters = ##"[\.\^\$\|\?\*\+\(\)\[\]\{\}]"##
    var regex = Regex(specialCharacters)
    var matcher = regex.matcher(input)
    let matchDatas = matcher.findAll().getOrDefault({=> Array<MatchData>()})
    var output = ArrayList<Byte>(input.toArray())
    for (i in matchDatas.size - 1..=0 : -1) {
        var matchData = matchDatas[i]
        var matchStr = matchData.matchStr()
        output.insert(matchData.matchPosition().start, b'\\')
    }
    return String.fromUtf8(output.toArray())
}

public func regSearch(content: String, pattern: String, group!: Int64 = 0): Option<String> {
    var re = Regex(pattern)
    match (re.matches(content)) {
        case Some(r) => r.matchStr(group)
        case None => None
    }
}