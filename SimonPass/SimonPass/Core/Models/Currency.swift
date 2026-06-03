//
//  Currency.swift
//  SimonPass
//

import Foundation

/// Represents the currency metadata returned in the response envelope.
struct Currency: Codable {
    let symbol: String
    let name: String
    let isoCode: String

    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case isoCode = "iso_code"
    }
}
