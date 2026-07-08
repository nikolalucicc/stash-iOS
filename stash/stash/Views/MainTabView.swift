//
//  MainTabView.swift
//  stash
//
//  Root tab bar shown after onboarding: Goals, Monthly, Spending, Account.
//  Uses a paged TabView (interactive, finger-following swipe) with a custom
//  bottom tab bar on top.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    private enum Tab: CaseIterable {
        case goals, monthly, spending, account

        var titleKey: LocalizedStringKey {
            switch self {
            case .goals:    return "tab.goals"
            case .monthly:  return "tab.monthly"
            case .spending: return "tab.spending"
            case .account:  return "tab.account"
            }
        }

        var icon: String {
            switch self {
            case .goals:    return "star.fill"
            case .monthly:  return "calendar"
            case .spending: return "creditcard.fill"
            case .account:  return "person.fill"
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var selection: Tab = .monthly
    @State private var showWalkthrough = false

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { WishlistView() }.tag(Tab.goals)
            NavigationStack { DashboardView() }.tag(Tab.monthly)
            NavigationStack { SpendingView() }.tag(Tab.spending)
            NavigationStack { AccountView() }.tag(Tab.account)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .safeAreaInset(edge: .bottom, spacing: 0) { tabBar }
        .tint(.accent)
        .onAppear { showWalkthrough = profiles.first?.walkthroughCompleted == false }
        .onChange(of: profiles.first?.walkthroughCompleted) { _, completed in
            if completed == false { showWalkthrough = true }
        }
        .fullScreenCover(isPresented: $showWalkthrough, onDismiss: markWalkthroughSeen) {
            WalkthroughView { showWalkthrough = false }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self, content: tabButton)
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.xs)
        .background(Capsule(style: .continuous).fill(Color.surfaceContainer))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.35), radius: 12, y: 4)
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.bottom, Spacing.sm)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))
                Text(tab.titleKey)
                    .font(.labelSmStyle)
            }
            .foregroundColor(selection == tab ? .accent : .onSurfaceVariant)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func markWalkthroughSeen() {
        let profile = UserProfile.current(in: modelContext)
        profile.walkthroughCompleted = true
        try? modelContext.save()
    }
}

#Preview {
    MainTabView()
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self, SpendingEntry.self],
            inMemory: true
        )
}
