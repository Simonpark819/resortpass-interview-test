//
//  EmptyStateView.swift
//  SimonPass
//

import SwiftUI

/// A reusable empty state view with an icon, title, and optional description.
/// Used in place of ContentUnavailableView to support iOS 16+.
struct EmptyStateView: View {

    let systemImage: String
    let title: String
    var description: String? = nil

    var body: some View {
        VStack(spacing: Spacing.spacing16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Colors.textSecondary)
                .accessibilityHidden(true)
            Text(title)
                .font(Typography.hotelCardTitle)
                .foregroundStyle(Colors.textPrimary)
            if let description {
                Text(description)
                    .font(Typography.hotelCardSubtitle)
                    .foregroundStyle(Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.spacing24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
