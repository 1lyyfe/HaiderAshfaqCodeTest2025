//
//  FavouritesStoreSmokeTests.swift
//  HeadlinesTests
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import XCTest
@testable import Headlines

@MainActor
final class FavouritesStoreSmokeTests: XCTestCase {
    func test_toggle_addsAndRemoves() {
        let store = FavouritesStore()
   
        // Warning: this writes to UserDefaults; acceptable as a smoke test for the purpose of this task

        let a = Article(
            id: "id-1",
            date: "2025-01-01T00:00:00Z",
            apiUrl: "https://content.guardianapis.com/id-1",
            fields: .init(headline: "Title", thumbnail: nil, body: "<p>Body</p>")
        )

        // Add
        store.toggle(id: a.id)
        XCTAssertTrue(store.isFavourite(a.id))

        // Remove
        store.toggle(id: a.id)
        XCTAssertFalse(store.isFavourite(a.id))
    }
}
