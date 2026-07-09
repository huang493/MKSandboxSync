import Foundation

final class MKSRouteHandler {
    private let configuration: MKSandboxSyncConfiguration
    private let fileProvider: MKSFileProvider
    private let defaultsProvider = MKSUserDefaultsProvider()

    init(configuration: MKSandboxSyncConfiguration) {
        self.configuration = configuration
        self.fileProvider = MKSFileProvider(roots: configuration.allowedRoots)
    }

    func handle(_ request: MKSHTTPRequest) -> MKSHTTPResponse {
        if request.method == "OPTIONS" {
            return .text("")
        }

        guard authorize(request) else {
            return .error(statusCode: 401, message: "Invalid or missing pairing token.")
        }

        do {
            switch (request.method, request.path) {
            case ("GET", "/"), ("GET", "/mkss/console"):
                return .html(MKSWebConsolePage.html)
            case ("GET", "/mkss/health"):
                return .json(MKSStatusPayload(ok: true, name: "MKSandboxSync"))
            case ("GET", "/mkss/manifest"):
                return .json(manifest())
            case ("GET", "/mkss/files"):
                return .json(try fileProvider.list(path: request.queryItems["path"] ?? "/"))
            case ("GET", "/mkss/stat"):
                return .json(try fileProvider.info(path: request.queryItems["path"] ?? "/"))
            case ("GET", "/mkss/file"):
                let path = request.queryItems["path"] ?? "/"
                return .data(try fileProvider.read(path: path), contentType: contentType(for: path))
            case ("GET", "/mkss/plist"):
                return .json(try fileProvider.readPlist(path: request.queryItems["path"] ?? "/"))
            case ("PUT", "/mkss/file"):
                try fileProvider.write(path: request.queryItems["path"] ?? "/", data: request.body)
                return .json(MKSOKPayload(ok: true))
            case ("PUT", "/mkss/plist"):
                try fileProvider.writePlist(path: request.queryItems["path"] ?? "/", jsonData: request.body)
                refreshDefaultsIfNeeded(for: request.queryItems["path"] ?? "/")
                return .json(MKSOKPayload(ok: true))
            case ("POST", "/mkss/directory"):
                try fileProvider.createDirectory(path: request.queryItems["path"] ?? "/")
                return .json(MKSOKPayload(ok: true))
            case ("DELETE", "/mkss/file"):
                try fileProvider.delete(path: request.queryItems["path"] ?? "/")
                return .json(MKSOKPayload(ok: true))
            case ("GET", "/mkss/defaults"):
                return .json(defaultsProvider.snapshot())
            case ("POST", "/mkss/defaults"):
                let payload = try MKSDefaultsMutation.decode(from: request.body)
                try defaultsProvider.set(key: payload.key, value: payload.value)
                return .json(MKSOKPayload(ok: true))
            case ("DELETE", "/mkss/defaults"):
                guard let key = request.queryItems["key"], !key.isEmpty else {
                    return .error(statusCode: 400, message: "Missing key.")
                }
                defaultsProvider.delete(key: key)
                return .json(MKSOKPayload(ok: true))
            case ("GET", "/mkss/logs"):
                return .json(MKSandboxSyncLogger.shared.snapshot())
            default:
                return .error(statusCode: 404, message: "Unknown endpoint.")
            }
        } catch {
            return .error(statusCode: 400, message: error.localizedDescription)
        }
    }

    private func authorize(_ request: MKSHTTPRequest) -> Bool {
        guard configuration.requiresPairingToken else { return true }
        return request.authorizationToken == configuration.pairingToken
    }

    private func manifest() -> MKSManifest {
        let bundle = Bundle.main
        return MKSManifest(
            protocolName: "mksandboxsync",
            protocolVersion: "1.0",
            appName: bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? "Unknown",
            bundleIdentifier: bundle.bundleIdentifier ?? "Unknown",
            serviceName: configuration.serviceName,
            requiresPairingToken: configuration.requiresPairingToken,
            roots: configuration.allowedRoots.map { MKSRootManifest(name: $0.name, path: "/\($0.name)") },
            shortcuts: shortcutManifests(bundleIdentifier: bundle.bundleIdentifier ?? "Unknown"),
            endpoints: [
                "GET /mkss/console",
                "GET /mkss/health",
                "GET /mkss/manifest",
                "GET /mkss/files?path=/Documents",
                "GET /mkss/stat?path=/Documents/example.json",
                "GET /mkss/file?path=/Documents/example.json",
                "GET /mkss/plist?path=/Library/Preferences/example.plist",
                "PUT /mkss/file?path=/Documents/example.json",
                "PUT /mkss/plist?path=/Library/Preferences/example.plist",
                "POST /mkss/directory?path=/Documents/NewFolder",
                "DELETE /mkss/file?path=/Documents/example.json",
                "GET /mkss/defaults",
                "POST /mkss/defaults",
                "DELETE /mkss/defaults?key=name",
                "GET /mkss/logs"
            ]
        )
    }

