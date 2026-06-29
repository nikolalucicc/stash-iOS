//
//  MainTabView.swift
//  stash
//
//  Root tab bar shown after onboarding: Vault, Goals, Monthly, Account.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    private enum Tab: Hashable { case goals, monthly, account }

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var selection: Tab = .monthly
    @State private var showWalkthrough = false

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                WishlistView()
            }
            .tabItem { Label("tab.goals", systemImage: "star.fill") }
            .tag(Tab.goals)

            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("tab.monthly", systemImage: "calendar") }
            .tag(Tab.monthly)

            NavigationStack {
                AccountView()
            }
            .tabItem { Label("tab.account", systemImage: "person.fill") }
            .tag(Tab.account)
        }
        .tint(.accent)
        .onAppear { showWalkthrough = profiles.first?.walkthroughCompleted == false }
        .onChange(of: profiles.first?.walkthroughCompleted) { _, completed in
            if completed == false { showWalkthrough = true }
        }
        .fullScreenCover(isPresented: $showWalkthrough, onDismiss: markWalkthroughSeen) {
            WalkthroughView { showWalkthrough = false }
        }
    }

    private func markWalkthroughSeen() {
        let profile = UserProfile.current(in: modelContext)
        profile.walkthroughCompleted = true
        try? modelContext.save()
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
