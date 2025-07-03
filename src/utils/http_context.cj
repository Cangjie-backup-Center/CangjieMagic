package magic.utils

import stdx.net.http.*

protected interface HttpContextExi {
    func UpgroudeSSE(): Unit
    func sendEvent(): HttpResponseWriter
}

extend HttpContext <: HttpContextExi {
    public func UpgroudeSSE(): Unit {
        this.responseBuilder.header("Content-Type", "text/event-stream")
        this.responseBuilder.header("Cache-Control", "no-cache")
        this.responseBuilder.header("Connection", "keep-alive")
        this.responseBuilder.header("Transfer-Encoding", "chunked")
        this.responseBuilder.header("Access-Control-Allow-Origin", "*")
        this.responseBuilder.status(200)
    }

    public func sendEvent(): HttpResponseWriter {
        return HttpResponseWriter(this)
    }
}
