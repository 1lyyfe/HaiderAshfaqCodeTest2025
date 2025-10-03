//
//  FavouriteArticle.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Lightweight snapshot of an article persisted as a favourite.
/// Keeps only the fields required for the favourites list/search.
struct FavouriteArticle: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let thumbnail: String?
    let date: String
    let bodyPlain: String

    var thumbnailURL: URL? { thumbnail.flatMap(URL.init(string:)) }
    var publishedDate: Date? { ISO8601DateFormatter().date(from: date) }
}

extension FavouriteArticle {
    /// Creates a favourite snapshot from a full `Article`.
    init(from a: Article) {
        self.id = a.id
        self.title = a.title
        self.thumbnail = a.fields.thumbnail
        self.date = a.date
        self.bodyPlain = a.plainBody
    }
}

#if DEBUG
extension FavouriteArticle {
    static let mockItems: [FavouriteArticle] = [
        FavouriteArticle(
            id: "tech/2025/jan/01/sample-1",
            title: "Fintech Startup Raises $50M to Disrupt Banking",
            thumbnail: "https://media.guim.co.uk/example/500.jpg",
            date: "2025-01-01T09:00:00Z",
            bodyPlain: "This is a mock article body for preview purposes."
        ),
        FavouriteArticle(
            id: "business/2025/feb/15/sample-2",
            title: "Monzo Expands to Investment Accounts",
            thumbnail: "https://media.guim.co.uk/example/600.jpg",
            date: "2025-02-15T14:30:00Z",
            bodyPlain: "Monzo announces a new investment platform aimed at retail customers."
        ),
        FavouriteArticle(
            id: "world/2025/mar/20/sample-3",
            title: "Global Markets Rally After Rate Cuts",
            thumbnail: nil,
            date: "2025-03-20T08:15:00Z",
            bodyPlain: "Markets around the world saw strong gains today."
        )
    ]
}
#endif
