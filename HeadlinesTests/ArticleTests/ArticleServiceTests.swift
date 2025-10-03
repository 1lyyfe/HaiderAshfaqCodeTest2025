//
//  ArticleServiceTests.swift
//  HeadlinesTests
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import XCTest
@testable import Headlines

final class URLProtocolMock: URLProtocol {
    static var responseCode: Int = 200
    static var responseData: Data = Data()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        let http = HTTPURLResponse(url: request.url!, statusCode: Self.responseCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

final class ArticleServiceTests: XCTestCase {
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
        ArticleService.session = session   // inject mock session
    }

    override func tearDown() {
        ArticleService.session = .shared
        session = nil
        super.tearDown()
    }

    func test_fetchArticles_success() async throws {
        URLProtocolMock.responseCode = 200
        URLProtocolMock.responseData = sampleJSON(count: 2)
        let articles = try await ArticleService.fetchArticles()
        XCTAssertEqual(articles.count, 2)
        XCTAssertEqual(articles.first?.fields.headline, "Fintech A")
    }

    func test_fetchArticles_non200_throws() async {
        URLProtocolMock.responseCode = 500
        URLProtocolMock.responseData = Data()
        await XCTAssertThrowsErrorAsync({ try await ArticleService.fetchArticles() })
    }

    func test_fetchArticles_badJSON_throws() async {
        URLProtocolMock.responseCode = 200
        URLProtocolMock.responseData = Data("{}".utf8)
        await XCTAssertThrowsErrorAsync({ try await ArticleService.fetchArticles() })
    }

    private func sampleJSON(count: Int) -> Data {
        
        let items = (0..<count).map { i in
            """
            {"id":"id-\(i)","webPublicationDate":"2025-01-0\(i+1)T09:00:00Z",
             "apiUrl":"https://content.guardianapis.com/id-\(i)",
             "fields":{"headline":"Fintech \(i==0 ? "A" : "B")","thumbnail":null,"body":"<p>Body \(i)</p>"}}
            """
        }.joined(separator: ",")
        
        return Data(#"{"response":{"currentPage":1,"pageSize":\#(count),"results":[\#(items)]}}"#.utf8)
    }
}


func XCTAssertThrowsErrorAsync<T>(
    _ expression: @escaping () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error but succeeded. " + message(), file: file, line: line)
    } catch {
        // success: it threw
    }
}
