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

    /// Primary surface background — #FEFEFE
    static let surfacePrimary = Color(hex: "#FEFEFE")

    /// Standard system background fallback
    static let background = Color(.systemBackground)

    // MARK: - Border

    /// Secondary border color — #EEEFF2
    static let borderSecondary = Color(hex: "#EEEFF2")

    // MARK: - Shadow

    /// Card shadow color — #6A7287 at 12% opacity
    static let cardShadow = Color(hex: "#6A7287").opacity(0.12)

    // MARK: - Text

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}

// MARK: - Hex initializer

extension Color {

    /// Convenience initializer for hex color strings.
    /// Accepts formats: "#RRGGBB" or "RRGGBB"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