    private func shortcutManifests(bundleIdentifier: String) -> [MKSShortcutManifest] {
        var manifests: [MKSShortcutManifest] = []

        if let defaultPath = defaultsVirtualPath(rootName: "Library", bundleIdentifier: bundleIdentifier) {
            manifests.append(MKSShortcutManifest(name: "Default", path: defaultPath))
        }

        if let groupManifest = configuration.appGroupIdentifiers
            .compactMap({ appGroupDefaultsManifest(identifier: $0, bundleIdentifier: bundleIdentifier) })
            .first
        {
            manifests.append(groupManifest)
        }

        manifests.append(contentsOf: configuration.webConsoleShortcuts.map {
            MKSShortcutManifest(name: $0.name, path: $0.path)
        })

        return manifests
    }

    private func appGroupDefaultsManifest(identifier: String, bundleIdentifier: String) -> MKSShortcutManifest? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) != nil else {
            return nil
        }
        return MKSShortcutManifest(
            name: "Group Defaults",
            path: "/AppGroup:\(identifier)/Library/Preferences/\(bundleIdentifier).plist"
        )
    }

    private func defaultsVirtualPath(rootName: String, bundleIdentifier: String) -> String? {
        guard !bundleIdentifier.isEmpty else { return nil }
        return "/\(rootName)/Preferences/\(bundleIdentifier).plist"
    }

    private func refreshDefaultsIfNeeded(for path: String) {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        guard !bundleIdentifier.isEmpty else { return }

        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        if normalizedPath == defaultsVirtualPath(rootName: "Library", bundleIdentifier: bundleIdentifier) {
            synchronizePreferences(domain: bundleIdentifier)
            return
        }

        for identifier in configuration.appGroupIdentifiers {
            let groupPath = "/AppGroup:\(identifier)/Library/Preferences/\(bundleIdentifier).plist"
            if normalizedPath == groupPath {
                synchronizePreferences(domain: identifier)
                return
            }
        }
    }

    private func synchronizePreferences(domain: String) {
        _ = CFPreferencesAppSynchronize(domain as CFString)
        if domain == (Bundle.main.bundleIdentifier ?? "") {
            UserDefaults.standard.synchronize()
        } else if let defaults = UserDefaults(suiteName: domain) {
            defaults.synchronize()
        }
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        MKSandboxSyncLogger.shared.log("Reloaded preferences for domain \(domain).")
    }

    private func contentType(for path: String) -> String {
        let ext = (path as NSString).pathExtension.lowercased()
        switch ext {
        case "json": return "application/json; charset=utf-8"
        case "txt", "log": return "text/plain; charset=utf-8"
        case "html": return "text/html; charset=utf-8"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "bmp": return "image/bmp"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "m4v": return "video/x-m4v"
        case "webm": return "video/webm"
        case "mp3": return "audio/mpeg"
        case "m4a": return "audio/mp4"
        case "aac": return "audio/aac"
        case "wav": return "audio/wav"
        case "flac": return "audio/flac"
        case "ogg", "oga": return "audio/ogg"
        case "plist": return "application/x-plist"
        default: return "application/octet-stream"
        }
    }
}

private struct MKSStatusPayload: Codable {
    let ok: Bool
    let name: String
}

private struct MKSOKPayload: Codable {
    let ok: Bool
}

struct MKSManifest: Codable {
    let protocolName: String
    let protocolVersion: String
    let appName: String
    let bundleIdentifier: String
    let serviceName: String
    let requiresPairingToken: Bool
    let roots: [MKSRootManifest]
    let shortcuts: [MKSShortcutManifest]
    let endpoints: [String]
}

struct MKSRootManifest: Codable {
    let name: String
    let path: String
}

struct MKSShortcutManifest: Codable {
    let name: String
    let path: String
}

struct MKSDefaultsMutation {
    let key: String
    let value: Any

    static func decode(from data: Data) throws -> MKSDefaultsMutation {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any],
              let key = dictionary["key"] as? String,
              !key.isEmpty,
              let value = dictionary["value"] else {
            throw MKSandboxSyncError.invalidRequest("Expected JSON body: {\"key\":\"name\",\"value\":...}.")
        }
        return MKSDefaultsMutation(key: key, value: MKSPlistValueCoding.denormalize(value))
    }
}
