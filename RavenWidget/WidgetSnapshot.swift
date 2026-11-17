//
//  WidgetSnapshot.swift
//  RavenWidget
//
//  Mirrors `WidgetSnapshot` in the app target (Raven/Services/WidgetSync.swift).
//  Keep both definitions and the App Group identifier in sync.
//

import Foundation
import UIKit

struct WidgetSnapshot: Codable, Equatable {
    var bookID: String
    var title: String
    var author: String
    var chapterTitle: String
    var progress: Double
    var isFinished: Bool
    var updatedAt: Date
}

enum SharedStore {
    static let appGroupID = "group.com.Imaginebowl.Raven"
    private static let snapshotKey = "widget.snapshot"
    private static let coverFileName = "widget-cover.jpg"

    static func loadSnapshot() -> WidgetSnapshot? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: snapshotKey)
        else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func loadCover() -> UIImage? {
        guard
            let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
                .appendingPathComponent(coverFileName),
            let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }
}
