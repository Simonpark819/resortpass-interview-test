//
//  SearchView.swift
//  SimonPass
//

import SwiftUI

/// The entry screen of the app. Presents a search bar and renders
/// autocomplete place suggestions as the user types.
/// All navigation is delegated to the coordinator — the view
/// only knows that a place was selected.
struct SearchView: View {

    // MARK: - Dependencies

    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    private let onPlaceSelected: (Place, Double, Double) -> Void

    // MARK: - Init

    init(
        viewModel: SearchViewModel,
        onPlaceSelected: @escaping (Place, Double, Double) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onPlaceSelected = onPlaceSelected
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            contentView
        }
        .padding(.horizontal, Spacing.spacing8)
        .navigationBarHidden(true)
        .onTapGesture {
            isSearchFocused = false
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        SearchBar(
            text: $viewModel.searchText,
            isLoading: viewModel.viewState == .loading,
            onClear: viewModel.clearSearch,
            isFocused: $isSearchFocused
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle:
            idleView
        case .loading:
            LoadingView()
        case .success(let places):
            placesList(places)
        case .empty:
            emptyView
        case .error(let message):
            ErrorStateView(message: message, onRetry: viewModel.retry)
        }
    }

    // MARK: - State views

    private var idleView: some View {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: Strings.Search.idleTitle,
            description: Strings.Search.idleDescription
        )
    }

    private var emptyView: some View {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: Strings.Search.emptyTitle(for: viewModel.searchText),
            description: Strings.Search.emptyDescription
        )
    }

    // MARK: - Places list

    private func placesList(_ places: [Place]) -> some View {
        List(places, id: \.self) { place in
            Button {
                guard let latitude = place.latitude,
                      let longitude = place.longitude else { return }
                onPlaceSelected(place, latitude, longitude)
            } label: {
                PlaceRow(place: place)
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: 0,
                leading: Spacing.spacing24,
                bottom: 0,
                trailing: Spacing.spacing16
            ))
            .opacity(place.hasValidCoordinates ? 1.0 : 0.4)
            .disabled(!place.hasValidCoordinates)
            .accessibilityLabel(place.name)
            .accessibilityHint(place.hasValidCoordinates ? A11y.Search.placeRowHint : A11y.Search.unavailablePlaceHint)
        }
        .listStyle(.plain)
    }
}

// MARK: - Place row

/// A single row in the autocomplete results list.
private struct PlaceRow: View {

    let place: Place

    var body: some View {
        HStack(spacing: Spacing.spacing8) {
            placeIcon
                .frame(width: 24, height: 24)
                .foregroundStyle(Colors.textSecondary)
            Text(place.name)
                .font(Typography.searchRowTitle)
                .foregroundStyle(Colors.textPrimary)
            Spacer()
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var placeIcon: some View {
        switch place.detailedType {
        case "hotel":
            Icons.hotel
        default:
            Icons.location
        }
    }
}
