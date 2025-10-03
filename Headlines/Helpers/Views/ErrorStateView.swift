//
//  EmptyStateView.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Lightweight empty state used when iOS 17's `ContentUnavailableView` is unavailable.
struct ErrorStateView: View {
    let title: String
    let message: String?
    let systemImage: String
    let retry: (() -> Void)?

    init(_ title: String, message: String? = nil, systemImage: String = "x.circle.fill", retry: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.retry = retry
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(title).font(.headline).multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let retry {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 6)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    ErrorStateView("Test")
}
