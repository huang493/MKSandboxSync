import Foundation
import Network

final class MKSHTTPServer {
    private let configuration: MKSandboxSyncConfiguration
    private let router: MKSRouteHandler
    private let queue = DispatchQueue(label: "com.mksandboxsync.httpserver")
    private var listener: NWListener?

    var port: UInt16? {
        listener?.port?.rawValue
    }

    init(configuration: MKSandboxSyncConfiguration, router: MKSRouteHandler) throws {
        self.configuration = configuration
        self.router = router
        let nwPort = configuration.port == 0 ? NWEndpoint.Port.any : NWEndpoint.Port(rawValue: configuration.port)!
        self.listener = try NWListener(using: .tcp, on: nwPort)
        if configuration.enablesBonjour {
            self.listener?.service = NWListener.Service(name: configuration.serviceName, type: "_mksandboxsync._tcp")
        }
    }

    func start() throws {
        guard let listener else { return }

        let readySemaphore = DispatchSemaphore(value: 0)
        let readyLock = NSLock()
        var didFinishStartup = false
        var startupError: Error?

        func finishStartup(error: Error? = nil) {
            readyLock.lock()
            defer { readyLock.unlock() }

            guard !didFinishStartup else { return }
            didFinishStartup = true
            startupError = error
            readySemaphore.signal()
        }

        listener.newConnectionHandler = { [weak self] connection in
            self?.handle(connection: connection)
        }
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                finishStartup()
            case let .failed(error):
                MKSandboxSyncLogger.shared.log("HTTP server failed: \(error)")
                finishStartup(error: MKSHTTPServerError.listenerFailed(error))
            case .cancelled:
                finishStartup(error: MKSHTTPServerError.cancelled)
            default:
                break
            }
        }
        listener.start(queue: queue)

        if readySemaphore.wait(timeout: .now() + 5) == .timedOut {
            throw MKSHTTPServerError.startTimedOut
        }

        if let startupError {
            throw startupError
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handle(connection: NWConnection) {
        connection.start(queue: queue)
        receive(on: connection, buffer: Data())
    }

    private func receive(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let error {
                MKSandboxSyncLogger.shared.log("Receive failed: \(error)")
                connection.cancel()
                return
            }

            var nextBuffer = buffer
            if let data {
                nextBuffer.append(data)
            }

            if let request = MKSHTTPParser.parse(data: nextBuffer) {
                let response = self.router.handle(request)
                connection.send(content: response.serialized(), completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            }

            if isComplete || nextBuffer.count > 10 * 1024 * 1024 {
                connection.send(content: MKSHTTPResponse.error(statusCode: 400, message: "Bad request").serialized(), completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            }

            self.receive(on: connection, buffer: nextBuffer)
        }
    }
}

private enum MKSHTTPServerError: LocalizedError {
    case startTimedOut
    case listenerFailed(Error)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .startTimedOut:
            return "MKSandboxSync HTTP server did not become ready within 5 seconds."
        case let .listenerFailed(error):
            return "MKSandboxSync HTTP server failed to start: \(error.localizedDescription)"
        case .cancelled:
            return "MKSandboxSync HTTP server was cancelled before it became ready."
        }
    }
}

enum MKSHTTPParser {
    static func parse(data: Data) -> MKSHTTPRequest? {
        guard let separatorRange = data.range(of: Data("\r\n\r\n".utf8)) else {
            return nil
        }

        let headerData = data[..<separatorRange.lowerBound]
        guard let headerText = String(data: headerData, encoding: .utf8) else {
            return nil
        }

        let lines = headerText.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else { return nil }
        let parts = requestLine.split(separator: " ", maxSplits: 2).map(String.init)
        guard parts.count >= 2 else { return nil }

        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = String(line[..<colon]).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let value = String(line[line.index(after: colon)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            headers[key] = value
        }

        let bodyStart = separatorRange.upperBound
        let contentLength = Int(headers["content-length"] ?? "0") ?? 0
        guard data.count >= bodyStart + contentLength else {
            return nil
        }

        let body = Data(data[bodyStart..<(bodyStart + contentLength)])
        let target = parts[1]
        var path = target
        var queryItems: [String: String] = [:]

        if let components = URLComponents(string: target) {
            path = components.path
            for item in components.queryItems ?? [] {
                queryItems[item.name] = item.value ?? ""
            }
        }

        return MKSHTTPRequest(
            method: parts[0].uppercased(),
            path: path,
            queryItems: queryItems,
            headers: headers,
            body: body
        )
    }
}
