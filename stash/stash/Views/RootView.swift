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
    @State private var router = AppRouter()

    private var onboardingCompleted: Bool {
        profiles.first?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                MainTabView()
                    .environment(router)
            } else {
                NavigationStack { OnboardingFirstStepView() }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
