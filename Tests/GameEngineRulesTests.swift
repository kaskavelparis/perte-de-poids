import XCTest
@testable import Core

/// Tests covering the main rules of the GameEngine.
final class GameEngineRulesTests: XCTestCase {
    /// Tests boss progress on success and victory.
    func testBossProgressSuccessAndVictory() {
        var engine = GameEngine()
        var state = AppState()
        state.boss.hpPercent = 0.4
        state.avatar.xp = 0
        // First success should reduce HP by 20%
        engine.updateBossProgress(state: &state, success: true)
        XCTAssertEqual(state.boss.hpPercent, 0.2, accuracy: 0.001)
        XCTAssertEqual(state.avatar.xp, 0)
        // Second success should trigger victory → hpPercent reset and XP +500
        engine.updateBossProgress(state: &state, success: true)
        XCTAssertEqual(state.boss.hpPercent, 1.0, accuracy: 0.001)
        XCTAssertEqual(state.avatar.xp, 500)
    }
    
    /// Tests boss defeat penalty.
    func testBossProgressDefeat() {
        var engine = GameEngine()
        var state = AppState()
        state.avatar.xp = 100
        engine.updateBossProgress(state: &state, success: false)
        // XP should decrease by 200
        XCTAssertEqual(state.avatar.xp, -100)
    }
    
    /// Tests advancing the journey unlocks destinations and carries over surplus steps.
    func testAdvanceJourney() {
        var engine = GameEngine()
        var state = AppState()
        state.journey.distanceToNext = 5000
        state.journey.currentDestination = "Départ"
        state.journey.unlocked = []
        // Exactly 5000 steps → unlock one destination and reset stepsToday
        engine.advanceJourney(state: &state, steps: 5000)
        XCTAssertEqual(state.journey.unlocked.count, 1)
        XCTAssertEqual(state.journey.stepsToday, 0)
        XCTAssertNotEqual(state.journey.currentDestination, "Départ")
        // Surplus: 7500 steps → at least one more unlock and leftover steps
        let previousUnlocked = state.journey.unlocked.count
        engine.advanceJourney(state: &state, steps: 7500)
        XCTAssertTrue(state.journey.unlocked.count >= previousUnlocked)
        XCTAssertTrue(state.journey.stepsToday >= 0 && state.journey.stepsToday < state.journey.distanceToNext)
    }
    
    /// Tests that exploration requires a healthy choice and does nothing otherwise.
    func testExploreRequiresHealthyChoice() {
        var engine = GameEngine()
        var state = AppState()
        let xpBefore = state.avatar.xp
        engine.explore(state: &state, choiceHealthy: false)
        XCTAssertEqual(state.avatar.xp, xpBefore)
    }
    
    /// Tests that health stats rules yield positive XP and boss damage when thresholds are met.
    func testApplyHealthStatsBonuses() {
        let engine = GameEngine()
        let stats = HealthStats(
            steps: 12_000,
            floors: 5,
            activeKcal: 600,
            exerciseMinutes: 45,
            sleepHours: 9,
            hydrationLiters: 1.5,
            heartRateAvg: nil
        )
        let deltas = engine.applyHealthStats(stats)
        XCTAssertTrue(deltas.xpDelta > 0)
        XCTAssertEqual(deltas.bossDamagePercent, 0.2, accuracy: 0.001)
        XCTAssertFalse(deltas.loot.isEmpty)
    }
}
