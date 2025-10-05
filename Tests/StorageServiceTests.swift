import XCTest
@testable import Services
@testable import Core

/// Unit tests for JSONStorageService's rotation behaviour.
final class StorageServiceTests: XCTestCase {
    /// Verifies that no files are removed when total size is below quota.
    func testRotationKeepsFilesBelowQuota() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let service = JSONStorageService(quotaMB: 1, keepDaysMin: 2, baseURL: tempDir)
        let folderURL = tempDir.appendingPathComponent("app_state", isDirectory: true)
        // Create three small files (200 bytes each)
        for i in 0..<3 {
            let url = folderURL.appendingPathComponent("2024-01-0\(i+1).json")
            let data = Data(repeating: UInt8(i), count: 200)
            FileManager.default.createFile(atPath: url.path, contents: data)
        }
        // Run rotation: total size ~600 bytes < 1 MB, so nothing should be removed
        try service.rotateStorageIfNeeded()
        let contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 3)
    }
    
    /// Verifies that the oldest files are removed when exceeding quota while respecting keepDaysMin.
    func testRotationRemovesOldestFiles() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        // Set quota 0 MB to force rotation; keep at least 1 file
        let service = JSONStorageService(quotaMB: 0, keepDaysMin: 1, baseURL: tempDir)
        let folderURL = tempDir.appendingPathComponent("app_state", isDirectory: true)
        // Create three files of 600 bytes, with increasing modification dates
        for i in 0..<3 {
            let url = folderURL.appendingPathComponent("2024-01-0\(i+1).json")
            let data = Data(repeating: UInt8(i), count: 600)
            FileManager.default.createFile(atPath: url.path, contents: data)
            let date = Date(timeIntervalSince1970: TimeInterval(i * 3600))
            try FileManager.default.setAttributes([.modificationDate: date], ofItemAtPath: url.path)
        }
        try service.rotateStorageIfNeeded()
        let contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        // With keepDaysMin = 1, at most one file should be removed
        XCTAssertEqual(contents.count, 2)
    }
}
