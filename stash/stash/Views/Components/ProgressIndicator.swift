//
//  ProgressIndicator.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import SwiftUI

struct ProgressIndicator: View {

    let currentStep: Int
    var suffix: String = ""

    private var stepLabel: String {
        suffix.isEmpty
            ? String(format: String(localized: "common.progress_step"), currentStep)
            : String(format: String(localized: "common.progress_step_suffix"), currentStep, suffix)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                ForEach(1...4, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color.accent : Color.white.opacity(0.1))
                        .frame(height: 4)
                }
            }
            Text(verbatim: stepLabel)
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            ProgressIndicator(currentStep: 1)
            ProgressIndicator(currentStep: 2)
            ProgressIndicator(currentStep: 3)
            ProgressIndicator(currentStep: 4)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
