//
//  Place.swift
//  SimonPass
//

import Foundation

/// Represents a single autocomplete suggestion returned by the places search API.
struct Place: Codable, Hashable {
    let id: Int
    let name: String
    let type: String
    let detailedType: String
    let url: String
    let parentId: Int?
    let parentType: String?
    let stateCode: String?
    let countryCode: String?
    let cityName: String?
    let latitude: Double
    let longitude: Double
    let distanceSearchOnly: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case detailedType = "detailed_type"
        case url
        case parentId = "parent_id"
        case parentType = "parent_type"
        case stateCode = "state_code"
        case countryCode = "country_code"
        case cityName = "city_name"
        case latitude
        case longitude
        case distanceSearchOnly = "distance_search_only"
    }
}
