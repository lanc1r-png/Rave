//
//  DeepLinkRouter.swift
//  Raven
//

import Foundation
import Observation

/// Carries "continue listening" requests (from the widget) to the library screen.
@MainActor
@Observable
final class DeepLinkRouter {
    var continueRequested = false
}
