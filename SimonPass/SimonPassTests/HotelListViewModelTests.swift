//
//  HotelListViewModelTests.swift
//  SimonPassTests
//

import XCTest
@testable import SimonPass

@MainActor
final class HotelListViewModelTests: XCTestCase {

    private var repository: MockHotelRepository!
    private var viewModel: HotelListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockHotelRepository()
        viewModel = HotelListViewModel(
            repository: repository,
            latitude: 25.7617,
            longitude: -80.1918
        )
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - fetchHotels

    func test_fetchHotels_setsLoadingStateFirst() async {
        repository.delay = true

        async let _ = viewModel.fetchHotels()

        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func test_fetchHotels_withHotels_setsSuccessState() async {
        let hotels = [Hotel.make()]
        let currency = Currency.make()
        repository.result = .success(HotelSearchResponse.make(hotels: hotels, currency: currency))

        await viewModel.fetchHotels()

        XCTAssertEqual(viewModel.viewState, .success(hotels, currency))
    }

    func test_fetchHotels_withEmptyHotels_setsEmptyState() async {
        repository.result = .success(HotelSearchResponse.make(hotels: []))

        await viewModel.fetchHotels()

        XCTAssertEqual(viewModel.viewState, .empty)
    }

    func test_fetchHotels_withError_setsErrorState() async {
        repository.result = .failure(NetworkError.invalidResponse)

        await viewModel.fetchHotels()

        if case .error = viewModel.viewState {
            // pass
        } else {
            XCTFail("Expected .error state, got \(viewModel.viewState)")
        }
    }

    func test_fetchHotels_errorMessage_matchesLocalizedDescription() async {
        repository.result = .failure(NetworkError.httpError(statusCode: 500))

        await viewModel.fetchHotels()

        XCTAssertEqual(viewModel.viewState, .error(NetworkError.httpError(statusCode: 500).localizedDescription))
    }

    // MARK: - retry

    func test_retry_afterError_refetchesAndSetsSuccessState() async throws {
        repository.result = .failure(NetworkError.invalidResponse)
        await viewModel.fetchHotels()

        let hotels = [Hotel.make()]
        repository.result = .success(HotelSearchResponse.make(hotels: hotels))

        viewModel.retry()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(viewModel.viewState, .success(hotels, Currency.make()))
    }

    func test_retry_incrementsCallCount() async throws {
        repository.result = .success(HotelSearchResponse.make(hotels: [Hotel.make()]))
        await viewModel.fetchHotels()

        viewModel.retry()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(repository.callCount, 2)
    }
}
