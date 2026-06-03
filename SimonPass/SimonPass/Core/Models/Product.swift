//
//  Product.swift
//  SimonPass
//

import Foundation

/// Represents a bookable product attached to a hotel.
struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let availability: String
    let productTypeName: String
    let productCategories: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case availability
        case productTypeName = "product_type_name"
        case productCategories = "product_categories"
    }
}
