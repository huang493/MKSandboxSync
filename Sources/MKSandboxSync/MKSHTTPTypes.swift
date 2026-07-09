import Foundation

struct MKSHTTPRequest {
    let method: String
    let path: String
    let queryItems: [String: String]
    let headers: [String: String]
    let body: Data

    var authorizationToken: String? {
        headers["x-mksandbox-token"] ?? queryItems["token"]
    }
}

struct MKSHTTPResponse {
    let statusCode: Int
    let reason: String
    let headers: [String: String]
    let body: Data

    init(statusCode: Int, reason: String, headers: [String: String] = [:], body: Data = Data()) {
        self.statusCode = statusCode
        self.reason = reason
        self.headers = headers
        self.body = body
    }

    static func json<T: Encodable>(_ value: T, statusCode: Int = 200, reason: String = "OK") -> MKSHTTPResponse {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let body = try encoder.encode(value)
            return MKSHTTPResponse(
                statusCode: statusCode,
                reason: reason,
                headers: ["Content-Type": "application/json; charset=utf-8"],
                body: body
            )
        } catch {
            return .error(statusCode: 500, message: "JSON encoding failed: \(error.localizedDescription)")
        }
    }

    static func data(_ data: Data, contentType: String = "application/octet-stream") -> MKSHTTPResponse {
        MKSHTTPResponse(
            statusCode: 200,
            reason: "OK",
            headers: ["Content-Type": contentType],
            body: data
        )
    }

    static func text(_ text: String, statusCode: Int = 200, reason: String = "OK") -> MKSHTTPResponse {
        MKSHTTPResponse(
            statusCode: statusCode,
            reason: reason,
            headers: ["Content-Type": "text/plain; charset=utf-8"],
            body: Data(text.utf8)
        )
    }

    static func html(_ html: String, statusCode: Int = 200, reason: String = "OK") -> MKSHTTPResponse {
        MKSHTTPResponse(
            statusCode: statusCode,
            reason: reason,
            headers: ["Content-Type": "text/html; charset=utf-8"],
            body: Data(html.utf8)
        )
    }

    static func error(statusCode: Int, message: String) -> MKSHTTPResponse {
        json(MKSErrorPayload(ok: false, error: message), statusCode: statusCode, reason: HTTPURLResponse.localizedString(forStatusCode: statusCode))
    }

    func serialized() -> Data {
        var responseHeaders = headers
        responseHeaders["Content-Length"] = "\(body.count)"
        responseHeaders["Connection"] = "close"
        responseHeaders["Access-Control-Allow-Origin"] = "*"
        responseHeaders["Access-Control-Allow-Headers"] = "Content-Type, X-MKSandbox-Token"
        responseHeaders["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"

        var head = "HTTP/1.1 \(statusCode) \(reason)\r\n"
        for (key, value) in responseHeaders.sorted(by: { $0.key < $1.key }) {
            head += "\(key): \(value)\r\n"
        }
        head += "\r\n"

        var data = Data(head.utf8)
        data.append(body)
        return data
    }
}

private struct MKSErrorPayload: Codable {
    let ok: Bool
    let error: String
}
