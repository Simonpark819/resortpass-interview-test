//
//  HotelListViewModel.swift
//  SimonPass
//

import Foundation

/// Manages state and data fetching for the hotel list screen.
/// Receives coordinates from the selected Place via the coordinator
/// and fetches matching hotels on initialization.
///
/// No Combine needed here — this is a single async operation
/// with no stream behavior, so async/await is the natural fit.
@Observable
final class HotelListViewModel {

    // MARK: - State

    enum ViewState {
        case loading
        case success([Hotel], Currency)
        case empty
        case error(String)
    }

    // MARK: - Properties

    private(set) var viewState: ViewState = .loading

    private let repository: HotelRepositoryProtocol
    private let latitude: Double
    private let longitude: Double

    /// Handle to the current fetch task.
    /// Stored to support cancellation if the view disappears
    /// before the request completes.
    private var fetchTask: Task<Void, Never>?

    // MARK: - Init

    init(
        repository: HotelRepositoryProtocol,
        latitude: Double,
        longitude: Double
    ) {
        self.repository = repository
        self.latitude = latitude
        self.longitude = longitude
    }

    // MARK: - Data fetching

    /// Initiates the hotel fetch. Called by the view on appear.
    /// Safe to call multiple times — cancels any in-flight task first.
    func fetchHotels() {
        fetchTask?.cancel()

        fetchTask = Task { [weak self] in
            guard let self else { return }

            viewState = .loading

            do {
                let response = try await repository.fetchHotels(
                    latitude: latitude,
                    longitude: longitude
                )

                guard !Task.isCancelled else { return }

                viewState = response.hotels.isEmpty
                    ? .empty
                    : .success(response.hotels, response.currency)
            } catch is CancellationError {
                // View disappeared before fetch completed — expected
            } catch {
                guard !Task.isCancelled else { return }
                viewState = .error(error.localizedDescription)
            }
        }
    }

    /// Called by the view when the user taps retry on the error state.
    func retry() {
        fetchHotels()
    }

    // MARK: - Cleanup

    /// Cancels any in-flight fetch when the view is no longer needed.
    func cancelFetch() {
        fetchTask?.cancel()
    }
}
