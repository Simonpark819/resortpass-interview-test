//
//  Colors.swift
//  SimonPass
//

import SwiftUI

/// Color tokens derived from the ResortPass design spec.
/// All colors support light and dark mode via asset catalog
/// or explicit light/dark variants.
enum Colors {

    // MARK: - Surface

    /// Primary surface background
    static let surfacePrimary = Color("Colors/SurfacePrimary")

    /// Standard system background fallback
    static let background = Color(.systemBackground)

    // MARK: - Border

    /// Secondary border color
    static let borderSecondary = Color("Colors/BorderSecondary")

    // MARK: - Shadow

    /// Card shadow color
    static let cardShadow = Color("Colors/CardShadow")

    // MARK: - Text

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}
