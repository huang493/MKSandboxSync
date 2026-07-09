import Foundation

public final class MKSandboxSync {
    public static let shared = MKSandboxSync()

    private let lock = NSLock()
    private var server: MKSHTTPServer?
    private(set) var configuration: MKSandboxSyncConfiguration = .default

    public private(set) var isRunning = false
    public private(set) var currentPort: UInt16?

    private init() {}

    public func start(configuration: MKSandboxSyncConfiguration = .default) throws {
        lock.lock()
        defer { lock.unlock() }

        guard !isRunning else { return }

        guard configuration.allowInReleaseBuild || _isDebugAssertConfiguration() else {
            MKSandboxSyncLogger.shared.log("MKSandboxSync ignored start outside a debug build.")
            return
        }

        self.configuration = configuration
        let router = MKSRouteHandler(configuration: configuration)
        let server = try MKSHTTPServer(configuration: configuration, router: router)
        try server.start()
        self.server = server
        self.currentPort = server.port
        self.isRunning = true

        logUnavailableAppGroups(configuration.appGroupIdentifiers, activeRoots: configuration.allowedRoots)
        logStartupLinks(port: server.port)
        if configuration.requiresPairingToken {
            MKSandboxSyncLogger.shared.log("Pairing token: \(configuration.pairingToken)")
        }
    }

    public func stop() {
        lock.lock()
        defer { lock.unlock() }

        server?.stop()
        server = nil
        isRunning = false
        currentPort = nil
        MKSandboxSyncLogger.shared.log("MKSandboxSync stopped.")
    }

    public func log(_ message: String) {
        MKSandboxSyncLogger.shared.log(message)
    }

    private func logUnavailableAppGroups(_ identifiers: [String], activeRoots: [MKSandboxRoot]) {
        guard !identifiers.isEmpty else { return }
        let activeNames = Set(activeRoots.map(\.name))
        for identifier in identifiers {
            let rootName = "AppGroup:\(identifier)"
            if activeNames.contains(rootName) {
                MKSandboxSyncLogger.shared.log("App Group enabled: /\(rootName)")
            } else {
                MKSandboxSyncLogger.shared.log("App Group unavailable: \(identifier). Check entitlements and provisioning.")
            }
        }
    }

    private func logStartupLinks(port: UInt16?) {
        guard let port else {
            MKSandboxSyncLogger.shared.log("MKSandboxSync started, but no port is available yet.")
            return
        }

        MKSandboxSyncLogger.shared.log("MKSandboxSync started on port \(port).")

        let hosts = MKSNetworkAddressProvider.webHosts()
        guard !hosts.isEmpty else {
            MKSandboxSyncLogger.shared.log("No local IPv4 address found. Check Wi-Fi/local network status.")
            return
        }

        for host in hosts {
            let baseURL = "http://\(host):\(port)"
            MKSandboxSyncLogger.shared.log("Web console: \(baseURL)/mkss/console")
            MKSandboxSyncLogger.shared.log("Manifest: \(baseURL)/mkss/manifest")
            MKSandboxSyncLogger.shared.log("Files: \(baseURL)/mkss/files?path=/Documents")
            MKSandboxSyncLogger.shared.log("UserDefaults: \(baseURL)/mkss/defaults")
            MKSandboxSyncLogger.shared.log("Logs: \(baseURL)/mkss/logs")
        }
    }
}

public extension MKSandboxSync {
    var webConsole: [String] {
        let port = MKSandboxSync.shared.currentPort ?? 0
        return MKSNetworkAddressProvider.webHosts().map { host in
            "http://\(host):\(port)"
        }
    }
}
