//
//  ArticleService.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import Foundation

/// Errors emitted by `ArticleService`.

enum ArticleServiceError: Error {
    case badURL, badResponse
}

/// Thin wrapper around the Guardian API.
/// - Important: Set your API key before calling `fetchArticles()`.
struct ArticleService {
    static let apiKey = "6888441c-c563-4c61-bc86-6949b39f1297"
    
#if DEBUG
    static var forceNetworkError = false
#endif
    
    static var session: URLSession = .shared
    
    /// Fetches latest articles with required `fields`.
      ///
      /// - Returns: Decoded array of `Article`.
      /// - Throws: `ArticleServiceError.badURL`, `ArticleServiceError.badResponse`, or `DecodingError`.
    static func fetchArticles() async throws -> [Article] {
        
#if DEBUG
        if forceNetworkError { throw ArticleServiceError.badResponse }
#endif
        
        let urlString =
        "https://content.guardianapis.com/search?q=fintech&order-by=newest&show-fields=headline,thumbnail,body&api-key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw ArticleServiceError.badURL }
        
        let (data, resp) = try await session.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw ArticleServiceError.badResponse }
        
        let decoder = JSONDecoder()
        let root = try decoder.decode(ArticlesResponse.self, from: data)
        return root.response.results
    }
}
