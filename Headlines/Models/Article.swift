import Foundation

fileprivate let APIKey = "09658731-cb6d-4a84-9e3c-5f030389de4e"

/// Root payload from the Guardian API.
/// - Note: Only the fields required by the exercise are modeled.
struct ArticlesResponse: Codable {
    let response: ArticlesMeta
}

/// Response metadata + results array.
struct ArticlesMeta: Codable {
    let currentPage: Int
    let pageSize: Int
    let results: [Article]
}


/// A single article as returned by the API endpoint.
struct Article: Codable {
    let id: String
    let date: String
    let apiUrl: String
    let fields: ArticleField
    
    enum CodingKeys: String, CodingKey {
        case date = "webPublicationDate"
        case id = "id"
        case apiUrl = "apiUrl"
        case fields = "fields"
    }
    
    /// Nested content fields requested via `show-fields=...`.
    struct ArticleField: Codable {
        let headline: String
        let thumbnail: String?
        let body: String
    }
}


extension Article {
    var title: String { fields.headline }
    
    var thumbnailURL: URL? { fields.thumbnail.flatMap(URL.init(string:)) }

    var plainBody: String { fields.body.strippingTags }

    var publishedDate: Date? { ISO8601DateFormatter().date(from: date) }

    var webURL: URL? { apiUrl.url }
}

extension Article {
    static let mockArticles: [Article] = [
        Article(
            id: "tech/2025/jan/01/sample-article-1",
            date: "2025-01-01T09:00:00Z",
            apiUrl: "https://content.guardianapis.com/tech/2025/jan/01/sample-article-1",
            fields: Article.ArticleField(
                headline: "Fintech Startup Raises $50M to Disrupt Banking",
                thumbnail: "https://example/500.jpg",
                body: "<p>This is a mock article body for preview purposes. It contains <strong>HTML</strong> tags and sample content to test rendering.</p>"
            )
        ),
        Article(
            id: "business/2025/feb/15/sample-article-2",
            date: "2025-02-15T14:30:00Z",
            apiUrl: "https://content.guardianapis.com/business/2025/feb/15/sample-article-2",
            fields: Article.ArticleField(
                headline: "Monzo Expands Services to Include Investment Accounts",
                thumbnail: "https://media.guim.co.uk/example/600.jpg",
                body: "<p>Monzo announces a new investment platform aimed at retail customers. This marks a significant expansion into new financial services.</p>"
            )
        ),
        Article(
            id: "world/2025/mar/20/sample-article-3",
            date: "2025-03-20T08:15:00Z",
            apiUrl: "https://content.guardianapis.com/world/2025/mar/20/sample-article-3",
            fields: Article.ArticleField(
                headline: "Global Markets Rally After Interest Rate Cuts",
                thumbnail: nil,
                body: "<p>Markets around the world saw strong gains today after central banks announced coordinated interest rate cuts.</p>"
            )
        )
    ]
}
