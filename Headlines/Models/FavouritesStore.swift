//
//  FavouritesStore.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Simple persistence for favourites using `UserDefaults`.
/// - Note: For the exercise, this keeps the code minimal and shippable.
@MainActor
final class FavouritesStore: ObservableObject {
    @Published private(set) var ids: Set<String> = []
    private let key = "favouriteArticleIDs"
    
    init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            ids = Set(saved)
        }
    }
    
    /// Returns `true` if the given article ID is favourited.
    func isFavourite(_ id: String) -> Bool {
        ids.contains(id)
    }
    
    /// Adds or removes the given article from favourites and persists.
    func toggle(id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        
        UserDefaults.standard.set(Array(ids), forKey: key)
        objectWillChange.send()
    }
}
