//
//  PlayerView.swift
//  Raven
//
//  Created by Ahsan Minhas on 28/05/2026.
//

import SwiftData
import SwiftUI

struct PlayerView: View {
    let book: Book
    var autoPlay = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AudioPlayerService.self) private var player
    @State private var viewModel = PlayerViewModel()
    @State private var showChapterList = false
    @State private var bookmarkBeingRenamed: Bookmark?
    @State private var renameDraft = ""

    var body: some View {
        VStack(spacing: 0) {
            playerNavigationBar

            ScrollView {
                VStack(spacing: 24) {
                    artworkSection
                    metadataSection
                    controlsSection
                    bookmarksSection
                }
                .padding(.horizontal, RavenDesign.Spacing.pageMargin)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .background {
            ZStack {
                RavenDesign.Colors.playerSurface
                RavenAmbientBackground(artworkData: book.artworkData, darken: 0.35)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showChapterList) {
            ChapterListView(book: book)
        }
        .alert("Rename bookmark", isPresented: renameAlertBinding) {
            TextField("Note", text: $renameDraft)
            Button("Save") {
                bookmarkBeingRenamed?.note = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                try? modelContext.save()
                bookmarkBeingRenamed = nil
            }
            Button("Cancel", role: .cancel) {
                bookmarkBeingRenamed = nil
            }
        }
        .task(id: book.id) {
            if player.currentBook?.id != book.id {
                try? await player.load(book, autoPlay: false)
            }
            if autoPlay {
                player.play()
            }
        }
    }

    private var renameAlertBinding: Binding<Bool> {
        Binding(
            get: { bookmarkBeingRenamed != nil },
            set: { if !$0 { bookmarkBeingRenamed = nil } }
        )
    }

    private var playerNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Close player")

            Spacer()

            VStack(spacing: 4) {
                Text("Now Playing")
                    .font(RavenDesign.Typography.headlineMedium())
                    .foregroundStyle(.white)

                Text(chapterSubtitle)
                    .font(RavenDesign.Typography.labelCaps())
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .lineLimit(1)
            }

            Spacer()

            Menu {
                Button {
                    showChapterList = true
                } label: {
                    Label("Chapters", systemImage: "list.bullet")
                }
                Button {
                    book.setFinished(!book.isFinished)
                    try? modelContext.save()
                } label: {
                    if book.isFinished {
                        Label("Mark as unfinished", systemImage: "arrow.uturn.backward.circle")
                    } else {
                        Label("Mark as finished", systemImage: "checkmark.circle")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
        .padding(.horizontal, RavenDesign.Spacing.pageMargin)
        .padding(.top, 8)
        .padding(.bottom, RavenDesign.Spacing.stackSmall)
    }

    private var chapterSubtitle: String {
        player.currentChapter?.title ?? book.title
    }

    private var artworkSection: some View {
        BookArtworkView(book: book, cornerRadius: 24, contentMode: .fit)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 280)
            .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
            .padding(.top, 8)
    }

    private var metadataSection: some View {
        VStack(spacing: 4) {
            Text(book.title)
                .font(RavenDesign.Typography.headlineMedium())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(book.author.isEmpty ? book.title : book.author)
                .font(RavenDesign.Typography.bodyUI())
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineLimit(1)

            if book.isFinished {
                Label("Finished", systemImage: "checkmark.circle.fill")
                    .font(RavenDesign.Typography.labelCaps())
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: RavenDesign.Spacing.stackMedium) {
            PlayerProgressSection(viewModel: viewModel)

            GlassEffectContainer(spacing: 20) {
                HStack {
                    playbackSpeedButton
                        .frame(width: 48, height: 48)
                        .glassEffect(.regular.interactive(), in: Circle())

                    Spacer()

                    HStack(spacing: 20) {
                        skipButton(systemImage: "gobackward.15") {
                            player.skipBackward()
                        }

                        Button {
                            player.togglePlayPause()
                        } label: {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .frame(width: 76, height: 76)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            .regular.tint(RavenDesign.Colors.primary.opacity(0.85)).interactive(),
                            in: Circle()
                        )

                        skipButton(systemImage: "goforward.30") {
                            player.skipForward()
                        }
                    }

                    Spacer()

                    PlayerBedtimeButton()
                        .frame(width: 48, height: 48)
                        .glassEffect(.regular.interactive(), in: Circle())
                }
            }
        }
    }

    private var bookmarksSection: some View {
        VStack(alignment: .leading, spacing: RavenDesign.Spacing.stackMedium) {
            HStack {
                Text("Bookmarks")
                    .font(RavenDesign.Typography.headlineMedium())
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    player.addBookmark()
                } label: {
                    Label("Add bookmark", systemImage: "bookmark.fill")
                        .font(RavenDesign.Typography.labelCaps())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }

            if book.sortedBookmarks.isEmpty {
                Text("No bookmarks yet. Tap “Add bookmark” to save your place.")
                    .font(RavenDesign.Typography.bodyUI())
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(book.sortedBookmarks.enumerated()), id: \.element.id) { index, bookmark in
                        BookmarkRow(bookmark: bookmark, fallbackTitle: chapterTitle(for: bookmark)) {
                            player.seekBookPosition(bookmark.bookPosition)
                            player.play()
                        }
                        .contextMenu {
                            Button {
                                renameDraft = bookmark.note
                                bookmarkBeingRenamed = bookmark
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                modelContext.delete(bookmark)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                        if index < book.sortedBookmarks.count - 1 {
                            Divider().overlay(.white.opacity(0.15))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
        }
    }

    private func chapterTitle(for bookmark: Bookmark) -> String {
        let chapters = book.sortedChapters
        guard chapters.indices.contains(bookmark.chapterIndex) else { return book.title }
        return chapters[bookmark.chapterIndex].title
    }

    private var playbackSpeedButton: some View {
        Menu {
            ForEach(viewModel.playbackRates, id: \.self) { rate in
                Button {
                    player.setPlaybackRate(rate)
                } label: {
                    if player.playbackRate == rate {
                        Label("\(rate, specifier: "%.2g")×", systemImage: "checkmark")
                    } else {
                        Text("\(rate, specifier: "%.2g")×")
                    }
                }
            }
        } label: {
            Text("\(player.playbackRate, specifier: "%.2g")×")
                .font(RavenDesign.Typography.labelCaps())
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func skipButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
    }
}

private struct BookmarkRow: View {
    let bookmark: Bookmark
    let fallbackTitle: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(.white.opacity(0.8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.note.isEmpty ? fallbackTitle : bookmark.note)
                        .font(RavenDesign.Typography.bodyUI().weight(.medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(bookmark.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(RavenDesign.Typography.labelCaps())
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Text(TimeFormatting.clock(bookmark.bookPosition))
                    .font(RavenDesign.Typography.labelCaps())
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct PlayerProgressSection: View {
    @Environment(AudioPlayerService.self) private var player
    @Bindable var viewModel: PlayerViewModel
    var controlSize: ControlSize = .regular

    var body: some View {
        VStack(spacing: RavenDesign.Spacing.stackSmall) {
            Slider(
                value: $viewModel.scrubValue,
                in: 0...max(player.bookTotalDuration, 1),
                onEditingChanged: { editing in
                    if editing {
                        viewModel.beginScrubbing(player: player)
                    } else {
                        viewModel.endScrubbing(player: player)
                    }
                }
            )
            .controlSize(controlSize)
            .tint(.white)

            HStack {
                Text(TimeFormatting.clock(viewModel.isScrubbing ? viewModel.scrubValue : player.bookElapsedTime))
                Spacer()
                Text(TimeFormatting.remaining(
                    viewModel.isScrubbing ? viewModel.scrubValue : player.bookElapsedTime,
                    total: player.bookTotalDuration
                ))
            }
            .font(RavenDesign.Typography.labelCaps())
            .foregroundStyle(.white.opacity(0.4))
            .monospacedDigit()
        }
        .onChange(of: player.bookElapsedTime) { _, _ in
            viewModel.bind(to: player)
        }
    }
}

private struct PlayerBedtimeButton: View {
    @Environment(AudioPlayerService.self) private var player

    var body: some View {
        Button {
            player.toggleBedtimeMode()
        } label: {
            Image(systemName: "moon.fill")
                .font(.title3)
                .foregroundStyle(
                    player.isBedtimeModeEnabled
                        ? RavenDesign.Colors.primaryFixedDim
                        : .white.opacity(0.8)
                )
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Bedtime mode")
    }
}

#Preview {
    PlayerView(book: Book(title: "The Name of the Wind", author: "Patrick Rothfuss"))
        .environment(AudioPlayerService())
        .modelContainer(for: [Book.self, Chapter.self, Bookmark.self], inMemory: true)
}
