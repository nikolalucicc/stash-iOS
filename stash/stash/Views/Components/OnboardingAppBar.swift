//
//  OnboardingAppBar.swift
//  stash
//
//  Shared app bar used across all onboarding steps.
//  Pass `onBack` to show a back arrow; omit it for the first step.
//

import SwiftUI

struct OnboardingAppBar: View {

    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            Text(verbatim: "Stash")
                .font(.screenTitleStyle)
                .fontWeight(.bold)
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)

            if let onBack {
                HStack {
                    Button { onBack() } label: {
                        Image(systemName: "arrow.left")
                            .accessibilityHidden(true)
                            .iconSize(IconSize.lg, weight: .medium)
                            .foregroundColor(.appPrimary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("a11y.back"))
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 0) {
            OnboardingAppBar()
            Divider()
            OnboardingAppBar(onBack: {})
        }
    }
    .preferredColorScheme(.dark)
}
