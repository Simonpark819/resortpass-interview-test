//
//  NetworkServiceTests.swift
//  SimonPassTests
//

import XCTest
@testable import SimonPass

@MainActor
final class NetworkServiceTests: XCTestCase {

    private var session: URLSession!
    private var service: NetworkService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        service = NetworkService(session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        session = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_request_withValidResponse_decodesSuccessfully() async throws {
        let place = Place.make()
        let data = try JSONEncoder().encode([PlaceEncodable(from: place)])

        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse.make(statusCode: 200), data)
        }

        let result: [Place] = try await service.request(.placeAutocomplete(terms: "Miami"))
        let resultName = result.first?.name
        XCTAssertEqual(resultName, place.name)
    }

    // MARK: - HTTP errors

    func test_request_with500Response_throwsHttpError() async {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse.make(statusCode: 500), Data())
        }

        do {
            let _: [Place] = try await service.request(.placeAutocomplete(terms: "Miami"))
            XCTFail("Expected httpError to be thrown")
        } catch let error as NetworkError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected .httpError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_request_with404Response_throwsHttpError() async {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse.make(statusCode: 404), Data())
        }

        do {
            let _: [Place] = try await service.request(.placeAutocomplete(terms: "Miami"))
            XCTFail("Expected httpError to be thrown")
        } catch let error as NetworkError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Expected .httpError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Invalid response

    func test_request_withNonHTTPResponse_throwsInvalidResponse() async {
        MockURLProtocol.requestHandler = { _ in
            (URLResponse(), Data())
        }

        do {
            let _: [Place] = try await service.request(.placeAutocomplete(terms: "Miami"))
            XCTFail("Expected invalidResponse to be thrown")
        } catch let error as NetworkError {
            if case .invalidResponse = error { } else {
                XCTFail("Expected .invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Decoding error

    func test_request_withMalformedJSON_throwsDecodingError() async {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse.make(statusCode: 200), Data("not json".utf8))
        }

        do {
            let _: [Place] = try await service.request(.placeAutocomplete(terms: "Miami"))
            XCTFail("Expected decodingError to be thrown")
        } catch let error as NetworkError {
            if case .decodingError = error { } else {
                XCTFail("Expected .decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - userMessage mapping

    func test_httpError500_userMessage_isServerMessage() {
        let error = NetworkError.httpError(statusCode: 500)
        XCTAssertEqual(error.userMessage, Strings.Error.server)
    }

    func test_httpError404_userMessage_isNotFoundMessage() {
        let error = NetworkError.httpError(statusCode: 404)
        XCTAssertEqual(error.userMessage, Strings.Error.notFound)
    }

    func test_httpError400_userMessage_isGenericMessage() {
        let error = NetworkError.httpError(statusCode: 400)
        XCTAssertEqual(error.userMessage, Strings.Error.generic)
    }

    func test_invalidResponse_userMessage_isGenericMessage() {
        XCTAssertEqual(NetworkError.invalidResponse.userMessage, Strings.Error.generic)
    }

    func test_decodingError_userMessage_isGenericMessage() {
        let error = NetworkError.decodingError(NSError(domain: "test", code: 0))
        XCTAssertEqual(error.userMessage, Strings.Error.generic)
    }
}
