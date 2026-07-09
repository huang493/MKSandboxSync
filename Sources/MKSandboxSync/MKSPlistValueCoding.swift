import Foundation

enum MKSPlistValueCoding {
    private static let formatter = ISO8601DateFormatter()

    static func normalize(_ value: Any) -> Any {
        switch value {
        case let value as Data:
            return [
                "__mks_type": "data",
                "value": value.base64EncodedString()
            ]
        case let value as Date:
            return [
                "__mks_type": "date",
                "value": formatter.string(from: value)
            ]
        case let value as [Any]:
            return value.map(normalize)
        case let value as [String: Any]:
            return value.mapValues(normalize)
        default:
            return value
        }
    }

    static func denormalize(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any],
           let type = dictionary["__mks_type"] as? String
        {
            switch type {
            case "data":
                if let base64 = dictionary["value"] as? String, let data = Data(base64Encoded: base64) {
                    return data
                }
            case "date":
                if let string = dictionary["value"] as? String, let date = formatter.date(from: string) {
                    return date
                }
            default:
                break
            }
        }

        switch value {
        case let value as [Any]:
            return value.map(denormalize)
        case let value as [String: Any]:
            return value.mapValues(denormalize)
        default:
            return value
        }
    }
}
