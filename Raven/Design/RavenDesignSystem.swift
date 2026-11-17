//
//  RavenDesignSystem.swift
//  Raven
//
//  Created by Ahsan Minhas on 29/05/2026.
//

import SwiftUI
import UIKit

/// Stitch design tokens mapped to SwiftUI.
enum RavenDesign {
    enum Colors {
        static let paper = Color("LaunchBackground")
        static let primary = Color("RavenPrimary")
        static let onPrimary = Color.white
        static let onSurface = Color("RavenOnSurface")
        static let onSurfaceVariant = Color("RavenOnSurfaceVariant")
        static let outlineVariant = Color("RavenOutlineVariant")
        static let surfaceContainerHighest = Color("RavenSurfaceContainerHighest")
        static let surfaceLowest = Color("RavenSurfaceLowest")
        static let surfaceContainer = Color("RavenSurfaceContainer")
        static let secondaryContainer = Color("RavenSecondaryContainer")
        static let primaryContainer = Color("RavenPrimaryContainer")
        static let playerSurface = Color("RavenPlayerSurface")
        static let primaryFixedDim = Color("RavenPrimaryFixedDim")
    }

    enum Typography {
        static func displayLarge() -> Font {
            .system(size: 34, weight: .bold, design: .serif)
        }

        static func headlineMedium() -> Font {
            .system(size: 22, weight: .semibold, design: .default)
        }

        static func bodyUI() -> Font {
            .system(size: 17, weight: .regular, design: .default)
        }

        static func bodyReading() -> Font {
            .system(size: 20, weight: .regular, design: .serif)
        }

        static func transcriptActive() -> Font {
            .system(size: 24, weight: .medium, design: .serif)
        }

        static func labelCaps() -> Font {
            .system(size: 12, weight: .semibold, design: .default)
        }
    }

    enum Spacing {
        static let pageMargin: CGFloat = 20
        static let stackLarge: CGFloat = 32
        static let stackMedium: CGFloat = 16
        static let stackSmall: CGFloat = 8
    }

    enum BookCover {
        static let featuredSize: CGFloat = 96
        static let compactSize: CGFloat = 64
    }
}

struct RavenPrimaryButton: View {
    let title: String
    let systemImage: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(RavenDesign.Typography.bodyUI())
            .padding(.horizontal, 28)
            .padding(.vertical, 6)
        }
        .buttonStyle(.glassProminent)
        .tint(RavenDesign.Colors.primary)
        .buttonBorderShape(.capsule)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

struct RavenPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LibraryScreenHeader: View {
    var onAddFolder: (() -> Void)?
    var isAddDisabled = false

    var body: some View {
        HStack(alignment: .center) {
            Text("Library")
                .font(RavenDesign.Typography.displayLarge())
                .foregroundStyle(RavenDesign.Colors.onSurface)
            Spacer()
            if let onAddFolder {
                Button(action: onAddFolder) {
                    Image(systemName: "folder.badge.plus")
                        .font(.title3)
                        .foregroundStyle(RavenDesign.Colors.onSurface)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .disabled(isAddDisabled)
                .opacity(isAddDisabled ? 0.5 : 1)
                .accessibilityLabel("Add folder")
            }
        }
        .padding(.horizontal, RavenDesign.Spacing.pageMargin)
        .padding(.bottom, RavenDesign.Spacing.stackSmall)
        .padding(.top, 4)
        .frame(maxWidth: .infinity)
    }
}

struct RavenProgressBar: View {
    let progress: Double
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(RavenDesign.Colors.surfaceContainerHighest)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(RavenDesign.Colors.primary)
                        .frame(width: geometry.size.width * min(max(progress, 0), 1))
                }
        }
        .frame(height: height)
    }
}

struct RavenLibraryCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(RavenDesign.Spacing.pageMargin)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

/// Ambient backdrop that gives Liquid Glass something to refract:
/// the current cover blurred and enlarged, or soft tinted blobs when there is none.
struct RavenAmbientBackground: View {
    var artworkData: Data?
    var darken: Double = 0

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            RavenDesign.Colors.paper

            if let artworkData, let image = UIImage(data: artworkData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.6)
                    .blur(radius: 60)
                    .saturation(1.3)
                    .opacity(colorScheme == .dark ? 0.55 : 0.45)
            } else {
                Circle()
                    .fill(RavenDesign.Colors.primary.opacity(0.35))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: -120, y: -260)
                Circle()
                    .fill(RavenDesign.Colors.primaryContainer.opacity(0.45))
                    .frame(width: 360, height: 360)
                    .blur(radius: 90)
                    .offset(x: 140, y: 280)
            }

            if darken > 0 {
                Color.black.opacity(darken)
            }
        }
        .ignoresSafeArea()
    }
}
