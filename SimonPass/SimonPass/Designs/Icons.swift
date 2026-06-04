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
    static let starPartialFilled = Image(systemName: "star.leadinghalf.filled")
    static let starFilled = Image(systemName: "star.fill")

    static let favoriteFilled = Image("Icons/icon_favorite_filled")
    static let favorite = Image("Icons/icon_favorite")

    static let back = Image(systemName: "chevron.left")
    static let clear = Image(systemName: "xmark.circle.fill")
    static let hotel = Image(systemName: "bed.double.fill")
    static let location = Image(systemName: "mappin.and.ellipse")
}
