//
//  NetworkService.swift
//  SimonPass
//

import Foundation

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
        let urlRequest = try endpoint.makeURLRequest()

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
