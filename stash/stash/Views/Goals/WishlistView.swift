//
//  WishlistView.swift
//  stash
//
//  Goals tab — the wishlist of savings goals with an empty state.
//

import SwiftUI
import SwiftData

struct WishlistView: View {

    @Query(sort: \SavingsGoal.sortOrder) private var goals: [SavingsGoal]
    @Query private var profiles: [UserProfile]
    @State private var showAddGoal = false

    private var monthlyBudget: Double { profiles.first?.goalsMonthlyBudget ?? 0 }

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header
                    if goals.isEmpty {
                        emptyState
                    } else {
                        budgetCard
                        goalsList
                    }
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, 96)
            }
            .overlay(addButton, alignment: .bottomTrailing)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddGoal) {
            AddGoalView(nextSortOrder: goals.count)
                .presentationBackground(Color.surfaceContainerLow)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("goals.title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
            Text("goals.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("goals.budget_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: monthlyBudget.serbianFormatted)
                    .font(.displayLgStyle)
                    .foregroundColor(.onSurface)
                Text("common.rsd")
                    .font(.displayValStyle)
                    .foregroundColor(.appPrimary)
            }
            HStack(spacing: Spacing.xs) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12))
                    .foregroundColor(.appPrimary)
                Text(verbatim: String(format: String(localized: "goals.active_count"), goals.count))
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var goalsList: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(goals) { goal in
                GoalCard(goal: goal)
            }
        }
    }

    private var addButton: some View {
        Button { showAddGoal = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accent)
                .cornerRadius(18)
                .shadow(color: Color.accent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(Spacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 88, height: 88)
                Image(systemName: "star")
                    .font(.system(size: 36))
                    .foregroundColor(.appPrimary)
            }
            Text("goals.empty_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            Text("goals.empty_subtitle")
                .font(.bodyStyle)
                .foregroundColor(.onSurfaceVariant)
                .multilineTextAlignment(.center)
            Button { showAddGoal = true } label: {
                Text("goals.empty_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
            }
            .buttonStyle(.plain)
            .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
    }
}

#Preview {
    NavigationStack {
        WishlistView()
    }
    .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
