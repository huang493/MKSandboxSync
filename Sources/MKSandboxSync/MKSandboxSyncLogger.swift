import Foundation

public final class MKSandboxSyncLogger {
    public static let shared = MKSandboxSyncLogger()

    private let queue = DispatchQueue(label: "com.mksandboxsync.logger")
    private var records: [MKSandboxLogRecord] = []
    private let limit = 500

    private init() {}

    public func log(_ message: String) {
        queue.async {
            let record = MKSandboxLogRecord(date: Date(), message: message)
            self.records.append(record)
            if self.records.count > self.limit {
                self.records.removeFirst(self.records.count - self.limit)
            }
            print("[MKSandboxSync] \(message)")
        }
    }

    func snapshot() -> [MKSandboxLogRecord] {
        queue.sync { records }
    }
}

struct MKSandboxLogRecord: Codable {
    let date: Date
    let message: String
}
