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
                PlaceholderTab(titleKey: "tab.account", systemImage: "person.fill")
            }
            .tabItem { Label("tab.account", systemImage: "person.fill") }
            .tag(Tab.account)
        }
        .tint(.accent)
    }
}

/// Simple "coming soon" content for tabs not built yet.
struct PlaceholderTab: View {
    let titleKey: LocalizedStringKey
    let systemImage: String

    var body: some View {
        StashTheme {
            VStack(spacing: Spacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundColor(.appPrimary.opacity(0.6))
                Text(titleKey)
                    .font(.screenTitleStyle)
                    .foregroundColor(.onSurface)
                Text("common.coming_soon")
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
