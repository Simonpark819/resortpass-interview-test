//
//  Typography.swift
//  SimonPass
//

import SwiftUI

/// Typography tokens derived from the ResortPass design spec.
/// Basetica is the specified typeface — San Francisco is used
/// as a platform-appropriate substitute since Basetica is a
/// licensed commercial font.
enum Typography {

    // MARK: - Search

    /// Search row place name — 14pt medium
    static let searchRowTitle = Font.system(size: 14, weight: .medium)

    // MARK: - Hotel card

    /// Hotel card title — 16pt medium
    static let hotelCardTitle = Font.system(size: 16, weight: .medium)

    /// Hotel card rating and location line — 14pt regular
    static let hotelCardSubtitle = Font.system(size: 14, weight: .regular)

    /// Search results screen title — 16pt regular, tighter tracking
    static let screenTitle = Font.system(size: 16, weight: .regular)
}
