//
//  LoadingView.swift
//  SimonPass
//

import SwiftUI

/// A centered loading indicator used across all screens
/// during data fetch operations.
struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
