//
//  NetworkService.swift
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
}

/// Protocol defining the networking contract.
/// Keeping this as a protocol means repositories depend on an
/// abstraction, making them independently testable with a mock.
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

/// Concrete URLSession-backed implementation of `NetworkServiceProtocol`.
final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    /// Executes a network request for the given endpoint and decodes
    /// the response into the inferred `Decodable` type.
    ///
    /// - Parameter endpoint: The `APIEndpoint` case describing the request.
    /// - Returns: A decoded instance of `T`.
    /// - Throws: A `NetworkError` describing what went wrong.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try endpoint.urlRequest

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
