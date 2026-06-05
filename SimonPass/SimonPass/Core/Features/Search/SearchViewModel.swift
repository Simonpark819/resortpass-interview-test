//
//  SearchViewModel.swift
//  SimonPass
//

import Foundation
import Combine

/// Manages state and search logic for the autocomplete search screen.
///
/// Input handling (debounce) is managed via Combine, consistent with
/// its strengths as a stream operator framework and the team's familiarity
/// with reactive input handling from RxSwift contexts.
///
/// All network work is handled via async/await with structured Task
/// cancellation — Combine is not used beyond the input boundary.
@Observable
final class SearchViewModel {

    // MARK: - State

    enum ViewState: Equatable {
        case idle
        case loading
        case success([Place])
        case empty
        case error(String)
    }

    // MARK: - Observable properties

    private(set) var viewState: ViewState = .idle

    /// Exposed for two-way binding with the search field in the view.
    /// Changes are fed into the Combine pipeline via `searchSubject`.
    var searchText: String = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }

    // MARK: - Private properties

    private let repository: SearchRepositoryProtocol
    private let debounceInterval: Int

    /// The entry point for the Combine debounce pipeline.
    /// Receives raw search text on every keystroke.
    private let searchSubject = PassthroughSubject<String, Never>()

    /// Handle to the current in-flight network Task.
    /// Stored so it can be explicitly cancelled before a new one starts.
    private var searchTask: Task<Void, Never>?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(repository: SearchRepositoryProtocol, debounceInterval: Int = 500) {
        self.repository = repository
        self.debounceInterval = debounceInterval
        bindSearchPipeline()
    }

    // MARK: - Combine input pipeline

    /// Connects the search subject to the network layer via a debounced
    /// Combine pipeline. This is the only place Combine is used —
    /// purely to manage the input stream behavior before handing
    /// off to async/await for the actual network work.
    private func bindSearchPipeline() {
        searchSubject
            .debounce(for: .milliseconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] terms in
                guard let self else { return }
                handleDebouncedInput(terms)
            }
            .store(in: &cancellables)
    }

    /// Called once the debounce threshold is met.
    /// Clears state for empty input, otherwise fires a network request.
    private func handleDebouncedInput(_ terms: String) {
        let trimmed = terms.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            searchTask?.cancel()
            viewState = .idle
            return
        }

        performSearch(terms: trimmed)
    }

    // MARK: - Network execution

    /// Cancels any in-flight request and starts a new search Task.
    /// Structured cancellation ensures stale responses never update state.
    private func performSearch(terms: String) {
        searchTask?.cancel()

        searchTask = Task { [weak self] in
            guard let self else { return }

            viewState = .loading

            do {
                let places = try await repository.searchPlaces(terms: terms)

                viewState = places.isEmpty ? .empty : .success(places)
            } catch is CancellationError {
                // A newer keystroke cancelled this task — expected, not an error
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Public actions

    /// Called by the view when the user taps retry on the error state.
    func retry() {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        performSearch(terms: trimmed)
    }

    /// Called by the view when the user clears the search field.
    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        viewState = .idle
    }
}
