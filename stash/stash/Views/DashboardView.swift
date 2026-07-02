//
//  DashboardView.swift
//  stash
//
//  Created by Nikola on 7. 6. 2026..
//

import SwiftUI
import SwiftData
import Foundation

struct DashboardView: View {

    @Query private var profiles: [UserProfile]
    @State private var showStash = false

    private var profile: UserProfile? { profiles.first }
    private var currencyCode: String { (profile?.currency ?? .rsd).code }

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.gutter) {
                    headerBar

                    if let profile {
                        stashCard(for: profile)
                        PaydayReminderCard(profile: profile, currencyCode: currencyCode)
                        savingHeroCard(for: profile)
                        currentMonthCard(for: profile)
                        statsGrid(for: profile)
                        if !profile.expenses.isEmpty {
                            expensesSection(for: profile)
                        }
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showStash) {
            if let profile {
                StashDepositSheet(currentBalance: profile.stashBalance, currencyCode: currencyCode)
                    .presentationDetents([.height(300)])
                    .presentationBackground(Color.surfaceContainerLow)
            }
        }
    }

    // MARK: - Stash Card

    private func stashCard(for profile: UserProfile) -> some View {
        Button { showStash = true } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("stash.total_label")
                        .font(.labelCapsStyle)
                        .tracking(0.6)
                        .foregroundColor(.onSurfaceVariant)
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.appPrimary)
                }
                HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                    Text(verbatim: profile.stashBalance.serbianFormatted)
                        .font(.heroNumStyle)
                        .foregroundColor(.onSurface)
                    Text(verbatim: currencyCode)
                        .font(.displayValStyle)
                        .foregroundColor(.appPrimary)
                }
                Text("stash.hint")
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .background(Color.appPrimary.opacity(0.08))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Text(verbatim: monthYearLabel)
                .font(.labelSmStyle)
                .foregroundColor(.white.opacity(0.4))
                .textCase(.uppercase)
                .tracking(1)
            Spacer()
        }
        .padding(.bottom, Spacing.xs)
    }

    private var monthYearLabel: String {
        Date.now.formatted(.dateTime.month(.wide).year())
    }

    private var emptyState: some View {
        Text("dashboard.empty_state")
            .font(.bodyStyle)
            .foregroundColor(.onSurfaceVariant)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
            .background(Color.white.opacity(0.03))
            .cornerRadius(Radius.xl)
    }

    // MARK: - Hero Saving Card

    private func savingHeroCard(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("dashboard.this_month_saving_label")
                    .font(.labelCapsStyle)
                    .tracking(0.6)
                    .foregroundColor(.white.opacity(0.4))
                HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                    Text(verbatim: profile.monthlySaving.serbianFormatted)
                        .font(.displayLgStyle)
                        .foregroundColor(.white)
                    Text(verbatim: profile.currency.code)
                        .font(.sectionHeaderStyle)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            VStack(spacing: Spacing.xs) {
                HStack {
                    Text("dashboard.share_of_salary")
                        .font(.noteStyle)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(verbatim: "\(Int(savingShare(for: profile).rounded()))%")
                        .font(.noteStyle)
                        .foregroundColor(.white)
                }
                ProgressTrack(progress: savingShare(for: profile) / 100, tint: .accent)
            }
        }
        .padding(Spacing.lg)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private func savingShare(for profile: UserProfile) -> Double {
        guard profile.monthlySalary > 0 else { return 0 }
        return min(profile.monthlySaving / profile.monthlySalary * 100, 100)
    }

    // MARK: - Current Month Card

    private func currentMonthCard(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            currentMonthHeader
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(verbatim: profile.monthlySalary.serbianFormatted)
                    .font(.screenTitleStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: profile.currency.code)
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            SegmentedBreakdownBar(breakdown: breakdown(for: profile))
            currentMonthStats(for: profile)
        }
        .padding(Spacing.md + 2)
        .background(Color.accent.opacity(0.1))
        .cornerRadius(Radius.xl + 4)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl + 4)
                .stroke(Color.accent.opacity(0.3), lineWidth: 0.5)
        )
    }

    private var currentMonthHeader: some View {
        HStack {
            Text("dashboard.salary_card_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text("dashboard.entered_badge")
                .font(.labelSmStyle)
                .foregroundColor(.appPrimary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 3)
                .background(Color.accent.opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.accent.opacity(0.3), lineWidth: 0.5))
        }
    }

    private func currentMonthStats(for profile: UserProfile) -> some View {
        HStack {
            statColumn(
                label: String(localized: "dashboard.savings_stat"),
                amount: profile.monthlySaving,
                tint: Color(hex: "#AFA9EC")
            )
            Spacer()
            statColumn(
                label: String(localized: "dashboard.fixed_stat"),
                amount: fixedTotal(for: profile),
                tint: .onSurfaceVariant
            )
            Spacer()
            statColumn(
                label: String(localized: "dashboard.free_stat"),
                amount: freeAmount(for: profile),
                tint: .onSurface
            )
        }
    }

    private func statColumn(label: String, amount: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: label)
                .font(.labelSmStyle)
                .foregroundColor(tint.opacity(0.8))
            Text(verbatim: amount.serbianFormatted)
                .font(.bodyStyle)
                .fontWeight(.medium)
                .foregroundColor(tint)
        }
    }
}

