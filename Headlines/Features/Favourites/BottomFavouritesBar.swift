//
//  BottomFavouritesBar.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Sticky bottom action bar shown on the pager.
/// Left: toggle favourite for current article. Right: open favourites modal.
struct BottomFavouritesBar: View {
    let isFavourited: Bool
    let onToggle: () -> Void
    let onOpen: () -> Void
    
    private let pagePadding: CGFloat = 20
    @ScaledMetric private var iconPadding: CGFloat = 6
    @ScaledMetric private var barVPad: CGFloat = 12

    var body: some View {
        HStack {
            Button(action: {
                onToggle()
            }) {
                Image(systemName: isFavourited ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                    .padding(.vertical, iconPadding)
                    .padding(.horizontal, iconPadding)
            }
            .accessibilityLabel("Favourite Button for this article, is set to ...")
            .accessibilityValue(isFavourited ? "On" : "Off")
            .accessibilityHint("Toggles favourite for the current article")

            Spacer()

            Button("Favourites", action: onOpen)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.yellow)
                .accessibilityHint("Opens your favourites list")
        }
        .padding(.horizontal, pagePadding)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .top)
    }
}

#Preview {
    BottomFavouritesBar(isFavourited: true, onToggle: {}, onOpen: {})
}
