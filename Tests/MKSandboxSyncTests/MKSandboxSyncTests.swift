import XCTest
@testable import MKSandboxSync

final class MKSandboxSyncTests: XCTestCase {
    func testDefaultConfigurationIncludesCommonSandboxRoots() {
        let rootNames = MKSandboxSyncConfiguration.default.allowedRoots.map(\.name)
        XCTAssertTrue(rootNames.contains("Documents"))
        XCTAssertTrue(rootNames.contains("Library"))
        XCTAssertTrue(rootNames.contains("Caches"))
    }

    func testLoggerKeepsSnapshot() {
        MKSandboxSyncLogger.shared.log("unit-test-message")
        let expectation = expectation(description: "async logger")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(MKSandboxSyncLogger.shared.snapshot().contains { $0.message == "unit-test-message" })
    }

    func testBinaryPlistCanBeReadAndWrittenAsJSON() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MKSandboxSyncTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootURL) }

        let provider = MKSFileProvider(roots: [MKSandboxRoot(name: "TestRoot", url: rootURL)])
        let plistPath = "/TestRoot/sample.plist"
        let original: [String: Any] = [
            "name": "MKSandboxSync",
            "enabled": true,
            "count": 3
        ]
        let binary = try PropertyListSerialization.data(fromPropertyList: original, format: .binary, options: 0)
        try provider.write(path: plistPath, data: binary)

        let payload = try provider.readPlist(path: plistPath)
        XCTAssertEqual(payload.format, "binary")

        let updatedJSON = Data(#"{"name":"Updated","enabled":false,"items":["a","b"]}"#.utf8)
        try provider.writePlist(path: plistPath, jsonData: updatedJSON)

        let updated = try provider.readPlist(path: plistPath)
        let encoded = try JSONEncoder().encode(updated)
        let json = String(data: encoded, encoding: .utf8) ?? ""
        XCTAssertTrue(json.contains("Updated"))
        XCTAssertTrue(json.contains("items"))
    }

    func testPlistDataRoundTripPreservesOriginalTypes() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MKSandboxSyncTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootURL) }

        let provider = MKSFileProvider(roots: [MKSandboxRoot(name: "TestRoot", url: rootURL)])
        let plistPath = "/TestRoot/sample.plist"
        let original: [String: Any] = [
            "name": "MKSandboxSync",
            "blob": Data([0x00, 0x01, 0x02, 0x03]),
            "stamp": Date(timeIntervalSince1970: 123_456_789)
        ]
        let binary = try PropertyListSerialization.data(fromPropertyList: original, format: .binary, options: 0)
        try provider.write(path: plistPath, data: binary)

        let payload = try provider.readPlist(path: plistPath)
        let payloadJSON = try JSONEncoder().encode(payload.value)
        let payloadString = String(data: payloadJSON, encoding: .utf8) ?? ""
        XCTAssertTrue(payloadString.contains("\"__mks_type\":\"data\""))
        XCTAssertTrue(payloadString.contains("\"__mks_type\":\"date\""))

        try provider.writePlist(path: plistPath, jsonData: payloadJSON)

        let roundTrippedData = try Data(contentsOf: rootURL.appendingPathComponent("sample.plist"))
        var format = PropertyListSerialization.PropertyListFormat.binary
        let roundTrippedObject = try PropertyListSerialization.propertyList(from: roundTrippedData, options: [], format: &format)
        let dictionary = roundTrippedObject as? [String: Any]
        XCTAssertNotNil(dictionary?["blob"] as? Data)
        XCTAssertNotNil(dictionary?["stamp"] as? Date)
        XCTAssertEqual(dictionary?["name"] as? String, "MKSandboxSync")
    }

    func testUserDefaultsSnapshotPreservesDataAndDateTypes() throws {
        let suiteName = "MKSandboxSyncTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return XCTFail("Unable to create test defaults suite")
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(Data([0xde, 0xad, 0xbe, 0xef]), forKey: "blob")
        defaults.set(Date(timeIntervalSince1970: 123_456_789), forKey: "stamp")

        let provider = MKSUserDefaultsProvider(defaults: defaults)
        let snapshot = provider.snapshot()
        let encoded = try JSONEncoder().encode(snapshot)
        let json = String(data: encoded, encoding: .utf8) ?? ""

        XCTAssertTrue(json.contains("\"blob\""))
        XCTAssertTrue(json.contains("\"__mks_type\":\"data\""))
        XCTAssertTrue(json.contains("\"__mks_type\":\"date\""))
    }

    func testWebConsoleShortcutNormalizesPlainPath() {
        let shortcut = MKSWebConsoleShortcut(name: "tmp", path: "tmp/UT")
        XCTAssertEqual(shortcut.path, "/tmp/UT")
    }

    func testWebConsoleShortcutSupportsAppGroupFolder() {
        let shortcut = MKSWebConsoleShortcut.appGroupFolder(
            name: "Group UT",
            identifier: "group.com.example.shared",
            relativePath: "/Library/Caches/UT/"
        )
        XCTAssertEqual(shortcut.path, "/AppGroup:group.com.example.shared/Library/Caches/UT")
    }
}
