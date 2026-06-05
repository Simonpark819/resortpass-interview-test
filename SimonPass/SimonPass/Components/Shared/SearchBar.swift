//
//  SearchBar.swift
//  SimonPass
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String
    let isLoading: Bool
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: Spacing.small) {
            leadingIcon
                .frame(width: 20, height: 20)
            TextField(Strings.Search.placeholder, text: $text)
                .font(Typography.searchRowTitle)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(height: 24)
            clearButton
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

    @ViewBuilder
    private var leadingIcon: some View {
        if isLoading {
            ProgressView()
                .controlSize(.small)
                .accessibilityLabel(A11y.Common.loadingIndicator)
        } else {
            Icons.location
                .frame(width: 20, height: 20)
                .foregroundStyle(Colors.textSecondary)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var clearButton: some View {
        if !text.isEmpty {
            Button {
                onClear()
            } label: {
                Icons.clear
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Colors.textSecondary)
            }
            .accessibilityLabel(A11y.Search.clearButton)
        }
    }
}
