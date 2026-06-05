//
//  ErrorStateView.swift
//  SimonPass
//

import SwiftUI

/// A reusable error state view with a retry action.
/// Used on both the search and hotel list screens.
struct ErrorStateView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(Colors.textSecondary)
                .accessibilityHidden(true)

            Text(Strings.Common.errorTitle)
                .font(Typography.hotelCardTitle)
                .foregroundStyle(Colors.textPrimary)

            Text(message)
                .font(Typography.hotelCardSubtitle)
                .foregroundStyle(Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button(Strings.Common.retryButton, action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding(Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
