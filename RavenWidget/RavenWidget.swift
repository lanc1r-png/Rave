//
//  RavenWidget.swift
//  RavenWidget
//
//  "Continue listening" home screen widget.
//

import SwiftUI
import UIKit
import WidgetKit

struct ContinueEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
    let cover: UIImage?
}

struct ContinueProvider: TimelineProvider {
    func placeholder(in context: Context) -> ContinueEntry {
        ContinueEntry(
            date: .now,
            snapshot: WidgetSnapshot(
                bookID: "",
                title: "Audiobook",
                author: "Author",
                chapterTitle: "",
                progress: 0.4,
                isFinished: false,
                updatedAt: .now
            ),
            cover: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ContinueEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ContinueEntry>) -> Void) {
        // The app asks WidgetKit to reload whenever playback state changes.
        completion(Timeline(entries: [currentEntry()], policy: .never))
    }

    private func currentEntry() -> ContinueEntry {
        ContinueEntry(date: .now, snapshot: SharedStore.loadSnapshot(), cover: SharedStore.loadCover())
    }
}

private struct CoverView: View {
    let cover: UIImage?

    var body: some View {
        Group {
            if let cover {
                Image(uiImage: cover)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle().fill(.quaternary)
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ProgressLine: View {
    let progress: Double

    var body: some View {
        ProgressView(value: min(max(progress, 0), 1))
            .progressViewStyle(.linear)
            .tint(.primary)
    }
}

struct ContinueListeningView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ContinueEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                switch family {
                case .systemMedium:
                    mediumLayout(snapshot)
                default:
                    smallLayout(snapshot)
                }
            } else {
                emptyLayout
            }
        }
        .widgetURL(URL(string: "raven://continue"))
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func smallLayout(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                CoverView(cover: entry.cover)
                    .frame(width: 52, height: 52)
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 0)
            Text(snapshot.title)
                .font(.footnote.weight(.semibold))
                .lineLimit(2)
            statusLine(snapshot)
        }
    }

    private func mediumLayout(_ snapshot: WidgetSnapshot) -> some View {
        HStack(spacing: 14) {
            CoverView(cover: entry.cover)
                .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 4) {
                Text("Continue listening")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(snapshot.title)
                    .font(.headline)
                    .lineLimit(2)
                if !snapshot.author.isEmpty {
                    Text(snapshot.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                statusLine(snapshot)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func statusLine(_ snapshot: WidgetSnapshot) -> some View {
        if snapshot.isFinished {
            Label("Finished", systemImage: "checkmark.circle.fill")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ProgressLine(progress: snapshot.progress)
                Text("\(Int(snapshot.progress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyLayout: some View {
        VStack(spacing: 6) {
            Image(systemName: "headphones")
                .font(.title)
            Text("Nothing to continue")
                .font(.footnote.weight(.semibold))
            Text("Open Raven to add a book.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContinueListeningWidget: Widget {
    let kind = "ContinueListeningWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ContinueProvider()) { entry in
            ContinueListeningView(entry: entry)
        }
        .configurationDisplayName("Continue listening")
        .description("Resume your latest audiobook.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct RavenWidgetBundle: WidgetBundle {
    var body: some Widget {
        ContinueListeningWidget()
    }
}
