import Foundation

/// Abstraction for estimating calories and meal quality.
public protocol MealAnalyzerService {
    /// Returns an estimated calorie count and qualitative judgement for a meal.
    func analyze(meal: Meal) async -> (kcal: Int, quality: Meal.MealQuality)
}

/// Local heuristic meal analyzer that works offline.
public final class LocalHeuristicMealAnalyzer: MealAnalyzerService {
    public init() {}
    public func analyze(meal: Meal) async -> (kcal: Int, quality: Meal.MealQuality) {
        // Placeholder heuristic: if the meal contains certain keywords, adjust estimation.
        if let text = meal.text?.lowercased() {
            if text.contains("salade") || text.contains("fruits") {
                return (kcal: 300, quality: .healthy)
            } else if text.contains("burger") || text.contains("pizza") {
                return (kcal: 900, quality: .junk)
            }
        }
        return (kcal: meal.kcalEstimate > 0 ? meal.kcalEstimate : 600, quality: .neutral)
    }
}

/// Stubbed analyzer ready to integrate with OpenAI later.
public final class OpenAIAnalyzer: MealAnalyzerService {
    public init() {}
    public func analyze(meal: Meal) async -> (kcal: Int, quality: Meal.MealQuality) {
        // In a real implementation this would call an OpenAI API with image or text input.
        return (kcal: meal.kcalEstimate, quality: meal.quality)
    }
}
