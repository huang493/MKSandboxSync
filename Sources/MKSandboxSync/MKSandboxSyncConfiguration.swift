import Foundation

public struct MKSandboxSyncConfiguration {
    public var serviceName: String
    public var port: UInt16
    public var enablesBonjour: Bool
    public var requiresPairingToken: Bool
    public var pairingToken: String
    public var allowInReleaseBuild: Bool
    public var allowedRoots: [MKSandboxRoot]
    public var appGroupIdentifiers: [String]

    public init(
        serviceName: String = "MKSandboxSync",
        port: UInt16 = 0,
        enablesBonjour: Bool = true,
        requiresPairingToken: Bool = false,
        pairingToken: String = UUID().uuidString,
        allowInReleaseBuild: Bool = false,
        allowedRoots: [MKSandboxRoot] = MKSandboxRoot.defaultRoots,
        appGroupIdentifiers: [String] = []
    ) {
        self.serviceName = serviceName
        self.port = port
        self.enablesBonjour = enablesBonjour
        self.requiresPairingToken = requiresPairingToken
        self.pairingToken = pairingToken
        self.allowInReleaseBuild = allowInReleaseBuild
        self.appGroupIdentifiers = appGroupIdentifiers
        self.allowedRoots = allowedRoots + appGroupIdentifiers.compactMap(MKSandboxRoot.appGroup(identifier:))
    }

    public static let `default` = MKSandboxSyncConfiguration()
}

public struct MKSandboxRoot: Hashable {
    public let name: String
    public let url: URL

    public init(name: String, url: URL) {
        self.name = name
        self.url = url.standardizedFileURL
    }

    public static var documents: MKSandboxRoot {
        MKSandboxRoot(
            name: "Documents",
            url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        )
    }

    public static var library: MKSandboxRoot {
        MKSandboxRoot(
            name: "Library",
            url: FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        )
    }

    public static var caches: MKSandboxRoot {
        MKSandboxRoot(
            name: "Caches",
            url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        )
    }

    public static var applicationSupport: MKSandboxRoot {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return MKSandboxRoot(name: "ApplicationSupport", url: url)
    }

    public static var temporary: MKSandboxRoot {
        MKSandboxRoot(name: "tmp", url: URL(fileURLWithPath: NSTemporaryDirectory()))
    }

    public static func appGroup(identifier: String) -> MKSandboxRoot? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            return nil
        }
        return MKSandboxRoot(name: "AppGroup:\(identifier)", url: url)
    }

    public static var defaultRoots: [MKSandboxRoot] {
        [.documents, .library, .caches, .applicationSupport, .temporary]
    }
}