// MARK: - Stats & expenses

private extension DashboardView {

    func statsGrid(for profile: UserProfile) -> some View {
        HStack(spacing: Spacing.gutter) {
            statTile(
                icon: "list.bullet.rectangle",
                iconColor: Color(hex: "#5DCAA5"),
                value: "\(profile.expenses.count)",
                label: String(localized: "dashboard.expenses_label")
            )
            statTile(
                icon: "calendar",
                iconColor: .white.opacity(0.4),
                value: daysUntilPaydayLabel(for: profile),
                label: String(localized: "dashboard.days_until_payday_label")
            )
        }
    }

    private func statTile(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
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

    // MARK: - Fixed Expenses

    private func expensesSection(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("dashboard.expenses_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
                .padding(.leading, 4)

            VStack(spacing: Spacing.gutter) {
                ForEach(profile.expenses.sorted { $0.createdAt < $1.createdAt }) { expense in
                    expenseRow(expense)
                }
            }
        }
    }

    private func expenseRow(_ expense: FixedExpenseEntity) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 36, height: 36)
                Image(systemName: expense.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: expense.name)
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: expense.note)
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(verbatim: expense.amount.serbianFormatted)
                    .font(.displayValStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: currencyCode)
                    .font(.labelSmStyle)
                    .foregroundColor(.onSurface)
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

}

// MARK: - Derived values

private extension DashboardView {

    func fixedTotal(for profile: UserProfile) -> Double {
        profile.fixedExpensesTotal
    }

    func freeAmount(for profile: UserProfile) -> Double {
        profile.freeMoney
    }

    func breakdown(for profile: UserProfile) -> SalaryBreakdown {
        let salary = max(profile.monthlySalary, 0.01)
        let saving = min(profile.monthlySaving / salary, 1)
        let fixed = min(fixedTotal(for: profile) / salary, 1 - saving)
        let free = max(0, 1 - saving - fixed)
        return SalaryBreakdown(savingRatio: saving, fixedRatio: fixed, freeRatio: free)
    }

    func daysUntilPaydayLabel(for profile: UserProfile) -> String {
        String(format: String(localized: "dashboard.days_value"), daysUntilNextPayday(for: profile))
    }

    func daysUntilNextPayday(for profile: UserProfile) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let timing = profile.payPeriod

        let candidates = [0, 1].compactMap {
            payday(monthsFromNow: $0, timing: timing, calendar: calendar, today: today)
        }
        guard let upcoming = candidates.first(where: { $0 >= today }) ?? candidates.first else {
            return 0
        }
        return max(0, calendar.dateComponents([.day], from: today, to: upcoming).day ?? 0)
    }

    func payday(monthsFromNow: Int, timing: PayPeriod, calendar: Calendar, today: Date) -> Date? {
        guard let monthDate = calendar.date(byAdding: .month, value: monthsFromNow, to: today) else { return nil }
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = timing.day(in: monthDate, calendar: calendar)
        return calendar.date(from: components)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self], inMemory: true)
}
