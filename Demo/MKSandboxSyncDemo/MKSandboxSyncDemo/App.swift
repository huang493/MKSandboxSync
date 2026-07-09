import SwiftUI
import MKSandboxSync

@main
struct MKSandboxSyncDemoApp: App {
    static let appGroupIdentifier = "group.com.mksandboxsync.demo"

    init() {
        DemoDataSeeder.seed()
        do {
            try MKSandboxSync.shared.start(
                configuration: .init(
                    serviceName: "MKSandboxSync Demo",
                    port: 56666,
                    requiresPairingToken: false,
                    appGroupIdentifiers: [Self.appGroupIdentifier]
                )
            )
            MKSandboxSync.shared.log("Demo app launched.")
        } catch {
            print("Failed to start MKSandboxSync: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
