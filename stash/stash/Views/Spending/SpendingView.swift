//
//  SpendingView.swift
//  stash
//
//  Spending tab: log day-to-day spends into categories; they're deducted from
//  this month's free money (salary − saving − fixed expenses).
//

import SwiftUI
import SwiftData

struct SpendingView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \SpendingEntry.createdAt, order: .reverse) private var entries: [SpendingEntry]
    @State private var addingCategory: SpendingCategory?

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header
                    if let profile {
                        freeToSpendCard(for: profile)
                        categoriesSection
                        if !monthEntries.isEmpty { recentSection }
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $addingCategory) { category in
            AddSpendingSheet(category: category, currencyCode: currencyCode)
                .presentationDetents([.height(340)])
                .presentationBackground(Color.surfaceContainerLow)
        }
    }
}

// MARK: - Derived state

private extension SpendingView {

    var profile: UserProfile? { profiles.first }
    var currencyCode: String { (profile?.currency ?? .rsd).code }

    var monthEntries: [SpendingEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }
    }

    var spentThisMonth: Double { monthEntries.reduce(0) { $0 + $1.amount } }
    var freeMoney: Double { profile?.freeMoney ?? 0 }
    var remaining: Double { freeMoney - spentThisMonth }
    var spentRatio: Double { freeMoney > 0 ? min(spentThisMonth / freeMoney, 1) : 0 }

    func spent(for category: SpendingCategory) -> Double {
        monthEntries.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }

    func delete(_ entry: SpendingEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

// MARK: - Sections

private extension SpendingView {

    var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("spending.title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
            Text("spending.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    func freeToSpendCard(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("spending.free_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: remaining.serbianFormatted)
                    .font(.heroNumStyle)
                    .foregroundColor(remaining < 0 ? .appError : .onSurface)
                Text(verbatim: currencyCode)
                    .font(.displayValStyle)
                    .foregroundColor(.appPrimary)
            }
            ProgressView(value: spentRatio)
                .tint(remaining < 0 ? .appError : .accent)
            Text(verbatim: String(format: String(localized: "spending.of_free"),
                                  "\(freeMoney.serbianFormatted) \(currencyCode)"))
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
        )
    }

    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("spending.categories_header")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            ForEach(SpendingCategory.allCases) { category in
                Button { addingCategory = category } label: {
                    categoryRow(category)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func categoryRow(_ category: SpendingCategory) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 36, height: 36)
                Image(systemName: category.icon)
                    .font(.system(size: 15))
                    .foregroundColor(.appPrimary)
            }
            Text(verbatim: category.label)
                .font(.navTitleStyle)
                .foregroundColor(.onSurface)
            Spacer()
            Text(verbatim: "\(spent(for: category).serbianFormatted) \(currencyCode)")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.appPrimary)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
    }

    var recentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("spending.recent_header")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            ForEach(monthEntries) { entry in
                entryRow(entry)
            }
        }
    }

    func entryRow(_ entry: SpendingEntry) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: entry.category.icon)
                .font(.system(size: 14))
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 24)
            Text(verbatim: entry.note.isEmpty ? entry.category.label : entry.note)
                .font(.secondaryStyle)
                .foregroundColor(.onSurface)
            Spacer()
            Text(verbatim: "-\(entry.amount.serbianFormatted) \(currencyCode)")
                .font(.secondaryStyle)
                .foregroundColor(.onSurface)
            Button { delete(entry) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.onSurfaceVariant)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.lg)
    }

    var emptyState: some View {
        Text("spending.empty")
            .font(.secondaryStyle)
            .foregroundColor(.onSurfaceVariant)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.xl)
    }
}

#Preview {
    NavigationStack { SpendingView() }
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self, SpendingEntry.self],
            inMemory: true
        )
}
