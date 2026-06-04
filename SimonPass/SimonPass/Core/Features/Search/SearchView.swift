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
        .navigationBarHidden(true)
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                leadingSearchIcon
                TextField("Search destinations...", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                trailingSearchControl
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    /// Shows a spinner while loading, a search icon otherwise.
    @ViewBuilder
    private var leadingSearchIcon: some View {
        if case .loading = viewModel.viewState {
            ProgressView()
                .controlSize(.small)
        } else {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
        }
    }

    /// Shows a clear button when there is text, nothing otherwise.
    @ViewBuilder
    private var trailingSearchControl: some View {
        if !viewModel.searchText.isEmpty {
            Button {
                viewModel.clearSearch()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
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
            loadingView
        case .success(let places):
            placesList(places)
        case .empty:
            emptyView
        case .error(let message):
            errorView(message: message)
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

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView.search(text: viewModel.searchText)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                viewModel.retry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .opacity(place.latitude == nil ? 0.4 : 1.0)
        }
        .listStyle(.plain)
    }
}

// MARK: - Place row

/// A single row in the autocomplete results list.
private struct PlaceRow: View {

    let place: Place

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.body)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// Maps the place type to an appropriate system icon.
    private var iconName: String {
        switch place.detailedType {
        case "city": return "building.2"
        case "state": return "map"
        case "country": return "globe"
        default: return "mappin"
        }
    }

    /// Builds a readable subtitle from available location metadata.
    private var subtitle: String? {
        switch place.detailedType {
        case "city":
            if let state = place.stateCode, let country = place.countryCode {
                return "\(state), \(country)"
            }
            return place.countryCode
        default:
            return place.countryCode
        }
    }
}
