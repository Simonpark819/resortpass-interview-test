//
//  Radius.swift
//  SimonPass
//

import Foundation

/// Corner radius tokens derived from the ResortPass design spec.
enum Radius {

    /// 4pt — Radius-minimal, used on card images and search bar
    static let minimal: CGFloat = 4

    /// 10pt — search bar outer container
    static let medium: CGFloat = 10

    /// 12pt — full card radius where applicable
    static let large: CGFloat = 12
}
