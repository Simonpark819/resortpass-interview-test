//
//  Hotel.swift
//  SimonPass
//

import Foundation

/// Represents a single hotel result from the search API.
struct Hotel: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let rating: Double?
    let reviews: Int?
    let cityName: String
    let stateCode: String
    let shortDesc: String?
    let hotelStar: Int?
    let latitude: Double
    let longitude: Double
    let image: [HotelImage]
    let products: [Product]
    let amenities: [Amenity]
    let availability: Bool
    let distanceMiles: Double?
    let productName: String?
    let productCategories: [String]
}

/// Represents the nested image structure returned by the hotel search API.
/// The top-level `picture.url` is intentionally unexposed — it is a relative
/// path (e.g. /uploads/...) and cannot be used directly for network requests.
/// Only the fully qualified variant URLs are surfaced.
struct HotelImage: Codable, Equatable {
    let picture: Picture

    struct Picture: Codable, Equatable {
        /// Relative path only — not exposed outside this struct.
        private let url: String
        let results: ImageVariant?
        let details: ImageVariant?

        /// Represents a single size/crop variant of a hotel image.
        /// Both `results` and `details` share this shape but serve
        /// intentionally different contexts — results for list views,
        /// details for full hotel screens.
        struct ImageVariant: Codable, Equatable {
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
