import Foundation
import SwiftUI

/// Abstraction for generating daily comic episodes.
public protocol ComicService {
    func generateDailyComic(from log: DailyLog) async throws -> ComicEpisode
}

/// Placeholder implementation that returns empty panels.
public final class PlaceholderComicService: ComicService {
    public init() {}
    
    public func generateDailyComic(from log: DailyLog) async throws -> ComicEpisode {
        // In a full implementation, SwiftUI views would be rendered to images and saved.
        return ComicEpisode(date: log.date, panels: [], caption: "À suivre…")
    }
}
