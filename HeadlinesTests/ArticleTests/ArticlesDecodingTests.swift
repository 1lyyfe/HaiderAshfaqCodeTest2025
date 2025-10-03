//
//  ArticlesDecodingTests.swift
//  HeadlinesTests
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import XCTest
@testable import Headlines

final class ArticlesDecodingTests: XCTestCase {
    func test_validJSON_decodes() throws {
        let json = """
        {"response":{"currentPage":1,"pageSize":1,"results":[
          {"id":"tech/2025/jan/01/sample-1","webPublicationDate":"2025-01-01T09:00:00Z",
           "apiUrl":"https://content.guardianapis.com/tech/2025/jan/01/sample-1",
           "fields":{"headline":"Fintech Startup Raises $50M","thumbnail":null,"body":"<p>Body</p>"}}
        ]}}
        """
        let root = try JSONDecoder().decode(ArticlesResponse.self, from: Data(json.utf8))
        XCTAssertEqual(root.response.results.first?.fields.headline, "Fintech Startup Raises $50M")
    }

    func test_missingFields_throws() {
        let json = #"{"response":{"currentPage":1,"pageSize":1,"results":[{}]}}"#
        XCTAssertThrowsError(try JSONDecoder().decode(ArticlesResponse.self, from: Data(json.utf8)))
    }

    func test_strippingTags() {
        XCTAssertEqual("<p>Hello</p> <p>World</p>".strippingTags, "Hello\n\nWorld")
    }
}
