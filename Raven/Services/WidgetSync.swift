//
//  WidgetSync.swift
//  Raven
//
//  Shares the "continue listening" state with the home screen widget
//  through an App Group container.
//

import Foundation
import UIKit
import WidgetKit

/// Plain data the widget needs. Keep in sync with `RavenWidget/WidgetSnapshot.swift`.
struct WidgetSnapshot: Codable, Equatable {
    var bookID: String
    var title: String
    var author: String
    var chapterTitle: String
    var progress: Double
    var isFinished: Bool
    var updatedAt: Date
}

enum WidgetSync {
    static let appGroupID = "group.com.Imaginebowl.Raven"
    private static let snapshotKey = "widget.snapshot"
    private static let coverFileName = "widget-cover.jpg"
    private static let coverBookKey = "widget.coverBookID"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private static var coverURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(coverFileName)
    }

    /// Writes the latest listening state. Cheap enough to call on every progress save.
    static func write(book: Book, chapterTitle: String?, progress: Double) {
        guard let defaults else { return }

        let snapshot = WidgetSnapshot(
            bookID: book.id.uuidString,
            title: book.title,
            author: book.author,
            chapterTitle: chapterTitle ?? "",
            progress: min(max(progress, 0), 1),
            isFinished: book.isFinished,
            updatedAt: Date()
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: snapshotKey)
        }

        // The cover is only re-encoded when the book changes.
        if defaults.string(forKey: coverBookKey) != snapshot.bookID {
            defaults.set(snapshot.bookID, forKey: coverBookKey)
            writeCover(for: book)
        }
    }

    /// Asks WidgetKit to refresh. Call sparingly (pause, background, book change).
    static func reload() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func writeCover(for book: Book) {
        guard let url = coverURL else { return }
        guard
            let data = book.artworkData,
            let image = UIImage(data: data)
        else {
            try? FileManager.default.removeItem(at: url)
            return
        }

        let maxSide: CGFloat = 400
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        if let jpeg = resized.jpegData(compressionQuality: 0.8) {
            try? jpeg.write(to: url, options: .atomic)
        }
    }
}
