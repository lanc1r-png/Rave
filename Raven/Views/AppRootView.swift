//
//  AppRootView.swift
//  Raven
//
//  Created by Ahsan Minhas on 28/05/2026.
//

import SwiftUI
import SwiftData

/// Configures shared services and handles app lifecycle for playback.
struct AppRootView: View {
    /// Set to `true` when library search ships.
    private static let showsSearchTab = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AudioPlayerService.self) private var player
    @Environment(DeepLinkRouter.self) private var router
    @State private var selection: AppTab = .library

    private enum AppTab: Hashable {
        case library, search, settings
    }

    var body: some View {
        TabView(selection: $selection) {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "book.closed.fill")
                }
                .tag(AppTab.library)

            if Self.showsSearchTab {
                SearchPlaceholderView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(AppTab.search)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
        .tint(RavenDesign.Colors.primary)
        .onAppear {
            player.configure(modelContext: modelContext)
        }
        .onChange(of: router.continueRequested, initial: true) { _, requested in
            if requested { selection = .library }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                player.handleAppBackgrounded()
            case .active:
                player.checkSleepTimerExpiry()
            case .inactive:
                player.handleAppBackgrounded()
            @unknown default:
                break
            }
        }
    }
}
