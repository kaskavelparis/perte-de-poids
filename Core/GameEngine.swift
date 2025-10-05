import Foundation

/// Core game logic independent of UI or platform features.
public struct GameEngine {
    public init() {}
    
    /// Evaluates a list of meals for a day and determines the badge and XP delta.
    public func evaluateMeals(_ meals: [Meal]) -> MealEvaluation {
        let totalKcal = meals.reduce(0) { $0 + $1.kcalEstimate }
        let badge: MealEvaluation.BadgeDaily
        switch totalKcal {
        case ..<1650:
            badge = .maitreDesCalories
        case 1650...1800:
            badge = .equilibrist
        default:
            badge = .gourmand
        }
        // Simple quality delta: healthy meals add +10 XP each, junk remove 10.
        let qualityDelta = meals.reduce(0) { result, meal in
            switch meal.quality {
            case .healthy: return result + 10
            case .junk: return result - 10
            case .neutral: return result
            }
        }
        return MealEvaluation(totalKcal: totalKcal, badgeDaily: badge, qualityXPDelta: qualityDelta)
    }
    
    /// Applies daily health statistics to compute XP/HP changes, boss damage and loot.
    public func applyHealthStats(_ stats: HealthStats) -> Deltas {
        var xp = 0
        var hp = 0
        var bossDamage: Double = 0
        var loot: [Item] = []
        
        // Steps: >10k → +50 XP + loot; <3k → −25 XP, −5 HP
        if stats.steps > 10_000 {
            xp += 50
            loot.append(Item(name: "Potion", kind: .artifact))
        } else if stats.steps < 3_000 {
            xp -= 25
            hp -= 5
        }
        
        // Floors climbed: >10 → temporary cape
        if stats.floors > 10 {
            loot.append(Item(name: "Cape légère", kind: .cape, expiresAt: Date().addingTimeInterval(24*3600)))
        }
        
        // Active calories: >500 → temporary weapon; <200 → fatigue
        if stats.activeKcal > 500 {
            loot.append(Item(name: "Épée flamboyante", kind: .weapon, expiresAt: Date().addingTimeInterval(24*3600)))
        } else if stats.activeKcal < 200 {
            xp -= 10
        }
        
        // Exercise minutes: >30 → +100 XP; 0 multiple consecutive days: this rule to be handled elsewhere
        if stats.exerciseMinutes > 30 {
            xp += 100
        }
        
        // Sleep hours: >8 → full HP regen + potion; <6 → −10 HP, −20 XP
        if stats.sleepHours > 8 {
            hp += 10 // regen simplified
            loot.append(Item(name: "Potion de sommeil", kind: .artifact))
        } else if stats.sleepHours < 6 {
            hp -= 10
            xp -= 20
        }
        
        // Hydration: ≥1L validates daily boss objective
        if stats.hydrationLiters >= 1.0 {
            bossDamage = 0.2
        }
        
        return Deltas(xpDelta: xp, hpDelta: hp, bossDamagePercent: bossDamage, loot: loot)
    }
    
    /// Updates the boss HP and applies win/lose conditions. Mutates the provided state.
    public mutating func updateBossProgress(state: inout AppState, success: Bool) {
        if success {
            state.boss.hpPercent = max(0.0, state.boss.hpPercent - 0.2)
            if state.boss.hpPercent <= 0 {
                // Victory: grant XP and reset boss
                state.avatar.xp += 500
                // TODO: grant random loot
                state.boss.hpPercent = 1.0
            }
        } else {
            state.avatar.xp -= 200
            // Defeat penalty flag could be set here
        }
    }
    
    /// Advances the user's journey based on step count. Mutates the provided state.
    public mutating func advanceJourney(state: inout AppState, steps: Int) {
        state.journey.stepsToday += steps
        state.journey.accumulatedSteps += steps
        // Check if a destination has been reached
        while state.journey.stepsToday >= state.journey.distanceToNext {
            state.journey.stepsToday -= state.journey.distanceToNext
            // Unlock the destination
            state.journey.unlocked.append(state.journey.currentDestination)
            // Generate next destination (placeholder)
            state.journey.currentDestination = "Destination #\(state.journey.unlocked.count + 1)"
            state.journey.environment = state.journey.unlocked.count % 2 == 0 ? "Forêt des Brumes" : "Cité Médiévale des Mille Tours"
        }
    }
    
    /// Handles exploration events that may result in bonus/malus. Mutates the provided state.
    public mutating func explore(state: inout AppState, choiceHealthy: Bool) {
        guard choiceHealthy else {
            // Exploration not available if healthy choice not made
            return
        }
        // Deterministic simple RNG for now
        let rand = Int(Date().timeIntervalSince1970) % 4
        switch rand {
        case 0:
            state.avatar.xp += 50
        case 1:
            state.avatar.hpCurrent = max(0, state.avatar.hpCurrent - 10)
        case 2:
            state.avatar.inventory.weapons.append(Item(name: "Dague rapide", kind: .weapon))
        case 3:
            state.journey.stepsToday += 1000
        default:
            break
        }
    }
    
    /// Finalises the day: compute streak, assign badges, persist logs and prepare next day.
    public mutating func tickDailyClose(state: inout AppState) {
        // Simplified daily close: increase level on XP thresholds
        let levelUpXP = state.avatar.level * 500
        if state.avatar.xp >= levelUpXP {
            state.avatar.level += 1
            state.avatar.hpMax += 20
            state.avatar.hpCurrent = state.avatar.hpMax
        }
        // Reset steps for next day
        state.journey.stepsToday = 0
    }
}

// MARK: - Meal & Evaluation

/// Represents a meal entry with optional photo or text.
public struct Meal: Codable, Identifiable {
    public var id: UUID
    public var time: Date
    public var photoLocalURL: URL?
    public var text: String?
    public var kcalEstimate: Int
    public var quality: MealQuality
    
    public init(id: UUID = UUID(), time: Date = Date(), photoLocalURL: URL? = nil, text: String? = nil, kcalEstimate: Int, quality: MealQuality) {
        self.id = id
        self.time = time
        self.photoLocalURL = photoLocalURL
        self.text = text
        self.kcalEstimate = kcalEstimate
        self.quality = quality
    }
    
    public enum MealQuality: String, Codable {
        case healthy, neutral, junk
    }
}

/// The result of evaluating a collection of meals.
public struct MealEvaluation: Codable {
    public enum BadgeDaily: String, Codable {
        case maitreDesCalories, equilibrist, gourmand
    }
    public var totalKcal: Int
    public var badgeDaily: BadgeDaily
    public var qualityXPDelta: Int
}

/// Represents daily health metrics used for gamification.
public struct HealthStats: Codable {
    public var steps: Int
    public var floors: Int
    public var activeKcal: Int
    public var exerciseMinutes: Int
    public var sleepHours: Double
    public var hydrationLiters: Double
    public var heartRateAvg: Double?
    
    public init(steps: Int, floors: Int, activeKcal: Int, exerciseMinutes: Int, sleepHours: Double, hydrationLiters: Double, heartRateAvg: Double?) {
        self.steps = steps
        self.floors = floors
        self.activeKcal = activeKcal
        self.exerciseMinutes = exerciseMinutes
        self.sleepHours = sleepHours
        self.hydrationLiters = hydrationLiters
        self.heartRateAvg = heartRateAvg
    }
}

/// Deltas returned by health and meal evaluations.
public struct Deltas: Codable {
    public var xpDelta: Int
    public var hpDelta: Int
    public var bossDamagePercent: Double
    public var loot: [Item]
}
