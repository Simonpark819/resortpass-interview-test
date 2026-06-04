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

    // MARK: - Init

    init(viewModel: HotelListViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await Task.detached {
                    await viewModel.fetchHotels()
                }.value
            }
            .onDisappear {
                viewModel.cancelFetch()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .success(let hotels, let currency):
            hotelList(hotels, currency: currency)
        case .empty:
            emptyView
        case .error(let message):
            errorView(message: message)
        }
    }

    // MARK: - State views

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No hotels found",
            systemImage: "bed.double",
            description: Text("There are no available hotels for this location.")
        )
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

    // MARK: - Hotel list

    private func hotelList(_ hotels: [Hotel], currency: Currency) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(hotels) { hotel in
                    HotelCard(hotel: hotel, currency: currency)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Hotel card

/// A single hotel result card showing image, name, rating, and pricing.
private struct HotelCard: View {

    let hotel: Hotel
    let currency: Currency

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hotelImage
            hotelDetails
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Image

    private var hotelImage: some View {
        AsyncImage(url: hotel.image.first?.resultsImageURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay { ProgressView() }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            @unknown default:
                EmptyView()
            }
        }
        .frame(height: 200)
        .clipped()
    }

    // MARK: - Details

    private var hotelDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(hotel.name)
                .font(.headline)
            HStack(spacing: 4) {
                ratingView
                if let reviews = hotel.reviews {
                    Text("(\(reviews))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                }
                Text("\(hotel.cityName), \(hotel.stateCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let product = hotel.products.first {
                HStack {
                    Text(product.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("From \(currency.symbol)\(Int(product.price))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(12)
    }

    // MARK: - Rating

    private var ratingView: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.yellow)
            Text(String(format: "%.1f", hotel.rating ?? 0.0))
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
