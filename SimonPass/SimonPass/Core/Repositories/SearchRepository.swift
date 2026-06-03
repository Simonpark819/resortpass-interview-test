//
//  SearchRepository.swift
//  SimonPass
//

import Foundation

protocol SearchRepositoryProtocol {
    func searchPlaces(terms: String) async throws -> [Place]
}

final class SearchRepository: SearchRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func searchPlaces(terms: String) async throws -> [Place] {
        try await networkService.request(.placeAutocomplete(terms: terms))
    }
}
