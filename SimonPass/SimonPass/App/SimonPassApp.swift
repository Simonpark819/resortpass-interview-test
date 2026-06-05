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
            configureURLCache()
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

    // MARK: - Cache configuration

    /// Configures URLCache with generous memory and disk capacity
    /// for hotel images served from S3 with max-age=31536000.
    /// Search API responses are not cached — the server sets
    /// max-age=0, private on those endpoints intentionally.
    private func configureURLCache() {
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,    // 50MB in-memory
            diskCapacity: 200 * 1024 * 1024,      // 200MB on-disk
            diskPath: "image_cache"
        )
    }
}
