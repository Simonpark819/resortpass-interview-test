//
//  APIEndpointTests.swift
//  SimonPassTests
//

import XCTest
@testable import SimonPass

final class APIEndpointTests: XCTestCase {

    // MARK: - placeAutocomplete

    func test_autocomplete_buildsCorrectURL() throws {
        let request = try APIEndpoint.placeAutocomplete(terms: "Miami").makeURLRequest()

        XCTAssertEqual(request.httpMethod, "GET")

        let components = try XCTUnwrap(URLComponents(url: XCTUnwrap(request.url), resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.path, "/api/search/places/autocomplete")

        let queryItems = try XCTUnwrap(components.queryItems)
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "terms", value: "Miami")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "limit", value: "10")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "offset", value: "0")))
    }

    func test_autocomplete_encodesSpecialCharactersInTerms() throws {
        let request = try APIEndpoint.placeAutocomplete(terms: "New York").makeURLRequest()
        let url = try XCTUnwrap(request.url)
        XCTAssertTrue(url.absoluteString.contains("New%20York") || url.absoluteString.contains("New+York"))
    }

    func test_autocomplete_respectsCustomLimitAndOffset() throws {
        let request = try APIEndpoint.placeAutocomplete(terms: "beach", limit: 5, offset: 10).makeURLRequest()

        let components = try XCTUnwrap(URLComponents(url: XCTUnwrap(request.url), resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "limit", value: "5")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "offset", value: "10")))
    }

    // MARK: - hotelSearch

    func test_hotelSearch_buildsCorrectURL() throws {
        let request = try APIEndpoint.hotelSearch(latitude: 25.7617, longitude: -80.1918).makeURLRequest()

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/search/algolia_hotels_v7")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func test_hotelSearch_encodesCoordinatesInBody() throws {
        let request = try APIEndpoint.hotelSearch(latitude: 25.7617, longitude: -80.1918).makeURLRequest()

        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        let location = try XCTUnwrap(json["location"] as? [String: Double])

        XCTAssertEqual(location["latitude"], 25.7617)
        XCTAssertEqual(location["longitude"], -80.1918)
    }

    func test_hotelSearch_encodesDefaultLimitAndOffset() throws {
        let request = try APIEndpoint.hotelSearch(latitude: 25.7617, longitude: -80.1918).makeURLRequest()

        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])

        XCTAssertEqual(json["limit"] as? Int, 30)
        XCTAssertEqual(json["offset"] as? Int, 0)
    }
}
