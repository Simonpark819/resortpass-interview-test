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
    let latitude: Double?
    let longitude: Double?
    let distanceSearchOnly: Bool?

    /// Custom decoder to handle `parentId` arriving as either
    /// an Int or a String depending on the place type.
    /// This is an API inconsistency we absorb at the model layer
    /// so nothing above it ever has to deal with it.
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        detailedType = try container.decode(String.self, forKey: .detailedType)
        url = try container.decode(String.self, forKey: .url)
        parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
        stateCode = try container.decodeIfPresent(String.self, forKey: .stateCode)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        cityName = try container.decodeIfPresent(String.self, forKey: .cityName)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        distanceSearchOnly = try container.decodeIfPresent(Bool.self, forKey: .distanceSearchOnly)

        // parentId can arrive as Int or String — try Int first, fall back to parsing String
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: .parentId) {
            parentId = intValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .parentId) {
            parentId = Int(stringValue)
        } else {
            parentId = nil
        }
    }

    /// setup to better handle API consistency issues where
    /// some places arriving with 0,0 or nil coordinates can't be used for hotel search
    var hasValidCoordinates: Bool {
        guard let latitude, let longitude else { return false }
        return latitude != 0 && longitude != 0
    }
}
