import Foundation
import Combine

/// View model owning the application state and coordinating between services.
@MainActor
final class AppViewModel: ObservableObject {
    /// Current application state.
    @Published var state = AppState()
    
    private let engine = GameEngine()
    private let storageService: StorageService
    private let healthService: HealthService
    
    /// Initializes the view model with concrete service implementations.
    init(storageService: StorageService = JSONStorageService(),
         healthService: HealthService = {
             #if targetEnvironment(simulator)
             return MockHealthService()
             #else
             return RealHealthService()
             #endif
         }()) {
        self.storageService = storageService
        self.healthService = healthService
    }
    
    /// Loads persisted state at startup.
    func load() async {
        do {
            let loaded = try await storageService.loadState()
            state = loaded
        } catch {
            print("Failed to load state: \(error)")
        }
    }

    /// Exports the current state to a JSON file in the Documents/export/ folder.
    func exportStateJSON() async {
        do {
            let data = try storageService.exportState()
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportDir = docs.appendingPathComponent("export", isDirectory: true)
            try fileManager.createDirectory(at: exportDir, withIntermediateDirectories: true)
            let fileURL = exportDir.appendingPathComponent("state.json")
            try data.write(to: fileURL, options: .atomic)
            print("State exported to \(fileURL)")
        } catch {
            print("Failed to export JSON: \(error)")
        }
    }
    
    /// Exports the current state to a YAML file in the Documents/export/ folder.
    func exportStateYAML() async {
        do {
            let yamlString = try storageService.exportStateYAML()
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportDir = docs.appendingPathComponent("export", isDirectory: true)
            try fileManager.createDirectory(at: exportDir, withIntermediateDirectories: true)
            let fileURL = exportDir.appendingPathComponent("state.yaml")
            try yamlString.data(using: .utf8)?.write(to: fileURL, options: .atomic)
            print("State exported to \(fileURL)")
        } catch {
            print("Failed to export YAML: \(error)")
        }
    }
    
    /// Returns the current storage usage in MB and the configured quota.
    func storageUsage() async -> (usedMB: Double, quotaMB: Int) {
        do {
            let usage = try storageService.currentUsage()
            let usedMB = Double(usage.usedBytes) / 1_048_576.0
            let quotaMB = usage.quotaBytes / (1_024 * 1_024)
            return (usedMB, quotaMB)
        } catch {
            print("Failed to compute storage usage: \(error)")
            return (0, state.settings.storageQuotaMB)
        }
    }
}
