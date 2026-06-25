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
    @State private var showBudget = false

    private var monthlyBudget: Double { profiles.first?.goalsMonthlyBudget ?? 0 }

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header
                    if goals.isEmpty {
                        emptyState
                    } else {
                        summaryCard
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
        .navigationDestination(for: SavingsGoal.self) { goal in
            GoalDetailView(goal: goal)
        }
        .sheet(isPresented: $showAddGoal) {
            AddGoalView(nextSortOrder: goals.count)
                .presentationBackground(Color.surfaceContainerLow)
        }
        .sheet(isPresented: $showBudget) {
            GoalsBudgetView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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

    private var summary: VaultSummary {
        VaultSummary(goals: goals, budget: monthlyBudget)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("goals.summary_saved_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: summary.totalSaved.serbianFormatted)
                    .font(.displayLgStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: "/ \(summary.totalTarget.serbianFormatted) \(String(localized: "common.rsd"))")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.05))
                    Capsule().fill(Color.appPrimary)
                        .frame(width: proxy.size.width * summary.progress)
                }
            }
            .frame(height: 8)
            HStack {
                Text(verbatim: "\(Int((summary.progress * 100).rounded()))%")
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
                Spacer()
                if summary.completedCount > 0 {
                    Text(verbatim: String(format: String(localized: "goals.completed"), summary.completedCount))
                        .font(.noteStyle)
                        .foregroundColor(.appPrimary)
                }
            }
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
            budgetRow
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var budgetRow: some View {
        Button { showBudget = true } label: {
            HStack(spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("goals.summary_budget_label")
                        .font(.labelSmStyle)
                        .foregroundColor(.onSurfaceVariant)
                    Text(verbatim: "\(monthlyBudget.serbianFormatted) \(String(localized: "common.rsd"))")
                        .font(.secondaryStyle)
                        .foregroundColor(.onSurface)
                }
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var goalsList: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(goals.sortedByPriority) { goal in
                NavigationLink(value: goal) {
                    GoalCard(goal: goal)
                }
                .buttonStyle(.plain)
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
