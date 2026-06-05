//
//  Icons.swift
//  SimonPass
//

import SwiftUI

/// Centralizes all custom icon references.
/// Prevents raw string literals from being scattered across the codebase
/// and makes missing asset errors easier to catch.
enum Icons {
    static let starEmpty = Image(systemName: "star")
    static let starHalfFilled = Image(systemName: "star.leadinghalf.filled")
    static let starFilled = Image(systemName: "star.fill")

    static let favorite = Image(systemName: "heart")
    static let favoriteFilled = Image(systemName: "heart.fill")

    static let back = Image("Icons/icon_back")
    static let clear = Image("Icons/icon_clear")
    static let hotel = Image("Icons/icon_hotel")
    static let location = Image("Icons/icon_location")
}
