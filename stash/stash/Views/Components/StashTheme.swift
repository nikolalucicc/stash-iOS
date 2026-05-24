//
//  StashTheme.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import SwiftUI

struct StashTheme<Content: View>: View {

    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 83/255, green: 74/255, blue: 183/255).opacity(0.3),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .frame(height: 400)
            .offset(y: -128)
            .allowsHitTesting(false)

            content
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    StashTheme {
        Text("Hello")
            .foregroundColor(.onSurface)
    }
}
