//
//  HotelListView.swift
//  SimonPass
//

import SwiftUI

/// Displays a list of hotels for the place selected on the search screen.
/// Fetches on appear and supports retry on error.
struct HotelListView: View {

    // MARK: - Dependencies

    @State private var viewModel: HotelListViewModel
    @Environment(AppCoordinator.self) private var coordinator
    let placeName: String

    // MARK: - Init

    init(viewModel: HotelListViewModel, placeName: String) {
        _viewModel = .init(wrappedValue: viewModel)
        self.placeName = placeName
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
            contentView
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchHotels()
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text(placeName)
                .font(Typography.screenTitle)
                .foregroundStyle(Colors.textPrimary)

            HStack {
                Button {
                    coordinator.pop()
                } label: {
                    Icons.back
                        .renderingMode(.original)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(A11y.HotelList.backButton)
                Spacer()
            }
            .padding(.horizontal, Spacing.large)
        }
        .frame(height: 44)
        .background(Color(.systemBackground))
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            LoadingView()
        case .success(let hotels, let currency):
            hotelList(hotels, currency: currency)
        case .empty:
            emptyView
        case .error(let message):
            ErrorStateView(message: message, onRetry: viewModel.retry)
        }
    }

    // MARK: - State views

    private var emptyView: some View {
        ContentUnavailableView(
            Strings.HotelList.emptyTitle,
            systemImage: "bed.double",
            description: Text(Strings.HotelList.emptyDescription)
        )
    }

    // MARK: - Hotel list

    private func hotelList(_ hotels: [Hotel], currency: Currency) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.small) {
                ForEach(hotels) { hotel in
                    HotelCard(hotel: hotel, currency: currency)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.large)
            .padding(.bottom, Spacing.medium)
        }
    }
}
