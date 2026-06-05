//
//  HotelCard.swift
//  SimonPass
//

import SwiftUI

/// A single hotel result card showing image, name, rating,
/// location, and pricing information.
/// Consumed by HotelListView.
struct HotelCard: View {

    let hotel: Hotel
    let currency: Currency

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            hotelImage
            infoBlock
        }
        // No background, no shadow, no card border —
        // hotels render as a continuous list per the design spec
    }

    // MARK: - Image

    private var hotelImage: some View {
        ZStack(alignment: .topTrailing) {
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
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 228, maxHeight: 228)
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(Colors.textSecondary)
                                .accessibilityHidden(true)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 228)
            .clipShape(RoundedRectangle(cornerRadius: Radius.minimal))
            .accessibilityLabel(A11y.HotelList.hotelImage(hotelName: hotel.name))

            favoriteButton
                .padding(.top, Spacing.spacing8)
                .padding(.trailing, Spacing.spacing8)
        }
    }

    private var favoriteButton: some View {
        Button {
            // Favorite functionality — future implementation
        } label: {
            Icons.favorite
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel(A11y.HotelList.favoriteButton(hotelName: hotel.name))
    }

    // MARK: - Info block

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text(hotel.name)
                .font(Typography.hotelCardTitle)
                .foregroundStyle(Colors.textPrimary)

            RatingView(
                rating: hotel.rating ?? 0.0,
                reviews: hotel.reviews,
                city: hotel.cityName,
                stateCode: hotel.stateCode
            )

            if let product = hotel.products.first {
                HStack {
                    Text(product.name)
                        .font(Typography.hotelCardSubtitle)
                        .foregroundStyle(Colors.textSecondary)
                    Spacer()
                    Text(Strings.HotelList.fromPrice(symbol: currency.symbol, amount: Int(product.price.rounded())))
                        .font(Typography.hotelCardSubtitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Colors.textPrimary)
                }
            }
        }
        .padding(.vertical, Spacing.spacing12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(A11y.HotelList.hotelCard(
            name: hotel.name,
            rating: hotel.rating ?? 0.0,
            reviews: hotel.reviews,
            city: hotel.cityName,
            stateCode: hotel.stateCode,
            productName: hotel.products.first?.name,
            price: hotel.products.first.map {
                Strings.HotelList.fromPrice(symbol: currency.symbol, amount: Int($0.price.rounded()))
            }
        ))
    }
}
