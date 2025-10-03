//
//  ArticleViewModelTests.swift
//  HeadlinesTests
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import XCTest
@testable import Headlines

/**
 These cover:
 
 Happy path → .loaded, cache saved, banner nil
 Network fail with cache → .loaded from cache + banner shown
 Network fail w/o cache → .failed + empty list
 */

@MainActor
final class ArticleViewModelTests: XCTestCase {
    
    // MARK: - Fakes
    
    final class FakeCache: ArticlesCacheing {
        var saved: [Article]? = nil
        var toLoad: CachedArticles? = nil
        func save(_ articles: [Article]) { saved = articles }
        func load() -> CachedArticles? { toLoad }
    }
    
    // MARK: - Helpers
    
    private func makeArticle(_ i: Int) -> Article {
        Article(
            id: "id-\(i)",
            date: "2025-01-0\(i + 1)T09:00:00Z",
            apiUrl: "https://content.guardianapis.com/id-\(i)",
            fields: .init(
                headline: "Headline \(i)",
                thumbnail: nil,
                body: "<p>Body \(i)</p>"
            )
        )
    }
    
    // MARK: - Tests
    
    func test_load_success_setsLoaded_andSavesCache() async {
        let articles = [makeArticle(0), makeArticle(1)]
        let cache = FakeCache()
        
        let vm = ArticleViewModel(
            fetch: { articles },
            cache: cache
        )
        
        await vm.loadArticles()
        
        XCTAssertEqual(vm.articles.count, 2)
        
        if case .loaded = vm.state {
            /* ok */ } else { XCTFail("state not loaded")
            }
        
        XCTAssertEqual(cache.saved?.count, 2)
        XCTAssertNil(vm.offlineMessaging)
        XCTAssertEqual(vm.selectedIndex, 0)
    }
    
    func test_load_failure_usesCache_andSetsBanner() async {
        let cached = [makeArticle(0)]
        let cache = FakeCache()
        cache.toLoad = CachedArticles(fetchedAt: Date().addingTimeInterval(-3600), articles: cached)
        
        let vm = ArticleViewModel(
            fetch: { throw URLError(.notConnectedToInternet) },
            cache: cache
        )
        
        await vm.loadArticles()
        
        XCTAssertEqual(vm.articles.map(\.id), cached.map(\.id))
        if case .loaded = vm.state {
            /* ok */
        }
        else { XCTFail("state not loaded from cache")
        }
        XCTAssertNotNil(vm.offlineMessaging)
    }
    
    func test_load_failure_noCache_setsFailed() async {
        let cache = FakeCache() // toLoad = nil
        
        let vm = ArticleViewModel(
            fetch: { throw URLError(.notConnectedToInternet) },
            cache: cache
        )
        
        await vm.loadArticles()
        
        if case .failed(let msg) = vm.state {
            XCTAssertTrue(msg.contains("Couldn’t load"))
        } else {
            XCTFail("state should be failed when no cache")
        }
        XCTAssertTrue(vm.articles.isEmpty)
        XCTAssertNil(vm.offlineMessaging)
    }
}
