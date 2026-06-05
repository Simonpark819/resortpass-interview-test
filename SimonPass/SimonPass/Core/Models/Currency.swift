//
//  Currency.swift
//  SimonPass
//

import Foundation

/// Represents the currency metadata returned in the response envelope.
struct Currency: Codable, Equatable {
    let symbol: String
    let name: String
    let isoCode: String
}
