//
//  FavouritesViewModelTests.swift
//  HeadlinesTests
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import XCTest
@testable import Headlines

@MainActor
final class FavouritesViewModelTests: XCTestCase {

    private func makeFavourite(
        _ id: String,
        title: String,
        date: String,
        body: String = "",
        thumb: String? = nil
    ) -> FavouriteArticle {
        FavouriteArticle(
            id: id,
            title: title,
            thumbnail: thumb,
            date: date,
            bodyPlain: body
        )
    }

    func test_visible_sortedNewestFirst_whenNoQuery() {
        // Given three items out of order
        let items: [FavouriteArticle] = [
            makeFavourite("a", title: "Old", date: "2024-01-01T09:00:00Z"),
            makeFavourite("b", title: "New", date: "2025-02-01T09:00:00Z"),
            makeFavourite("c", title: "Mid", date: "2025-01-01T09:00:00Z")
        ]
        let vm = FavouritesViewModel(items: items)

        // When
        let visible = vm.visible.map(\.id)

        // Then (descending by date)
        XCTAssertEqual(visible, ["b", "c", "a"])
    }

    func test_visible_filtersByTitle_orBody_caseInsensitive() {
        // Given
        let items: [FavouriteArticle] = [
            makeFavourite("1", title: "BBC Expands", date: "2025-01-01T00:00:00Z"),
            makeFavourite("2", title: "Fintech News", date: "2025-01-02T00:00:00Z"),
            makeFavourite("3", title: "Unrelated", date: "2025-01-03T00:00:00Z", body: "contains BBC in body")
        ]
        let vm = FavouritesViewModel(items: items)

        // When: search "monzo"
        vm.query = "BBC"
        let resultIDs = vm.visible.map(\.id)

        // Then: matches title (1) and body (3), newest first among those
        XCTAssertEqual(resultIDs, ["3", "1"])
    }

    func test_visible_emptyWhenNoMatches() {
        let items: [FavouriteArticle] = [
            makeFavourite("1", title: "Alpha", date: "2025-01-01T00:00:00Z")
        ]
        let vm = FavouritesViewModel(items: items)

        vm.query = "zzz"
        XCTAssertTrue(vm.visible.isEmpty)
    }
}
