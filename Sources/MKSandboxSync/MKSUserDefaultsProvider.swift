import Foundation

final class MKSUserDefaultsProvider {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func snapshot() -> [String: MKSAnyCodable] {
        defaults.dictionaryRepresentation()
            .filter { MKSAnyCodable.isSupported($0.value) }
            .mapValues { MKSAnyCodable(MKSPlistValueCoding.normalize($0)) }
    }

    func set(key: String, value: Any) throws {
        guard MKSAnyCodable.isSupported(value) else {
            throw MKSandboxSyncError.unsupportedDefaultsValue
        }
        defaults.set(MKSPlistValueCoding.denormalize(value), forKey: key)
        MKSandboxSyncLogger.shared.log("Set UserDefaults key \(key).")
    }

    func delete(key: String) {
        defaults.removeObject(forKey: key)
        MKSandboxSyncLogger.shared.log("Deleted UserDefaults key \(key).")
    }
}

struct MKSAnyCodable: Encodable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let value as String:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as Float:
            try container.encode(Double(value))
        case let value as Bool:
            try container.encode(value)
        case let value as Data:
            try container.encode(MKSPlistValueCoding.normalize(value) as? [String: String] ?? [:])
        case let value as Date:
            try container.encode(MKSPlistValueCoding.normalize(value) as? [String: String] ?? [:])
        case let value as [Any]:
            try container.encode(value.map(MKSAnyCodable.init))
        case let value as [String: Any]:
            try container.encode(value.mapValues(MKSAnyCodable.init))
        case is NSNull:
            try container.encodeNil()
        default:
            try container.encode(String(describing: value))
        }
    }

    static func isSupported(_ value: Any) -> Bool {
        switch value {
        case is String, is Int, is Double, is Float, is Bool, is Date, is Data, is NSNull:
            return true
        case let array as [Any]:
            return array.allSatisfy(isSupported)
        case let dictionary as [String: Any]:
            return dictionary.values.allSatisfy(isSupported)
        default:
            return false
        }
    }
}
