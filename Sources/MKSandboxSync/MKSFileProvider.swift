import Foundation

final class MKSFileProvider {
    private let roots: [MKSandboxRoot]
    private let fileManager = FileManager.default

    init(roots: [MKSandboxRoot]) {
        self.roots = roots
    }

    func list(path: String) throws -> MKSDirectoryListing {
        let resolved = try resolve(path: path)
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: resolved.url.path, isDirectory: &isDirectory),
           resolved.relativeComponents.isEmpty {
            try fileManager.createDirectory(at: resolved.url, withIntermediateDirectories: true)
            isDirectory = true
        }

        guard fileManager.fileExists(atPath: resolved.url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw MKSandboxSyncError.fileNotFound(path)
        }

        let urls = try fileManager.contentsOfDirectory(
            at: resolved.url,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        )

        let entries = try urls.map { url in
            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey])
            return MKSFileEntry(
                name: url.lastPathComponent,
                path: resolved.virtualPath(for: url),
                isDirectory: values.isDirectory ?? false,
                size: values.fileSize ?? 0,
                modifiedAt: values.contentModificationDate,
                createdAt: values.creationDate
            )
        }
        .sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory && !rhs.isDirectory }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return MKSDirectoryListing(path: resolved.virtualPath, entries: entries)
    }

    func read(path: String) throws -> Data {
        let resolved = try resolve(path: path)
        guard fileManager.fileExists(atPath: resolved.url.path) else {
            throw MKSandboxSyncError.fileNotFound(path)
        }
        return try Data(contentsOf: resolved.url)
    }

    func info(path: String) throws -> MKSFileEntry {
        let resolved = try resolve(path: path)
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: resolved.url.path, isDirectory: &isDirectory) else {
            throw MKSandboxSyncError.fileNotFound(path)
        }

        let values = try resolved.url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey])
        return MKSFileEntry(
            name: resolved.url.lastPathComponent.isEmpty ? resolved.root.name : resolved.url.lastPathComponent,
            path: resolved.virtualPath,
            isDirectory: values.isDirectory ?? isDirectory.boolValue,
            size: values.fileSize ?? 0,
            modifiedAt: values.contentModificationDate,
            createdAt: values.creationDate
        )
    }

    func readPlist(path: String) throws -> MKSPlistPayload {
        let data = try read(path: path)
        var format = PropertyListSerialization.PropertyListFormat.binary
        let object = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)
        return MKSPlistPayload(
            format: format.debugName,
            value: MKSAnyCodable(MKSPlistValueCoding.normalize(object))
        )
    }

    func write(path: String, data: Data) throws {
        let resolved = try resolve(path: path, allowsMissingLeaf: true)
        let parent = resolved.url.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        try data.write(to: resolved.url, options: [.atomic])
        MKSandboxSyncLogger.shared.log("Wrote \(data.count) bytes to \(resolved.virtualPath).")
    }

    func writePlist(path: String, jsonData: Data) throws {
        let object = try JSONSerialization.jsonObject(with: jsonData)
        guard JSONSerialization.isValidJSONObject(object) else {
            throw MKSandboxSyncError.invalidRequest("Plist JSON must be a dictionary or array.")
        }
        let plistObject = MKSPlistValueCoding.denormalize(object)
        let data = try PropertyListSerialization.data(fromPropertyList: plistObject, format: .xml, options: 0)
        try write(path: path, data: data)
    }

    func createDirectory(path: String) throws {
        let resolved = try resolve(path: path, allowsMissingLeaf: true)
        guard !resolved.relativeComponents.isEmpty else {
            throw MKSandboxSyncError.invalidRequest("Creating a sandbox root is not allowed.")
        }
        try fileManager.createDirectory(at: resolved.url, withIntermediateDirectories: true)
        MKSandboxSyncLogger.shared.log("Created directory \(resolved.virtualPath).")
    }

    func delete(path: String) throws {
        let resolved = try resolve(path: path)
        guard !resolved.relativeComponents.isEmpty else {
            throw MKSandboxSyncError.invalidRequest("Deleting a sandbox root is not allowed.")
        }
        try fileManager.removeItem(at: resolved.url)
        MKSandboxSyncLogger.shared.log("Deleted \(resolved.virtualPath).")
    }

    private func resolve(path: String, allowsMissingLeaf: Bool = false) throws -> MKSResolvedPath {
        let normalized = normalize(path: path)
        guard let rootName = normalized.first,
              let root = roots.first(where: { $0.name == rootName }) else {
            throw MKSandboxSyncError.pathOutsideAllowedRoots(path)
        }

        let relative = Array(normalized.dropFirst())
        let rootURL = root.url.resolvingSymlinksInPath().standardizedFileURL
        let candidate = relative.reduce(rootURL) { partial, component in
            partial.appendingPathComponent(component)
        }.standardizedFileURL

        let checkedURL: URL
        if allowsMissingLeaf {
            checkedURL = candidate.deletingLastPathComponent().resolvingSymlinksInPath().standardizedFileURL
        } else {
            checkedURL = candidate.resolvingSymlinksInPath().standardizedFileURL
        }

        guard checkedURL.path == rootURL.path || checkedURL.path.hasPrefix(rootURL.path + "/") else {
            throw MKSandboxSyncError.pathOutsideAllowedRoots(path)
        }

        return MKSResolvedPath(root: root, rootURL: rootURL, url: candidate, relativeComponents: relative)
    }

    private func normalize(path: String) -> [String] {
        path
            .split(separator: "/")
            .map(String.init)
            .filter { !$0.isEmpty && $0 != "." && $0 != ".." }
    }
}

private struct MKSResolvedPath {
    let root: MKSandboxRoot
    let rootURL: URL
    let url: URL
    let relativeComponents: [String]

    var virtualPath: String {
        ([root.name] + relativeComponents).joined(separator: "/").prefixedSlash
    }

    func virtualPath(for childURL: URL) -> String {
        let childPath = childURL.resolvingSymlinksInPath().standardizedFileURL.path
        let relative = childPath.dropFirst(rootURL.path.count)
        let suffix = relative.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if suffix.isEmpty {
            return "/\(root.name)"
        }
        return "/\(root.name)/\(suffix)"
    }
}

private extension String {
    var prefixedSlash: String {
        hasPrefix("/") ? self : "/" + self
    }
}

struct MKSDirectoryListing: Codable {
    let path: String
    let entries: [MKSFileEntry]
}

struct MKSFileEntry: Codable {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int
    let modifiedAt: Date?
    let createdAt: Date?
}

struct MKSPlistPayload: Encodable {
    let format: String
    let value: MKSAnyCodable
}

private extension PropertyListSerialization.PropertyListFormat {
    var debugName: String {
        switch self {
        case .openStep:
            return "openStep"
        case .xml:
            return "xml"
        case .binary:
            return "binary"
        @unknown default:
            return "unknown"
        }
    }
}
