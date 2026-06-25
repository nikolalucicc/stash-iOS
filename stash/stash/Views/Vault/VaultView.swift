//
//  VaultView.swift
//  stash
//
//  Vault tab — aggregate savings overview across all goals.
//

import SwiftUI
import SwiftData

struct VaultView: View {

    @Environment(AppRouter.self) private var router
    @Query private var goals: [SavingsGoal]
    @Query private var profiles: [UserProfile]

    private var summary: VaultSummary {
        VaultSummary(goals: goals, budget: profiles.first?.goalsMonthlyBudget ?? 0)
    }

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header
                    if goals.isEmpty {
                        emptyState
                    } else {
                        heroCard
                        statsRow
                        breakdown
                    }
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: SavingsGoal.self) { goal in
            GoalDetailView(goal: goal)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("vault.title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
            Text("vault.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("vault.total_saved_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: summary.totalSaved.serbianFormatted)
                    .font(.heroNumStyle)
                    .foregroundColor(.onSurface)
                Text("common.rsd")
                    .font(.displayValStyle)
                    .foregroundColor(.appPrimary)
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
                Text(verbatim: "\(summary.totalTarget.serbianFormatted) \(String(localized: "common.rsd"))")
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var statsRow: some View {
        HStack(spacing: Spacing.gutter) {
            Button { router.selectedTab = .goals } label: {
                statTile(
                    icon: "star.fill",
                    value: "\(summary.goalCount)",
                    label: String(localized: "vault.active_goals")
                )
            }
            .buttonStyle(.plain)
            statTile(
                icon: "calendar",
                value: summary.monthlyAllocated.serbianFormatted,
                label: String(localized: "vault.saved_monthly")
            )
        }
    }

    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            Text(verbatim: value)
                .font(.displayValStyle)
                .foregroundColor(.onSurface)
            Text(verbatim: label)
                .font(.labelSmStyle)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.white.opacity(0.04))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: Spacing.gutter) {
            HStack {
                Text("vault.breakdown_header")
                    .font(.sectionHeaderStyle)
                    .foregroundColor(.onSurface)
                Spacer()
                if summary.completedCount > 0 {
                    Text(verbatim: String(format: String(localized: "vault.completed"), summary.completedCount))
                        .font(.noteStyle)
                        .foregroundColor(.appPrimary)
                }
            }
            ForEach(goals.sortedByPriority) { goal in
                NavigationLink(value: goal) {
                    goalRow(goal)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func goalRow(_ goal: SavingsGoal) -> some View {
        HStack(spacing: Spacing.md) {
            Text(verbatim: goal.emoji)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(verbatim: goal.name)
                        .font(.bodyStyle)
                        .foregroundColor(.onSurface)
                    Spacer()
                    Text(verbatim: "\(Int((goal.progress * 100).rounded()))%")
                        .font(.labelCapsStyle)
                        .foregroundColor(.appPrimary)
                }
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.05))
                        Capsule().fill(Color.appPrimary)
                            .frame(width: proxy.size.width * goal.progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 88, height: 88)
                Image(systemName: "banknote")
                    .font(.system(size: 34))
                    .foregroundColor(.appPrimary)
            }
            Text("vault.empty_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            Text("vault.empty_subtitle")
                .font(.bodyStyle)
                .foregroundColor(.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
    }
}

#Preview {
    NavigationStack {
        VaultView()
    }
    .environment(AppRouter())
    .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
