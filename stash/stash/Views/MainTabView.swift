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

    @State private var selection: Tab = .monthly

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
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
