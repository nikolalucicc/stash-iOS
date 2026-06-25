//
//  MainTabView.swift
//  stash
//
//  Root tab bar shown after onboarding: Vault, Goals, Monthly, Account.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        return TabView(selection: $router.selectedTab) {
            NavigationStack {
                VaultView()
            }
            .tabItem { Label("tab.vault", systemImage: "creditcard.fill") }
            .tag(AppTab.vault)

            NavigationStack {
                WishlistView()
            }
            .tabItem { Label("tab.goals", systemImage: "star.fill") }
            .tag(AppTab.goals)

            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("tab.monthly", systemImage: "calendar") }
            .tag(AppTab.monthly)

            NavigationStack {
                PlaceholderTab(titleKey: "tab.account", systemImage: "person.fill")
            }
            .tabItem { Label("tab.account", systemImage: "person.fill") }
            .tag(AppTab.account)
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
        .environment(AppRouter())
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
