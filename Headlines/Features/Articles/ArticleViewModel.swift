//
//  ArticleViewModel.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// View model driving the headlines pager: loading, error/empty states, offline cache fallback, and selection index.
@MainActor
final class ArticleViewModel: ObservableObject {
    enum LoadState {
        case idle, loading, loaded, failed(String)
    }

    @Published var articles: [Article] = []
    @Published var state: LoadState = .idle
    @Published var selectedIndex: Int = 0
    @Published var offlineMessaging: String? = nil
    
    private let fetch: () async throws -> [Article]
    private let cache: ArticlesCacheing
    
    /// - Parameters:
     ///   - fetch: Async fetch closure (defaults to `ArticleService.fetchArticles`).
     ///   - cache: Cache adapter (defaults to on-disk `ArticlesCache`).
    init(
        fetch: @escaping () async throws -> [Article] = ArticleService.fetchArticles,
        cache: ArticlesCacheing = DefaultArticlesCache()
    ) {
        self.fetch = fetch
        self.cache = cache
    }

    /// Loads headlines. On failure, attempts to load the last-good cache.
    func loadArticles() async {
        state = .loading
        offlineMessaging = nil
        do {
            let fetched = try await fetch()
            articles = fetched
            state = .loaded
            selectedIndex = 0
            cache.save(fetched)
        } catch {
            if let cached = cache.load() {
                articles = cached.articles
                state = .loaded
                selectedIndex = 0
        
                let df = RelativeDateTimeFormatter()
                df.unitsStyle = .short
        
                offlineMessaging = "Offline — showing saved headlines (\(df.localizedString(for: cached.fetchedAt, relativeTo: Date())))"
            } else {
                state = .failed("Couldn’t load headlines.")
            }
        }
    }
}


#if DEBUG
extension ArticleViewModel {
    static func mock() -> ArticleViewModel {
        let vm = ArticleViewModel()
        vm.articles = Article.mockArticles
        vm.state = .loaded
        vm.selectedIndex = 0
        return vm
    }
}
#endif
