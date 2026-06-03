//
//  APIEndpoint.swift
//  SimonPass
//

import Foundation

/*
       get
            /api/search/places/autocomplete?terms=beach&limit=10&offset=0
       post
            /api/search/algolia_hotels_v7
 */

/// Defines all API endpoints in the app. Each case encapsulates
/// everything needed to construct a valid URLRequest — method,
/// path, and parameters — keeping that responsibility out of
/// the network service and repositories.
enum APIEndpoint {
    case placeAutocomplete(terms: String, limit: Int = 10, offset: Int = 0)
    case hotelSearch(latitude: Double, longitude: Double, limit: Int = 30, offset: Int = 0)
}

// MARK: - Request construction

extension APIEndpoint {

    /// The base URL for all API requests.
    private static let baseURL = "https://staging-app.resortpass.com/api"

    var urlRequest: URLRequest {
        get throws {
            switch self {
            case .placeAutocomplete(let terms, let limit, let offset):
                return try makeAutocompleteRequest(terms: terms, limit: limit, offset: offset)
            case .hotelSearch(let latitude, let longitude, let limit, let offset):
                return try makeHotelSearchRequest(latitude: latitude, longitude: longitude, limit: limit, offset: offset)
            }
        }
    }

    // MARK: - Private builders

    private func makeAutocompleteRequest(
        terms: String,
        limit: Int,
        offset: Int
    ) throws -> URLRequest {
        guard var components = URLComponents(string: "\(APIEndpoint.baseURL)/search/places/autocomplete") else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "terms", value: terms),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }

    private func makeHotelSearchRequest(
        latitude: Double,
        longitude: Double,
        limit: Int,
        offset: Int
    ) throws -> URLRequest {
        guard let url = URL(string: "\(APIEndpoint.baseURL)/search/algolia_hotels_v7") else {
            throw NetworkError.invalidURL
        }

        let body = HotelSearchRequestBody(
            location: .init(latitude: latitude, longitude: longitude),
            limit: limit,
            offset: offset
        )

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
}

// MARK: - Supporting types

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Request body for the hotel search endpoint.
private struct HotelSearchRequestBody: Encodable {
    let location: Location
    let limit: Int
    let offset: Int

    struct Location: Encodable {
        let latitude: Double
        let longitude: Double
    }
}
