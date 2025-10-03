//
//  ArticlePageView.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Full article page used inside the pager.
struct ArticlePageView: View {
    let article: Article
        
    @ScaledMetric private var headerHeight: CGFloat = 260
    @ScaledMetric private var pagePadding: CGFloat = 20
    
    /// Adaptive, Dynamic-Type-friendly font for the headline.
    private var titleFont: Font {
        switch article.title.count {
        case 0..<60:   return .largeTitle
        case 60..<90:  return .title
        default:       return .title2
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            ScrollView {
                VStack(spacing: 0) {
                    header(width: width)
                    content(width: width)
                }
                .frame(width: width)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Sections
    
    private func header(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(titleFont)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                
                if let d = article.publishedDate {
                    Text(Self.df.string(from: d))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, pagePadding)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(width: width, alignment: .leading)
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)
            
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: article.thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                    case .success(let img): 
                        img.resizable().scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(Image(systemName: "photo"))
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: width, height: headerHeight)
                .clipped()
                .accessibilityHidden(true)
                
                SwipeHint()
                    .padding(8)
                    .accessibilityHidden(true)
            }
        }
    }
    
    private func content(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(article.plainBody)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, pagePadding)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .frame(width: width, alignment: .topLeading)
        .background(Color(.systemBackground))  
    }
    
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()
}

// Swipe hint view.
private struct SwipeHint: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("Swipe Next")
                .font(.footnote.weight(.semibold))
            Image(systemName: "arrow.right")
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .opacity(0.9)
    }
}

#Preview {
    ArticlePageView(article: .mockArticles.first!)
}

