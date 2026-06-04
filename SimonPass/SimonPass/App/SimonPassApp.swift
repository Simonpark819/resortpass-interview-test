//
//  SimonPassApp.swift
//  SimonPass
//

import SwiftUI

@main
struct SimonPassApp: App {

    @State private var coordinator: AppCoordinator

        init() {
            let container = AppContainer()
            _coordinator = .init(wrappedValue: AppCoordinator(container: container))
        }

        var body: some Scene {
            WindowGroup {
                NavigationStack(path: $coordinator.path) {
                    SearchView(
                        viewModel: coordinator.makeSearchViewModel(),
                        onPlaceSelected: { place, latitude, longitude in
                            coordinator.show(.hotelList(place: place, latitude: latitude, longitude: longitude))
                        }
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        coordinator.view(for: route)
                    }
                }
                .environment(coordinator)
            }
        }
}
