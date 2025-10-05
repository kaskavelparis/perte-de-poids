import Foundation

/// Abstraction for persisting and rotating the application state.
public protocol StorageService {
    func loadState() async throws -> AppState
    func saveState(_ state: AppState) async throws
    func rotateStorageIfNeeded() throws
    func exportState() throws -> Data
    func importState(from data: Data) throws

    /// Exports the canonical state as a YAML string.
    func exportStateYAML() throws -> String

    /// Returns the current used size in bytes and the quota in bytes.
    func currentUsage() throws -> (usedBytes: Int, quotaBytes: Int)
}

/// A JSON-based storage service with a basic rotation policy.
public final class JSONStorageService: StorageService {
    private let fileManager: FileManager
    private let quotaMB: Int
    private let keepDaysMin: Int
    private let folderURL: URL
    private let canonicalURL: URL
    
    /// - Parameters:
    ///   - quotaMB: Maximum disk usage in megabytes before rotation kicks in.
    ///   - keepDaysMin: Minimum number of recent logs to retain regardless of quota.
    ///   - baseURL: Optional base directory for storing state; by default uses the user's document directory. Tests can override this to use a temporary directory.
    public init(quotaMB: Int = 50, keepDaysMin: Int = 30, baseURL: URL? = nil) {
        self.fileManager = .default
        self.quotaMB = quotaMB
        self.keepDaysMin = keepDaysMin
        let docs: URL
        if let baseURL = baseURL {
            docs = baseURL
        } else {
            docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.folderURL = docs.appendingPathComponent("app_state", isDirectory: true)
        self.canonicalURL = folderURL.appendingPathComponent("state.json")
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func loadState() async throws -> AppState {
        guard fileManager.fileExists(atPath: canonicalURL.path) else {
            return AppState()
        }
        let data = try Data(contentsOf: canonicalURL)
        let decoder = JSONDecoder()
        return try decoder.decode(AppState.self, from: data)
    }
    
    public func saveState(_ state: AppState) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(state)
        try data.write(to: canonicalURL, options: .atomic)
        try rotateStorageIfNeeded()
    }
    
    public func rotateStorageIfNeeded() throws {
        // Compute the total size of the folder.
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        var files: [(url: URL, size: Int, date: Date)] = []
        let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: resourceKeys)!
        for case let fileURL as URL in enumerator {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
            if resourceValues.isDirectory == true { continue }
            let size = resourceValues.fileSize ?? 0
            let date = resourceValues.contentModificationDate ?? Date.distantPast
            files.append((fileURL, size, date))
        }
        let totalSizeBytes = files.reduce(0) { $0 + $1.size }
        let quotaBytes = quotaMB * 1_024 * 1_024
        guard totalSizeBytes > quotaBytes else { return }
        // Sort by date ascending (oldest first)
        files.sort { $0.date < $1.date }
        var bytesToFree = totalSizeBytes - Int(Double(quotaBytes) * 0.9)
        var removedCount = 0
        for file in files {
            if removedCount >= keepDaysMin { break }
            try fileManager.removeItem(at: file.url)
            bytesToFree -= file.size
            removedCount += 1
            if bytesToFree <= 0 { break }
        }
    }
    
    public func exportState() throws -> Data {
        return try Data(contentsOf: canonicalURL)
    }
    
    public func importState(from data: Data) throws {
        let decoder = JSONDecoder()
        _ = try decoder.decode(AppState.self, from: data)
        try data.write(to: canonicalURL, options: .atomic)
    }

    // MARK: - YAML Export

    public func exportStateYAML() throws -> String {
        let jsonData = try exportState()
        let object = try JSONSerialization.jsonObject(with: jsonData, options: [])
        var yaml = ""
        func yamlValue(_ val: Any, indent: String) -> String {
            if let dict = val as? [String: Any] {
                var lines = "\n"
                for (k, v) in dict {
                    lines += indent + k + ": " + yamlValue(v, indent: indent + "  ")
                }
                return lines
            } else if let arr = val as? [Any] {
                var lines = "\n"
                for item in arr {
                    lines += indent + "- " + yamlValue(item, indent: indent + "  ")
                }
                return lines
            } else if let str = val as? String {
                return "\"\(str)\"\n"
            } else {
                return "\(val)\n"
            }
        }
        if let dict = object as? [String: Any] {
            for (key, value) in dict {
                yaml += "\(key): " + yamlValue(value, indent: "  ")
            }
        }
        return yaml
    }

    // MARK: - Usage

    public func currentUsage() throws -> (usedBytes: Int, quotaBytes: Int) {
        let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey])!
        var totalSize = 0
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: Set([.isDirectoryKey, .fileSizeKey]))
            if values.isDirectory == true { continue }
            totalSize += values.fileSize ?? 0
        }
        let quotaBytes = quotaMB * 1_024 * 1_024
        return (usedBytes: totalSize, quotaBytes: quotaBytes)
    }
}
