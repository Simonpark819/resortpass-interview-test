//
//  HotelSearchResponse.swift
//  SimonPass
//

import Foundation

/// Top-level response envelope from the hotel search API.
struct HotelSearchResponse: Codable {
    let total: Int
    let page: Int
    let pages: Int
    let hotels: [Hotel]
    let currency: Currency
}
