//
//  String+Extensions.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import Foundation

extension String {
    /// Utilities for cleaning HTML and extracting the first URL from a string.
    var strippingTags: String {
        var result = self.replacingOccurrences(of: "</p> <p>", with: "\n\n") as NSString
        var range = result.range(of: "<[^>]+>", options: .regularExpression)
        while range.location != NSNotFound {
            result = result.replacingCharacters(in: range, with: "") as NSString
            range = result.range(of: "<[^>]+>", options: .regularExpression)
        }
        return result as String
    }

    /// Returns the first detected URL in the string, if any.
    var url: URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length))
        return matches.first?.url
    }
}
