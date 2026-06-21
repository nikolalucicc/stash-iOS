//
//  RootView.swift
//  stash
//
//  Decides whether to show onboarding or the dashboard, based on whether
//  the user already finished setup (persisted in `UserProfile`).
//

import SwiftUI
import SwiftData

struct RootView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var hasCompletedOnboarding: Bool?

    var body: some View {
        Group {
            if let hasCompletedOnboarding {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    NavigationStack { OnboardingFirstStepView() }
                }
            } else {
                Color.appBackground.ignoresSafeArea()
            }
        }
        .onAppear { resolveStartDestination() }
    }

    private func resolveStartDestination() {
        guard hasCompletedOnboarding == nil else { return }
        hasCompletedOnboarding = UserProfile.existing(in: modelContext)?.onboardingCompleted ?? false
    }
}

#Preview {
    RootView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
