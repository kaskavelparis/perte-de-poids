import Foundation

// MARK: - Avatar & Inventory

/// Represents the user's avatar and progression.
public struct Avatar: Codable {
    public var level: Int
    public var xp: Int
    public var hpCurrent: Int
    public var hpMax: Int
    public var streak: Int
    public var inventory: Inventory
    
    public init(level: Int, xp: Int, hpCurrent: Int, hpMax: Int, streak: Int, inventory: Inventory) {
        self.level = level
        self.xp = xp
        self.hpCurrent = hpCurrent
        self.hpMax = hpMax
        self.streak = streak
        self.inventory = inventory
    }
    
    public static let `default` = Avatar(level: 1, xp: 0, hpCurrent: 100, hpMax: 100, streak: 0, inventory: .empty)
}

/// Contains collections of items the user has obtained.
public struct Inventory: Codable {
    public var weapons: [Item]
    public var shields: [Item]
    public var capes: [Item]
    public var artifacts: [Item]
    
    public init(weapons: [Item], shields: [Item], capes: [Item], artifacts: [Item]) {
        self.weapons = weapons
        self.shields = shields
        self.capes = capes
        self.artifacts = artifacts
    }
    
    public static let empty = Inventory(weapons: [], shields: [], capes: [], artifacts: [])
}

/// Represents an equippable or collectible item.
public struct Item: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var kind: Kind
    public var expiresAt: Date?
    
    public enum Kind: String, Codable {
        case weapon, shield, cape, artifact
    }
    
    public init(id: UUID = UUID(), name: String, kind: Kind, expiresAt: Date? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.expiresAt = expiresAt
    }
}

// MARK: - Boss

/// Represents the weekly boss challenge.
public struct Boss: Codable {
    public var name: String
    public var hpPercent: Double
    public var dailyObjective: String
    
    public init(name: String, hpPercent: Double, dailyObjective: String) {
        self.name = name
        self.hpPercent = hpPercent
        self.dailyObjective = dailyObjective
    }
    
    public static let `default` = Boss(name: "Squelette Maudit", hpPercent: 1.0, dailyObjective: "Drink 1L of water")
}

// MARK: - Journey

/// Tracks progress toward destinations and unlocked locations.
public struct Journey: Codable {
    public var environment: String
    public var stepsToday: Int
    public var accumulatedSteps: Int
    public var distanceToNext: Int
    public var currentDestination: String
    public var unlocked: [String]
    
    public init(environment: String, stepsToday: Int, accumulatedSteps: Int, distanceToNext: Int, currentDestination: String, unlocked: [String]) {
        self.environment = environment
        self.stepsToday = stepsToday
        self.accumulatedSteps = accumulatedSteps
        self.distanceToNext = distanceToNext
        self.currentDestination = currentDestination
        self.unlocked = unlocked
    }
    
    public static let `default` = Journey(
        environment: "Forêt des Brumes",
        stepsToday: 0,
        accumulatedSteps: 0,
        distanceToNext: 5000,
        currentDestination: "Cité Médiévale des Mille Tours",
        unlocked: []
    )
}

// MARK: - Settings

/// User‐configurable settings for storage, notifications and analysis.
public struct Settings: Codable {
    public var storageQuotaMB: Int
    public var keepDaysMin: Int
    public var notificationsEnabled: Bool
    public var useOpenAIAnalyzer: Bool
    
    public init(storageQuotaMB: Int, keepDaysMin: Int, notificationsEnabled: Bool, useOpenAIAnalyzer: Bool) {
        self.storageQuotaMB = storageQuotaMB
        self.keepDaysMin = keepDaysMin
        self.notificationsEnabled = notificationsEnabled
        self.useOpenAIAnalyzer = useOpenAIAnalyzer
    }
    
    public static let `default` = Settings(storageQuotaMB: 50, keepDaysMin: 30, notificationsEnabled: true, useOpenAIAnalyzer: false)
}

// MARK: - Daily Log

/// Persists a single day's data for exporting and rotation.
public struct DailyLog: Codable {
    public var date: Date
    public var meals: [Meal]
    public var healthStats: HealthStats
    public var badgeDaily: MealEvaluation.BadgeDaily
    public var totalKcal: Int
    
    public init(date: Date = Date(),
                meals: [Meal] = [],
                healthStats: HealthStats = HealthStats(steps: 0, floors: 0, activeKcal: 0, exerciseMinutes: 0, sleepHours: 0, hydrationLiters: 0, heartRateAvg: nil),
                badgeDaily: MealEvaluation.BadgeDaily = .equilibrist,
                totalKcal: Int = 0) {
        self.date = date
        self.meals = meals
        self.healthStats = healthStats
        self.badgeDaily = badgeDaily
        self.totalKcal = totalKcal
    }
}

// MARK: - Comic Episode

/// Stores generated comic panels for a given day.
public struct ComicEpisode: Codable {
    public var date: Date
    public var panels: [URL]
    public var caption: String
    
    public init(date: Date, panels: [URL], caption: String) {
        self.date = date
        self.panels = panels
        self.caption = caption
    }
}
