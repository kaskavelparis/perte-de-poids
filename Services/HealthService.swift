import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Abstraction for reading health data. Real implementation uses HealthKit; mock provides canned data.
public protocol HealthService {
    /// Requests the necessary read permissions from the user.
    func requestAuthorization() async throws
    /// Reads today's aggregated stats.
    func readTodayStats() async throws -> HealthStats
}

/// Health service backed by HealthKit (only available on physical devices).
public final class RealHealthService: HealthService {
#if canImport(HealthKit)
    private let store = HKHealthStore()
#endif
    public init() {}
    
    public func requestAuthorization() async throws {
#if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let readTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        try await store.requestAuthorization(toShare: [], read: readTypes)
#else
        throw NSError(domain: "HealthKitUnavailable", code: -1, userInfo: nil)
#endif
    }
    
    public func readTodayStats() async throws -> HealthStats {
#if canImport(HealthKit)
        // This is a placeholder. Proper implementation would query the HealthKit store.
        return HealthStats(steps: 0, floors: 0, activeKcal: 0, exerciseMinutes: 0, sleepHours: 0, hydrationLiters: 0, heartRateAvg: nil)
#else
        throw NSError(domain: "HealthKitUnavailable", code: -1, userInfo: nil)
#endif
    }
}

/// Mock implementation for simulator and unit tests.
public final class MockHealthService: HealthService {
    public init() {}
    public func requestAuthorization() async throws {}
    public func readTodayStats() async throws -> HealthStats {
        return HealthStats(steps: 5000, floors: 5, activeKcal: 350, exerciseMinutes: 30, sleepHours: 7.5, hydrationLiters: 1.2, heartRateAvg: 70)
    }
}
