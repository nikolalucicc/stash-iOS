//
//  RootView.swift
//  stash
//
//  Decides whether to show onboarding or the main app, reacting to whether
//  the user has finished setup (persisted in `UserProfile`).
//

import SwiftUI
import SwiftData

struct RootView: View {

    @Query private var profiles: [UserProfile]

    private var onboardingCompleted: Bool {
        profiles.first?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                MainTabView()
            } else {
                NavigationStack { OnboardingFourthStepView() }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
