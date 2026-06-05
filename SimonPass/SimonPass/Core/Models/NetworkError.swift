//
//  NetworkError.swift
//  SimonPass
//

import Foundation

/// The networking error cases the app can encounter.
/// Keeping these explicit avoids leaking URLSession internals
/// into the rest of the app.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .decodingError:
            return "The response could not be decoded."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    /// User-facing message suitable for display in the UI.
    /// Distinct from errorDescription, which is a developer-facing diagnostic.
    var userMessage: String {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError, .unknown:
            return Strings.Error.generic
        case .httpError(let statusCode) where statusCode >= 500:
            return Strings.Error.server
        case .httpError(let statusCode) where statusCode == 404:
            return Strings.Error.notFound
        case .httpError:
            return Strings.Error.generic
        }
    }
}
