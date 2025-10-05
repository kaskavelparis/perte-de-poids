import Foundation
#if canImport(UIKit)
import SwiftUI
import UIKit
#endif

/// Abstraction for saving view snapshots to disk.
public protocol ImageService {
    /// Renders the given SwiftUI view to a PNG and saves it under Documents/media/YYYY/MM/DD/.
    func saveReportSnapshot<V: View>(view: V, date: Date) throws -> URL
}

/// Implementation using ImageRenderer (iOS 16+) to capture SwiftUI views.
public final class FileImageService: ImageService {
    public init() {}
#if canImport(UIKit)
    public func saveReportSnapshot<V: View>(view: V, date: Date) throws -> URL {
        let renderer = ImageRenderer(content: view)
        guard let uiImage = renderer.uiImage else {
            throw NSError(domain: "ImageRenderError", code: -1, userInfo: nil)
        }
        guard let data = uiImage.pngData() else {
            throw NSError(domain: "PNGEncodingError", code: -2, userInfo: nil)
        }
        let fileManager = FileManager.default
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs
            .appendingPathComponent("media", isDirectory: true)
            .appendingPathComponent(String(comps.year ?? 0), isDirectory: true)
            .appendingPathComponent(String(comps.month ?? 0), isDirectory: true)
            .appendingPathComponent(String(comps.day ?? 0), isDirectory: true)
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        let filename = "report-\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = dir.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
#else
    public func saveReportSnapshot<V: View>(view: V, date: Date) throws -> URL {
        throw NSError(domain: "UnsupportedPlatform", code: -1, userInfo: nil)
    }
#endif
}
