package magic.mcp

import stdx.net.http.*
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.random.*
import std.time.*
import magic.core.agent.Agent
import magic.tool.AgentAsTool
import magic.log.LogUtils
import magic.jsonable.*
import magic.core.tool.Tool
import magic.utils.HttpContextExi

public class SseMCPServer <: AbsMCPServer {
    var client_map = ConcurrentHashMap<String, HttpResponseWriter>()

    public init(tools: Array<Tool>) {
        super(tools)
    }

    private func getRandomString(): String {
        let chars: Array<Rune> = [
            r'A', r'B', r'C', r'D', r'E', r'F', r'G', r'H', r'I',
            r'J', r'K', r'L', r'M', r'N', r'O', r'P', r'Q', r'R',
            r'S', r'T', r'U', r'V', r'W', r'X', r'Y', r'Z', r'a',
            r'b', r'c', r'd', r'e', r'f', r'g', r'h', r'i', r'j', 
            r'k', r'l', r'm', r'n', r'o', r'p', r'q', r's', r't',
            r'u', r'v', r'w', r'x', r'y', r'z', r'0', r'1', r'2',
            r'3', r'4', r'5', r'6', r'7', r'8', r'9'
        ]

        let random = Random()
        let buffer = StringBuilder()

        for (_ in 0..12) {
            let index = random.nextInt64(chars.size)
            buffer.append(chars[index])
        }

        return buffer.toString()
    }

    public func start(host: String, port: UInt16): Unit {
        let http_server = ServerBuilder().addr(host).port(port).build()

        var sse: HttpRequestHandler = FuncHandler(
            {
                httpContext =>
                if (httpContext.request.method != "GET") {
                    return
                }

                httpContext.UpgroudeSSE()

                let w = httpContext.sendEvent()
                let uuid = this.getRandomString()

                w.write("event: endpoint\ndata: /messages/?session_id=${uuid}\n\n".toArray())
                this.client_map.add(uuid, w)

                while (true) {
                    sleep(Duration.second * 8)
                    try {
                        w.write(": ping - ${DateTime.now()}\n\n".toArray())
                    } catch (e: Exception) {
                        LogUtils.error("Client: ${uuid} ${e.message}")
                        this.client_map.remove(uuid)
                        break
                    }
                }
            }
        )

        var messages: HttpRequestHandler = FuncHandler(
            {
                httpContext =>
                if (httpContext.request.method != "POST") {
                    return
                }

                let qurey = httpContext.request.url.queryForm
                let length = httpContext.request.bodySize

                let stream = Array<UInt8>(length.getOrThrow(), repeat: 0)
                httpContext.request.body.read(stream)

                let msg = String.fromUtf8(stream)
                let uuid = qurey.get("session_id").getOrThrow().toString()

                LogUtils.info("Recv: ${uuid}: ${msg}")

                httpContext.responseBuilder.status(202)
                httpContext.responseBuilder.body("Accepted")

                spawn {
                    this.loop(msg, uuid)
                }
            }
        )

        http_server.distributor.register("/sse", sse)
        http_server.distributor.register("/messages/", messages)

        http_server.serve()
    }

    public func loop(msg: String, uuid: String): Unit {
        if (let Some(resp) <- this.handleRequestMessage(msg)) {
            this.send(resp, uuid)
        }
    }

    private func send(msg: String, uuid: String): Unit {
        LogUtils.info("Send: ${uuid}: ${msg}")
        client_map.get(uuid).getOrThrow().write("event: message\ndata: ${msg}\n\n".toArray())
    }

    private func send<T>(response: T, uuid: String): Unit where T <: ToJsonValue {
        this.send(response.toJsonValue().toString(), uuid)
    }

    protected override func send(msg: String): Unit {
        throw Exception("Implementation")
    }

    protected override func recv(): Option<String> {
        throw Exception("Implementation")
    }

    public static func startWith(agents: Array<Agent>, host: String, port: UInt16): Unit {
        let allTools = ArrayList<Tool>()
        for (agent in agents) {
            allTools.add(all: agent.toolManager.getTools())
            // The agent itself is also a tool
            allTools.add(AgentAsTool(agent))
        }
        let server = SseMCPServer(allTools.toArray())
        server.start(host, port)
    }

    public static func startWith(tools: Array<Tool>, host: String, port: UInt16): Unit {
        let server = SseMCPServer(tools)
        server.start(host, port)
    }
}
