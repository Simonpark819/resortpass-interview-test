//
//  RatingView.swift
//  SimonPass
//

import SwiftUI

/// Displays a 5-star rating row with filled and unfilled stars
/// based on the hotel's numeric rating value.
/// Format: ★★★★☆ 4.7 (542) | Miami, FL
struct RatingView: View {

    let rating: Double
    let reviews: Int?
    let city: String
    let stateCode: String
    private let maxStars = 5

    var body: some View {
        HStack(spacing: 4) {
            starsRow
            Text(String(format: "%.1f", rating))
                .font(Typography.hotelCardSubtitle)
                .foregroundStyle(Colors.textPrimary)
            if let reviews {
                Text("(\(reviews))")
                    .font(Typography.hotelCardSubtitle)
                    .foregroundStyle(Colors.textPrimary)
            }
            Text("|")
                .foregroundStyle(Colors.textSecondary)
                .font(Typography.hotelCardSubtitle)
                .accessibilityHidden(true)
            Text("\(city), \(stateCode)")
                .font(Typography.hotelCardSubtitle)
                .foregroundStyle(Colors.textPrimary)
        }
    }

    // MARK: - Stars

    private var starsRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<maxStars, id: \.self) { index in
                starImage(for: index)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .frame(width: 16, height: 16)
            }
        }
        .accessibilityHidden(true)
    }

    private func starImage(for index: Int) -> Image {
        let threshold = Double(index) + 0.5
        if rating >= Double(index + 1) {
            return Icons.starFilled
        } else if rating >= threshold {
            return Icons.starHalfFilled
        } else {
            return Icons.starEmpty
        }
    }
}
