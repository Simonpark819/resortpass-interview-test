//
//  Hotel.swift
//  SimonPass
//

import Foundation

/// Represents a single hotel result from the search API.
struct Hotel: Codable, Identifiable {
    let id: Int
    let name: String
    let rating: Double
    let reviews: Int
    let cityName: String
    let stateCode: String
    let shortDesc: String
    let hotelStar: Int
    let latitude: Double
    let longitude: Double
    let images: [HotelImage]
    let products: [Product]
    let amenities: [Amenity]
    let availability: Bool
    let distanceMiles: Double
    let productName: String?
    let productCategories: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rating
        case reviews
        case cityName = "city_name"
        case stateCode = "state_code"
        case shortDesc = "short_desc"
        case hotelStar = "hotel_star"
        case latitude
        case longitude
        case images = "image"
        case products
        case amenities
        case availability
        case distanceMiles = "distance_miles"
        case productName = "product_name"
        case productCategories = "product_categories"
    }
}

/// Represents the nested image structure returned by the hotel search API.
/// The top-level `picture.url` is intentionally unexposed — it is a relative
/// path (e.g. /uploads/...) and cannot be used directly for network requests.
/// Only the fully qualified variant URLs are surfaced.
struct HotelImage: Codable {
    let picture: Picture

    struct Picture: Codable {
        /// Relative path only — not exposed outside this struct.
        private let url: String
        let results: ImageVariant?
        let details: ImageVariant?

        /// Represents a single size/crop variant of a hotel image.
        /// Both `results` and `details` share this shape but serve
        /// intentionally different contexts — results for list views,
        /// details for full hotel screens.
        struct ImageVariant: Codable {
            let url: String

            var asURL: URL? {
                URL(string: url)
            }
        }
    }

    /// The image variant optimized for list/search result contexts.
    var resultsImageURL: URL? {
        picture.results?.asURL
    }

    /// The image variant optimized for hotel detail screen contexts.
    var detailsImageURL: URL? {
        picture.details?.asURL
    }
}
