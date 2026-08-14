//
//  WishlistView.swift
//  stash
//
//  Goals tab — the wishlist of savings goals with an empty state.
//

import SwiftUI
import SwiftData

struct WishlistView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.sortOrder) private var goals: [SavingsGoal]
    @Query private var profiles: [UserProfile]
    @State private var vm = WishlistVM()
    @State private var showAddGoal = false

    /// Goals are funded from the stash, so that's what there is to share out.
    private var availableToShare: Double { profiles.first?.stashBalance ?? 0 }
    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }

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
        VaultSummary(goals: goals, available: availableToShare)
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
                Text(verbatim: "/ \(summary.totalTarget.serbianFormatted) \(currencyCode)")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(Opacity.surface))
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
                .fill(Color.white.opacity(Opacity.fill))
                .frame(height: 0.5)
            availableRow
            distributeRow
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(Opacity.fill))
        .cornerRadius(Radius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(Color.appPrimary.opacity(Opacity.tintBorder), lineWidth: Line.hairline)
        )
    }

    private var availableRow: some View {
        HStack(spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("goals.available_label")
                    .font(.labelSmStyle)
                    .foregroundColor(.onSurfaceVariant)
                Text(verbatim: "\(availableToShare.serbianFormatted) \(currencyCode)")
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurface)
            }
            Spacer()
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.system(size: IconSize.md))
                .foregroundColor(.appPrimary)
        }
    }

    /// Pays out the budget for the month, or says it's already done.
    @ViewBuilder
    private var distributeRow: some View {
        if vm.isDistributed(profiles.first) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: IconSize.smd))
                Text("goals.distributed_done")
                    .font(.noteStyle)
            }
            .foregroundColor(.appPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Size.controlMd)
        } else {
            Button {
                Task { await vm.distribute(to: orderedGoals, in: modelContext) }
            } label: {
                Text("goals.distribute_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.controlMd)
                    .background(Color.accent)
                    .cornerRadius(Radius.lg)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!vm.canDistribute(profiles.first, goals: orderedGoals))
            .opacity(vm.canDistribute(profiles.first, goals: orderedGoals) ? 1 : Opacity.muted)
        }
    }

    /// Goals in the order the budget is handed out (highest priority first).
    private var orderedGoals: [SavingsGoal] { goals.sortedByPriority }

    /// Each goal paired with its share, zipped in one pass so the two can never
    /// go out of step (indexing a parallel array crashes while a goal is deleted).
    private var fundedGoals: [(goal: SavingsGoal, monthly: Double)] {
        let ordered = orderedGoals
        return zip(ordered, vm.allocations(for: ordered, available: availableToShare))
            .map { (goal: $0, monthly: $1) }
    }

    private var goalsList: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(fundedGoals, id: \.goal.persistentModelID) { funded in
                NavigationLink(value: funded.goal) {
                    GoalCard(goal: funded.goal, currencyCode: currencyCode, monthlyAmount: funded.monthly)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var addButton: some View {
        Button { showAddGoal = true } label: {
            Image(systemName: "plus")
                .font(.system(size: IconSize.xxl, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accent)
                .cornerRadius(18)
                .shadow(color: Color.accent.opacity(Opacity.shadow), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(Spacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(Opacity.border))
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
