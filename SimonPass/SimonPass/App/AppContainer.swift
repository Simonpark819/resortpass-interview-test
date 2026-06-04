//
//  AppContainer.swift
//  SimonPass
//

import Foundation

/// The app's dependency container. Constructs and owns all
/// shared dependencies and acts as the factory for ViewModels.
///
/// This is the only place in the app where concrete types are
/// referenced directly — everything else depends on protocols.
final class AppContainer {

    // MARK: - Shared dependencies

    private let networkService: NetworkServiceProtocol
    private let searchRepository: SearchRepositoryProtocol
    private let hotelRepository: HotelRepositoryProtocol

    // MARK: - Init

    init() {
        let networkService = NetworkService()
        self.networkService = networkService
        self.searchRepository = SearchRepository(networkService: networkService)
        self.hotelRepository = HotelRepository(networkService: networkService)
    }

    // MARK: - ViewModel factories

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: searchRepository)
    }

    func makeHotelListViewModel(latitude: Double, longitude: Double) -> HotelListViewModel {
        HotelListViewModel(
            repository: hotelRepository,
            latitude: latitude,
            longitude: longitude
        )
    }
}
