//
//  Spacing.swift
//  SimonPass
//

import Foundation

/// Spacing tokens derived from the ResortPass design spec.
///
/// Named by their point value so the amount is always unambiguous at the call site.
/// Use these instead of raw CGFloat literals to keep spacing consistent and refactorable.
enum Spacing {
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
}
