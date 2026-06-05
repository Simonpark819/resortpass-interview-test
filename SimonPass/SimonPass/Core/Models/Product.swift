//
//  Product.swift
//  SimonPass
//

import Foundation

/// Represents a bookable product attached to a hotel.
struct Product: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let availability: String
    let productTypeName: String
    let productCategories: [String]
}
