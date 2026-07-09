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
}
