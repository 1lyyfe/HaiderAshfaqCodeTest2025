//
//  OfflineBanner.swift
//  Headlines
//
//  Created by Haider Ashfaq on 12/08/2025.
//  Copyright © 2025 Example. All rights reserved.
//

import SwiftUI

/// Small capsule banner shown when rendering cached content (offline/degraded).
struct OfflineBanner: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.red)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding(.top, 8)
    }
}

#Preview {
    OfflineBanner(text: "Offline")
}
