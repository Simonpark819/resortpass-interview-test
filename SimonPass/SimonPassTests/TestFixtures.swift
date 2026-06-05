//
//  TestFixtures.swift
//  SimonPassTests
//
//  Mocks and model factories used across all test files.

import Foundation
@testable import SimonPass

// MARK: - Mocks

final class MockSearchRepository: SearchRepositoryProtocol {
    var result: Result<[Place], Error> = .success([])
    var callCount = 0

    func searchPlaces(terms: String) async throws -> [Place] {
        callCount += 1
        return try result.get()
    }
}

final class MockHotelRepository: HotelRepositoryProtocol {
    var result: Result<HotelSearchResponse, Error> = .success(.make())
    var callCount = 0
    var delay = false

    func fetchHotels(latitude: Double, longitude: Double) async throws -> HotelSearchResponse {
        callCount += 1
        if delay { try await Task.sleep(for: .seconds(10)) }
        return try result.get()
    }
}

// MARK: - Place factory

extension Place {
    static func make(
        id: Int = 1,
        name: String = "Miami, Florida",
        type: String = "city",
        detailedType: String = "city",
        url: String = "/miami-florida",
        latitude: Double? = 25.7617,
        longitude: Double? = -80.1918
    ) -> Place {
        // Build JSON and decode to correctly exercise the custom init(from:)
        let json: [String: Any?] = [
            "id": id,
            "name": name,
            "type": type,
            "detailed_type": detailedType,
            "url": url,
            "parent_id": nil,
            "parent_type": nil,
            "state_code": "FL",
            "country_code": "US",
            "city_name": "Miami",
            "latitude": latitude,
            "longitude": longitude,
            "distance_search_only": nil
        ]
        let data = try! JSONSerialization.data(withJSONObject: json.compactMapValues { $0 })
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(Place.self, from: data)
    }
}

// MARK: - Hotel factory

extension Hotel {
    static func make(
        id: Int = 1,
        name: String = "Eden Roc Miami Beach",
        rating: Double? = 4.7,
        reviews: Int? = 542,
        cityName: String = "Miami",
        stateCode: String = "FL"
    ) -> Hotel {
        Hotel(
            id: id,
            name: name,
            rating: rating,
            reviews: reviews,
            cityName: cityName,
            stateCode: stateCode,
            shortDesc: nil,
            hotelStar: 5,
            latitude: 25.7617,
            longitude: -80.1918,
            image: [],
            products: [],
            amenities: [],
            availability: true,
            distanceMiles: nil,
            productName: nil,
            productCategories: []
        )
    }
}

// MARK: - Currency factory

extension Currency {
    static func make(
        symbol: String = "$",
        name: String = "US Dollar",
        isoCode: String = "USD"
    ) -> Currency {
        Currency(symbol: symbol, name: name, isoCode: isoCode)
    }
}

// MARK: - HotelSearchResponse factory

extension HotelSearchResponse {
    static func make(
        hotels: [Hotel] = [.make()],
        currency: Currency = .make()
    ) -> HotelSearchResponse {
        HotelSearchResponse(total: hotels.count, page: 1, pages: 1, hotels: hotels, currency: currency)
    }
}

// MARK: - HTTPURLResponse factory

extension HTTPURLResponse {
    static func make(statusCode: Int, url: URL = URL(string: "https://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - PlaceEncodable
// Place uses a custom Decodable init but isn't Encodable.
// This mirror struct is used in tests to produce valid JSON for NetworkService tests.

struct PlaceEncodable: Encodable {
    let id: Int
    let name: String
    let type: String
    let detailedType: String
    let url: String
    let latitude: Double?
    let longitude: Double?

    init(from place: Place) {
        id = place.id
        name = place.name
        type = place.type
        detailedType = place.detailedType
        url = place.url
        latitude = place.latitude
        longitude = place.longitude
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, url, latitude, longitude
        case detailedType = "detailed_type"
    }
}
