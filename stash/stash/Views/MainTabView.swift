//
//  MainTabView.swift
//  stash
//
//  Root tab bar shown after onboarding: Vault, Goals, Monthly, Account.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PlaceholderTab(titleKey: "tab.vault", systemImage: "creditcard.fill")
            }
            .tabItem { Label("tab.vault", systemImage: "creditcard.fill") }

            NavigationStack {
                WishlistView()
            }
            .tabItem { Label("tab.goals", systemImage: "star.fill") }

            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("tab.monthly", systemImage: "calendar") }

            NavigationStack {
                PlaceholderTab(titleKey: "tab.account", systemImage: "person.fill")
            }
            .tabItem { Label("tab.account", systemImage: "person.fill") }
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
