import SwiftUI
import MKSandboxSync

struct ContentView: View {
    @State private var statusMessage = "SDK started. Check the Xcode console for the selected port."

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Server")) {
                    row(title: "Port", value: MKSandboxSync.shared.currentPort.map(String.init) ?? "Starting")
                    row(title: "Manifest", value: "/mkss/manifest")
                    row(title: "Files", value: "/mkss/files?path=/Documents")
                    row(title: "Defaults", value: "/mkss/defaults")
                    row(title: "Logs", value: "/mkss/logs")
                }

                Section(header: Text("Actions")) {
                    Button("Write sample file") {
                        DemoDataSeeder.writeSampleFile()
                        MKSandboxSync.shared.log("Sample file refreshed from demo UI.")
                        statusMessage = "Wrote Documents/mksandboxsync-demo.json"
                    }

                    Button("Set UserDefaults value") {
                        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "mksandboxsync.lastTap")
                        MKSandboxSync.shared.log("Updated mksandboxsync.lastTap.")
                        statusMessage = "Updated UserDefaults key mksandboxsync.lastTap"
                    }
                }

                Section(header: Text("Status")) {
                    Text(statusMessage)
                        .font(.footnote)
                }
            }
            .navigationTitle("MKSandboxSync")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            let home = NSHomeDirectory()
            let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MKSandboxSyncDemoApp.appGroupIdentifier)?.path
            print("Home:\(home)")
            print("group:\(group ?? "unavailable")")
        }
    }

    private func row(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

enum DemoDataSeeder {
    static func seed() {
        UserDefaults.standard.set("hello from demo", forKey: "mksandboxsync.message")
        writeSampleFile()
        writeAppGroupSampleFile()
    }

    static func writeSampleFile() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("mksandboxsync-demo.json")
        let payload: [String: Any] = [
            "name": "MKSandboxSync",
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "purpose": "Demo file for sandbox read/write testing"
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        try? data?.write(to: url, options: [.atomic])
    }

    static func writeAppGroupSampleFile() {
        guard let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: MKSandboxSyncDemoApp.appGroupIdentifier
        ) else {
            return
        }

        let url = container.appendingPathComponent("mksandboxsync-group-demo.json")
        let payload: [String: Any] = [
            "name": "MKSandboxSync App Group",
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "purpose": "Demo file for app group read/write/delete testing"
        ]
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        try? data?.write(to: url, options: [.atomic])
    }
}
