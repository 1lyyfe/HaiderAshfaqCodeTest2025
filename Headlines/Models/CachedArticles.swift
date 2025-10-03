//
//  CachedArticles.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import Foundation

struct CachedArticles: Codable {
    let fetchedAt: Date
    let articles: [Article]
}

/// On-disk cache of the last successful articles fetch.
/// Stored in `Library/Caches` and used as an offline fallback.
enum ArticlesCache {
    private static var url: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("articles-cache.json")
    }

    /// Saves the given articles as the "last known good" payload.
    static func save(_ articles: [Article]) {
        let payload = CachedArticles(fetchedAt: Date(), articles: articles)
        do {
            let data = try JSONEncoder().encode(payload)
            try data.write(to: url, options: .atomic)
        } catch {
            // Non-fatal in MVP; silently ignore
        }
    }

    /// Loads the last saved payload, if present.
    static func load() -> CachedArticles? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(CachedArticles.self, from: data)
    }
}


protocol ArticlesCacheing {
    func save(_ articles: [Article])
    func load() -> CachedArticles?
}

struct DefaultArticlesCache: ArticlesCacheing {
    func save(_ articles: [Article]) { ArticlesCache.save(articles) }
    func load() -> CachedArticles? { ArticlesCache.load() }
}
