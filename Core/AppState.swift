import Foundation

/// Represents the entire application state persisted between launches.
public struct AppState: Codable {
    public var avatar: Avatar
    public var boss: Boss
    public var journey: Journey
    public var settings: Settings
    // Additional fields such as nutrition, exploration, health bonuses, hydration, sleep, etc. will be added later.
    
    public init(avatar: Avatar = .default,
                boss: Boss = .default,
                journey: Journey = .default,
                settings: Settings = .default) {
        self.avatar = avatar
        self.boss = boss
        self.journey = journey
        self.settings = settings
    }
}
