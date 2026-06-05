//
//  A11y.swift
//  SimonPass
//

import Foundation

/// Accessibility labels, hints, and descriptions for assistive technologies.
///
/// Kept separate from Strings.swift — display copy and accessibility metadata
/// serve different audiences and evolve independently.
///
/// Naming follows the a11y numeronym convention (a + 11 letters + y).
enum A11y {

    // MARK: - Search

    enum Search {
        static let clearButton = "Clear search"
        static let searchFieldLabel = "Search destinations"
        static let placeRowHint = "Search for hotels in this location"
        static let unavailablePlaceHint = "Location not available"
    }

    // MARK: - Hotel list

    enum HotelList {
        static let backButton = "Go back"

        static func hotelCard(
            name: String,
            rating: Double,
            reviews: Int?,
            city: String,
            stateCode: String,
            productName: String?,
            price: String?
        ) -> String {
            var parts = [name]

            if let reviews {
                parts.append("Rated \(String(format: "%.1f", rating)) out of 5 from \(reviews) reviews")
            } else {
                parts.append("Rated \(String(format: "%.1f", rating)) out of 5")
            }

            parts.append("\(city), \(stateCode)")

            if let productName, let price {
                parts.append("\(productName), \(price)")
            }

            return parts.joined(separator: ". ")
        }

        static func favoriteButton(hotelName: String) -> String {
            "Save \(hotelName)"
        }

        static func hotelImage(hotelName: String) -> String {
            "Photo of \(hotelName)"
        }
    }

    // MARK: - Common

    enum Common {
        static let loadingIndicator = "Loading"
        static let errorIcon = "Error"
    }
}
