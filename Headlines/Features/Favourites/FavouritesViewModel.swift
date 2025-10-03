//
//  FavouritesViewModel.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Read-only view model for the favourites modal.
/// Accepts a snapshot of favourites and exposes filtered/sorted results.
@MainActor
final class FavouritesViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var items: [FavouriteArticle]

    init(items: [FavouriteArticle]) {
        self.items = items
    }

    /// Items filtered by `query` and sorted newest-first.
    var visible: [FavouriteArticle] {
        var out = items
        if !query.isEmpty {
            out = out.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                || $0.bodyPlain.localizedCaseInsensitiveContains(query)
            }
        }
        out.sort { ($0.publishedDate ?? .distantPast) > ($1.publishedDate ?? .distantPast) }
        return out
    }
}
