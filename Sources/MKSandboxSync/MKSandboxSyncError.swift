import Foundation

enum MKSandboxSyncError: LocalizedError {
    case invalidRequest(String)
    case pathOutsideAllowedRoots(String)
    case fileNotFound(String)
    case unsupportedDefaultsValue

    var errorDescription: String? {
        switch self {
        case let .invalidRequest(message):
            return message
        case let .pathOutsideAllowedRoots(path):
            return "Path is outside allowed sandbox roots: \(path)"
        case let .fileNotFound(path):
            return "File not found: \(path)"
        case .unsupportedDefaultsValue:
            return "UserDefaults value must be JSON-compatible."
        }
    }
}
