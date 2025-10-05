import XCTest
@testable import Core

/// Unit tests for the GameEngine. Currently tests the meal evaluation thresholds.
final class GameEngineTests: XCTestCase {
    func testEvaluateMealsBadgeThresholds() {
        let engine = GameEngine()
        // Below 1650 kcal → Maître des Calories
        let mealsLow = [
            Meal(kcalEstimate: 500, quality: .healthy),
            Meal(kcalEstimate: 800, quality: .neutral)
        ]
        let evalLow = engine.evaluateMeals(mealsLow)
        XCTAssertEqual(evalLow.badgeDaily, .maitreDesCalories)
        
        // Between 1650 and 1800 kcal → Équilibriste
        let mealsMid = [
            Meal(kcalEstimate: 1000, quality: .healthy),
            Meal(kcalEstimate: 700, quality: .junk)
        ]
        let evalMid = engine.evaluateMeals(mealsMid)
        XCTAssertEqual(evalMid.badgeDaily, .equilibrist)
        
        // Above 1800 kcal → Gourmand
        let mealsHigh = [
            Meal(kcalEstimate: 1200, quality: .junk),
            Meal(kcalEstimate: 800, quality: .junk)
        ]
        let evalHigh = engine.evaluateMeals(mealsHigh)
        XCTAssertEqual(evalHigh.badgeDaily, .gourmand)
    }
}
