package magic.mcp

import magic.core.tool.Tool
import magic.jsonable.*
import magic.log.LogUtils
import magic.core.ToolResponse

import std.collection.{ArrayList, HashMap, map, collectArray}
import stdx.encoding.json.{JsonValue, JsonObject, JsonString}


public class HTMLUIMCPClient <: AbsMCPClient {
    override protected func doSend(req: JsonObject): Bool {
        return false
    }

    override protected func doRecv(): Option<String> {
        return "mock HTMLUIMCPClient"
    }

    override public prop initParams: JsonObject {
        get() {
            let jo = JsonObject()
            return jo
        }
    }

    public func callUI(names: Array<String>, args: Array<Array<(String, JsonValue)>>, title: String, tools: Array<Tool>): ToolResponse {
        this.doBeforeRequest()
        // Prepare the request
        let argsArr = ArrayList<JsonObject>()
        for (arg in args) {
            let arguments = HashMap<String, JsonValue>(arg)
            argsArr.add(JsonObject(arguments))
        }
        let req = CallHTMLUIRequest(
            params: CallUIParams(
                names: names,
                title: title,
                combMode: 'Column',
                arguments: if (args.isEmpty()) { None } else { argsArr.toArray() }
            )
        )
        let params = req.params.toJsonValue()
        let reqMsg = '{"jsonrpc":"2.0","id":1,"method":"htmlui/call","params":${params}}'
        let msg = HTMLUIMCPServer(tools).handleRequestMessage(reqMsg)
        let resp = CallUIResponse.fromJsonValue(msg.getOrThrow().toJsonValue())
        // Merge all result content
        let result = resp.result
        let strBuilder = StringBuilder()
        for (content in result.content) {
            strBuilder.append(content.getValue())
            strBuilder.append("\n")
        }
        if ((result.isError ?? false)) {
            return ToolResponse(strBuilder.toString(), isError: true)
        } else {
            return ToolResponse(strBuilder.toString(), isError: false)
        }
    }
}