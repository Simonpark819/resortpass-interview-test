//
//  PlaceTests.swift
//  SimonPassTests
//

import XCTest
@testable import SimonPass

final class PlaceTests: XCTestCase {

    // MARK: - hasValidCoordinates

    func test_hasValidCoordinates_withValidCoords_returnsTrue() {
        let place = Place.make(latitude: 25.7617, longitude: -80.1918)
        XCTAssertTrue(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withNilLatitude_returnsFalse() {
        let place = Place.make(latitude: nil, longitude: -80.1918)
        XCTAssertFalse(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withNilLongitude_returnsFalse() {
        let place = Place.make(latitude: 25.7617, longitude: nil)
        XCTAssertFalse(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withBothNil_returnsFalse() {
        let place = Place.make(latitude: nil, longitude: nil)
        XCTAssertFalse(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withZeroLatitude_returnsFalse() {
        let place = Place.make(latitude: 0.0, longitude: -80.1918)
        XCTAssertFalse(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withZeroLongitude_returnsFalse() {
        let place = Place.make(latitude: 25.7617, longitude: 0.0)
        XCTAssertFalse(place.hasValidCoordinates)
    }

    func test_hasValidCoordinates_withBothZero_returnsFalse() {
        let place = Place.make(latitude: 0.0, longitude: 0.0)
        XCTAssertFalse(place.hasValidCoordinates)
    }
}
