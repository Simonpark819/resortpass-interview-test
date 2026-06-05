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

    @State private var viewModel: SearchViewModel
    private let onPlaceSelected: (Place, Double, Double) -> Void

    // MARK: - Init

    init(
        viewModel: SearchViewModel,
        onPlaceSelected: @escaping (Place, Double, Double) -> Void
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        self.onPlaceSelected = onPlaceSelected
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            contentView
        }
        .padding(.horizontal, Spacing.small)
        .navigationBarHidden(true)
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: Spacing.small) {
            leadingSearchIcon
                .frame(width: 20, height: 20)
            TextField("Search destinations...", text: $viewModel.searchText)
                .font(Typography.searchRowTitle)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(height: 24)
            trailingSearchControl
        }
        .padding(.horizontal, Spacing.small)
        .frame(height: 44)
        .background(Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: Radius.minimal))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.minimal)
                .stroke(Colors.borderSecondary, lineWidth: 1)
        }
        .padding(.horizontal, Spacing.large)
    }

    /// Shows a spinner while loading, a search icon otherwise.
    @ViewBuilder
    private var leadingSearchIcon: some View {
        if case .loading = viewModel.viewState {
            ProgressView()
                .controlSize(.small)
        } else {
            Icons.location
                .frame(width: 20, height: 20)
                .foregroundStyle(Colors.textSecondary)
        }
    }

    /// Shows a clear button when there is text, nothing otherwise.
    @ViewBuilder
    private var trailingSearchControl: some View {
        if !viewModel.searchText.isEmpty {
            Button {
                viewModel.clearSearch()
            } label: {
                Icons.clear
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Colors.textSecondary)
            }
        }
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
        ContentUnavailableView(
            "Search destinations",
            systemImage: "magnifyingglass",
            description: Text("Type a city, state, or hotel name to get started.")
        )
    }

    private var emptyView: some View {
        ContentUnavailableView.search(text: viewModel.searchText)
    }

    // MARK: - Places list

    private func placesList(_ places: [Place]) -> some View {
        List(places, id: \.self) { place in
            PlaceRow(place: place)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard let latitude = place.latitude,
                          let longitude = place.longitude else { return }
                    onPlaceSelected(place, latitude, longitude)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: 0,
                    leading: Spacing.large,
                    bottom: 0,
                    trailing: Spacing.large
                ))
                .opacity(place.hasValidCoordinates ? 1.0 : 0.4 )
                .disabled(!place.hasValidCoordinates)
        }
        .listStyle(.plain)
    }
}

// MARK: - Place row

/// A single row in the autocomplete results list.
private struct PlaceRow: View {

    let place: Place

    var body: some View {
        HStack(spacing: Spacing.small) {
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
