//
//  ArticlesPagerView.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Top-level screen showing swipeable articles and a sticky favourites bar.
/// Handles loading/error/empty states, pull-to-refresh, and offline banner.
struct ArticlesPagerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @StateObject private var vm: ArticleViewModel
    @StateObject private var favs = FavouritesStore()
    @State private var showFavourites = false
    
    init(vm: ArticleViewModel? = nil) {
        _vm = StateObject(wrappedValue: vm ?? ArticleViewModel())
    }
    
    private var currentArticle: Article? {
        guard case .loaded = vm.state,
              vm.articles.indices.contains(vm.selectedIndex) else { return nil }
        return vm.articles[vm.selectedIndex]
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle, .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading headlines…")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .failed(let msg):
                    ErrorStateView(
                        "Couldn’t load headlines.",
                        message: msg,
                        retry: { Task { await vm.loadArticles() } }
                    )
                    
                case .loaded:
                    if vm.articles.isEmpty {
                        ErrorStateView(
                            "No articles",
                            systemImage: "newspaper",
                            retry: { Task { await vm.loadArticles() } }
                        )
                    } else {
                        VStack(spacing: 0) {
                            if let msg = vm.offlineMessaging {
                                OfflineBanner(text: msg).transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            TabView(selection: $vm.selectedIndex) {
                                ForEach(Array(vm.articles.enumerated()), id: \.offset) { idx, a in
                                    ArticlePageView(article: a)
                                        .tag(idx)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if case .idle = vm.state {
                await vm.loadArticles()
            }
        }
        .refreshable {
            await vm.loadArticles()
        }
        .safeAreaInset(edge: .bottom) {
            if let a = currentArticle {
                BottomFavouritesBar(
                    isFavourited: favs.isFavourite(a.id),
                    onToggle: { favs.toggle(id: a.id) },
                    onOpen: { showFavourites = true }
                )
            }
        }
//        .overlay(alignment: .top) {
//            if let msg = vm.offlineMessaging {
//                OfflineBanner(text: msg).transition(.move(edge: .top).combined(with: .opacity))
//            }
//        }
        // Modal favourites list
        .sheet(isPresented: $showFavourites) {
            let favArticles: [Article] = vm.articles.filter { favs.isFavourite($0.id) }
            let items: [FavouriteArticle] = favArticles.map(FavouriteArticle.init(from:))
            
            FavouritesListView(
                vm: FavouritesViewModel(items: items),
                onSelect: { fav in
                   
                    if let idx = vm.articles.firstIndex(where: { $0.id == fav.id }) {
                        vm.selectedIndex = idx
                    }
                    
                    showFavourites = false
                })
        }
    }
}
#Preview("Pager — Mock Data") {
    ArticlesPagerView(vm: .mock())
}
