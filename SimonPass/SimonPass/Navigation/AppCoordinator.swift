//
//  AppCoordinator.swift
//  SimonPass
//

import SwiftUI

/// The single source of truth for all navigation in the app.
/// Views never push or pop directly — they call the coordinator
/// which decides what happens next and constructs the destination.
///
/// All dependencies are sourced from AppContainer, keeping
/// view construction and dependency wiring out of the views themselves.
@Observable
final class AppCoordinator {

    // MARK: - Properties

    var path: NavigationPath = NavigationPath()
    private let container: AppContainer

    // MARK: - Init

    init(container: AppContainer) {
        self.container = container
    }

    // MARK: - Navigation actions

    func show(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    // MARK: - View model factories

    func makeSearchViewModel() -> SearchViewModel {
        container.makeSearchViewModel()
    }

    func makeHotelListViewModel(latitude: Double, longitude: Double) -> HotelListViewModel {
        container.makeHotelListViewModel(latitude: latitude, longitude: longitude)
    }

    // MARK: - View factory

    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .hotelList(let place, let latitude, let longitude):
            HotelListView(
                viewModel: makeHotelListViewModel(
                    latitude: latitude,
                    longitude: longitude
                )
            )
            .navigationTitle(place.name)
        }
    }
}
