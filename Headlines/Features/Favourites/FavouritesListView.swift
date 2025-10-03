//
//  FavouritesListView.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Modal list of favourites with search and "Done".
/// Rows show thumbnail, title, and `dd/MM/yyyy` date.
/// - Note: Selection callback is used to jump to the chosen article.
struct FavouritesListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: FavouritesViewModel
    let onSelect: ((FavouriteArticle) -> Void)?
    
    @ScaledMetric var scale: CGFloat = 1.0
    
    init(vm: FavouritesViewModel, onSelect: ((FavouriteArticle) -> Void)? = nil) {
        _vm = StateObject(wrappedValue: vm)
        self.onSelect = onSelect
    }
    
    private static let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"; return f
    }()
    
    var body: some View {
        NavigationStack {
            List(vm.visible) { a in
                HStack(spacing: 12) {
                    AsyncImage(url: a.thumbnailURL) { phase in
                        switch phase {
                        case .empty: Color.gray.opacity(0.12)
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: Color.gray.opacity(0.12).overlay(Image(systemName: "photo"))
                        @unknown default: EmptyView()
                        }
                    }
                    .frame(width: 56 * scale, height: 56 * scale)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(a.title).font(.headline).lineLimit(2)
                        Text(a.publishedDate.map(Self.df.string(from:)) ?? "")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect?(a)
                    dismiss()
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(a.title)
                .accessibilityHint("Opens this article")
            }
            .listStyle(.plain)
            .searchable(text: $vm.query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search")
            .navigationTitle(vm.visible.count != 1 ? "\(vm.visible.count) favourites" : "\(vm.visible.count) favourite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                        .tint(.yellow)
                }
            }
        }
    }
}

#Preview {
    FavouritesListView(vm: FavouritesViewModel(items: FavouriteArticle.mockItems))
}
