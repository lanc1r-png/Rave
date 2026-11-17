//
//  Bookmark.swift
//  Raven
//

import Foundation
import SwiftData

/// A saved position inside a book.
@Model
final class Bookmark {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var note: String = ""
    /// Index of the chapter (in `Book.sortedChapters`) the bookmark points into.
    var chapterIndex: Int = 0
    /// Time inside that chapter, in seconds.
    var chapterTime: TimeInterval = 0
    /// Position from the start of the whole book, in seconds.
    var bookPosition: TimeInterval = 0
    var book: Book?

    init(note: String = "", chapterIndex: Int, chapterTime: TimeInterval, bookPosition: TimeInterval) {
        self.id = UUID()
        self.createdAt = Date()
        self.note = note
        self.chapterIndex = chapterIndex
        self.chapterTime = chapterTime
        self.bookPosition = bookPosition
    }
}
