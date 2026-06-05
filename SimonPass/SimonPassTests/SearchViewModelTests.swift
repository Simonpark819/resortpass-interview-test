//
//  SearchViewModelTests.swift
//  SimonPassTests
//

import XCTest
@testable import SimonPass

final class SearchViewModelTests: XCTestCase {

    private var repository: MockSearchRepository!
    private var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()
        repository = MockSearchRepository()
        viewModel = SearchViewModel(repository: repository, debounceInterval: 0)
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_isIdle() {
        XCTAssertEqual(viewModel.viewState, .idle)
        XCTAssertEqual(viewModel.searchText, "")
    }

    // MARK: - clearSearch

    func test_clearSearch_resetsTextAndState() async throws {
        repository.result = .success([Place.make()])
        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.viewState, .idle)
    }

    func test_clearSearch_fromIdleState_remainsIdle() {
        viewModel.clearSearch()

        XCTAssertEqual(viewModel.viewState, .idle)
        XCTAssertEqual(viewModel.searchText, "")
    }

    // MARK: - Search results

    func test_searchText_withResults_setsSuccessState() async throws {
        let places = [Place.make()]
        repository.result = .success(places)

        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(viewModel.viewState, .success(places))
    }

    func test_searchText_withEmptyResults_setsEmptyState() async throws {
        repository.result = .success([])

        viewModel.searchText = "xyzzy"
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(viewModel.viewState, .empty)
    }

    func test_searchText_withError_setsErrorState() async throws {
        repository.result = .failure(NetworkError.invalidResponse)

        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        if case .error = viewModel.viewState {
            // pass
        } else {
            XCTFail("Expected .error state, got \(viewModel.viewState)")
        }
    }

    func test_searchText_whitespaceOnly_resetsToIdle() async throws {
        repository.result = .success([Place.make()])
        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        viewModel.searchText = "   "
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(viewModel.viewState, .idle)
    }

    func test_searchText_empty_resetsToIdle() async throws {
        repository.result = .success([Place.make()])
        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        viewModel.searchText = ""
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(viewModel.viewState, .idle)
    }

    // MARK: - retry

    func test_retry_withValidSearchText_refetches() async throws {
        repository.result = .failure(NetworkError.invalidResponse)
        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        repository.result = .success([Place.make()])
        viewModel.retry()
        try await Task.sleep(for: .milliseconds(50))

        if case .success = viewModel.viewState {
            // pass
        } else {
            XCTFail("Expected .success state after retry, got \(viewModel.viewState)")
        }
    }

    func test_retry_withEmptySearchText_doesNotFetch() {
        viewModel.retry()

        XCTAssertEqual(repository.callCount, 0)
    }

    // MARK: - Debounce / deduplication

    func test_duplicateSearchText_doesNotTriggerMultipleFetches() async throws {
        repository.result = .success([Place.make()])

        viewModel.searchText = "Miami"
        viewModel.searchText = "Miami"
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(repository.callCount, 1)
    }
}
