//
//  Strings.swift
//  SimonPass
//

/// All user-facing strings in the app.
///
/// Grouped by feature namespace with a Common bucket for shared copy.
/// No string literals should appear directly in views — reference these instead.
enum Strings {

    // MARK: - Search

    enum Search {
        static let placeholder = "Search destinations..."
        static let idleTitle = "Search destinations"
        static let idleDescription = "Type a city, state, or hotel name to get started."
    }

    // MARK: - Hotel list

    enum HotelList {
        static let emptyTitle = "No hotels found"
        static let emptyDescription = "There are no available hotels for this location."
        static func fromPrice(symbol: String, amount: Int) -> String {
            "From \(symbol)\(amount)"
        }
    }

    // MARK: - Common

    enum Common {
        static let errorTitle = "Something went wrong"
        static let retryButton = "Try again"
    }
}
