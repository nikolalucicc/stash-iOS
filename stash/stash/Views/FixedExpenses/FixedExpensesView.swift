//
//  FixedExpensesView.swift
//  stash
//
//  Manage the user's fixed monthly expenses: add, edit and delete. Reached by
//  tapping the fixed-expenses card on the dashboard.
//

import SwiftUI
import SwiftData

struct FixedExpensesView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = FixedExpensesVM()
    @State private var showSheet = false
    @State private var pendingDelete: FixedExpenseEntity?

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        totalCard
                        if expenses.isEmpty { emptyState } else { expensesList }
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
                addButton
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSheet) {
            FixedExpenseSheet(vm: vm, currencyCode: currencyCode)
                .presentationDetents([.height(360)])
                .presentationBackground(Color.surfaceContainerLow)
        }
        .alert("expenses.delete_title", isPresented: deleteAlertBinding) {
            Button("common.cancel_btn", role: .cancel) { pendingDelete = nil }
            Button("expenses.delete_cta", role: .destructive) { confirmDelete() }
        } message: {
            Text("expenses.delete_message")
        }
    }
}

// MARK: - Derived state

private extension FixedExpensesView {

    var profile: UserProfile? { profiles.first }
    var currencyCode: String { (profile?.currency ?? .rsd).code }

    var expenses: [FixedExpenseEntity] {
        (profile?.expenses ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var total: Double { profile?.fixedExpensesTotal ?? 0 }

    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )
    }

    func presentAdd() {
        vm.startAdd()
        showSheet = true
    }

    func presentEdit(_ expense: FixedExpenseEntity) {
        vm.startEdit(expense)
        showSheet = true
    }

    func confirmDelete() {
        guard let expense = pendingDelete else { return }
        pendingDelete = nil
        Task { await vm.delete(expense, from: modelContext) }
    }
}

// MARK: - Sections

private extension FixedExpensesView {

    var topBar: some View {
        ZStack {
            Text("expenses.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: IconSize.lg, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.vertical, Spacing.sm)
    }

    var totalCard: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step3.total_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: total.serbianFormatted)
                    .font(.heroNumStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: currencyCode)
                    .font(.displayValStyle)
                    .foregroundColor(.appPrimary)
            }
            Text("expenses.subtitle")
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
            if profile?.isOverCommitted == true {
                overCommittedNote
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(Opacity.fill))
        .cornerRadius(Radius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(Color.appPrimary.opacity(Opacity.tintBorder), lineWidth: Line.hairline)
        )
    }

    /// Saving plus these expenses promise more than the salary covers.
    @ViewBuilder
    var overCommittedNote: some View {
        if let profile {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: IconSize.sm))
                Text(verbatim: String(format: String(localized: "expenses.over_committed"),
                                      "\(abs(profile.uncommittedMoney).serbianFormatted) \(currencyCode)"))
                    .font(.noteStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.appError)
            .padding(.top, Spacing.xs)
        }
    }

    var expensesList: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(expenses) { expense in
                Button { presentEdit(expense) } label: { expenseRow(expense) }
                    .buttonStyle(.plain)
            }
        }
    }

    func expenseRow(_ expense: FixedExpenseEntity) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(Opacity.surface))
                    .frame(width: Size.iconBadge, height: Size.iconBadge)
                Image(systemName: expense.icon)
                    .font(.system(size: IconSize.md))
                    .foregroundColor(.appPrimary)
            }
            Text(verbatim: expense.name)
                .font(.navTitleStyle)
                .foregroundColor(.onSurface)
            Spacer()
            Text(verbatim: "\(expense.amount.serbianFormatted) \(currencyCode)")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
            Button { pendingDelete = expense } label: {
                Image(systemName: "trash")
                    .font(.system(size: IconSize.smd))
                    .foregroundColor(.appError)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(Opacity.surfaceSubtle))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(Opacity.fill), lineWidth: Line.hairline)
        )
        .contentShape(Rectangle())
    }

    var emptyState: some View {
        Text("expenses.empty")
            .font(.secondaryStyle)
            .foregroundColor(.onSurfaceVariant)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.xl)
    }

    var addButton: some View {
        Button { presentAdd() } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus")
                    .font(.system(size: IconSize.smd, weight: .semibold))
                Text("onboarding.step3.add_expense_btn")
                    .font(.navTitleStyle)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Size.field)
            .background(Color.accent)
            .cornerRadius(Radius.xl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    NavigationStack { FixedExpensesView() }
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
                  SpendingEntry.self, SpendingCategory.self],
            inMemory: true
        )
}
