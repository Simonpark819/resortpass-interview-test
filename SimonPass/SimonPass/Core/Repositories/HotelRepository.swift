//
//  HotelRepository.swift
//  SimonPass
//

import Foundation

protocol HotelRepositoryProtocol {
    func fetchHotels(latitude: Double, longitude: Double) async throws -> HotelSearchResponse
}

final class HotelRepository: HotelRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchHotels(latitude: Double, longitude: Double) async throws -> HotelSearchResponse {
        try await networkService.request(.hotelSearch(latitude: latitude, longitude: longitude))
    }
}
