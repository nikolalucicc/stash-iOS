//
//  GoalDetailView.swift
//  stash
//
//  A single goal: progress, monthly plan + ETA, deposits, edit and delete.
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {

    let goal: SavingsGoal

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \SavingsGoal.sortOrder) private var goals: [SavingsGoal]
    @State private var vm = GoalDetailVM()
    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        header
                        progressCard
                        monthlyCard
                        actions
                        deleteButton
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEdit) {
            AddGoalView(editing: goal)
                .presentationBackground(Color.surfaceContainerLow)
        }
        .sheet(isPresented: Bindable(vm).showDepositSheet) {
            DepositSheet(vm: vm, goal: goal, currencyCode: currencyCode,
                         availableInStash: profiles.first?.stashBalance ?? 0)
                .presentationDetents([.height(280)])
                .presentationBackground(Color.surfaceContainerLow)
        }
        .alert("goals.delete_confirm_title", isPresented: $showDeleteConfirm) {
            Button("common.cancel_btn", role: .cancel) {}
            Button("goals.delete_cta", role: .destructive) {
                // Leave the screen first: rendering this view against a deleted
                // model is what makes SwiftData blow up.
                dismiss()
                Task { await vm.delete(goal, in: modelContext) }
            }
        } message: {
            Text("goals.delete_confirm_message")
        }
    }

    private var topBar: some View {
        ZStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: IconSize.lg, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { showEdit = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.vertical, Spacing.md)
    }

    private var header: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.white.opacity(Opacity.surface))
                    .frame(width: 56, height: 56)
                Text(verbatim: goal.emoji)
                    .font(.system(size: 28))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: goal.name)
                    .font(.screenTitleStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: goal.priority.label)
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: goal.savedAmount.serbianFormatted)
                    .font(.displayLgStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: "/ \(goal.targetAmount.serbianFormatted) \(currencyCode)")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(Opacity.surface))
                    Capsule().fill(Color.appPrimary)
                        .frame(width: proxy.size.width * goal.progress)
                }
            }
            .frame(height: 8)
            HStack {
                Text(verbatim: "\(Int((goal.progress * 100).rounded()))%")
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
                Spacer()
                Text(verbatim: remainingText)
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(Opacity.fill))
        .cornerRadius(Radius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(Color.appPrimary.opacity(Opacity.tintBorder), lineWidth: Line.hairline)
        )
    }

    private var monthlyCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("goals.planned_monthly")
                    .font(.labelCapsStyle)
                    .tracking(0.6)
                    .foregroundColor(.onSurfaceVariant)
                Text(verbatim: "\(plannedMonthly.serbianFormatted) \(currencyCode)")
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
            }
            Spacer()
            Text(verbatim: etaText)
                .font(.noteStyle)
                .foregroundColor(.appPrimary)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(Opacity.surfaceSubtle))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(Opacity.fill), lineWidth: Line.hairline)
        )
    }

    private var actions: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                Task { await vm.deposit(plannedMonthly, to: goal, in: modelContext) }
            } label: {
                Text(verbatim: depositMonthText)
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.field)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(plannedMonthly <= 0)
            .opacity(plannedMonthly > 0 ? 1 : Opacity.muted)

            Button { vm.showDepositSheet = true } label: {
                Text("goals.deposit_custom_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.field)
                    .background(Color.white.opacity(Opacity.surface))
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            Text("goals.delete_cta")
                .font(.secondaryStyle)
                .foregroundColor(.appError)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.plain)
    }

    /// What this goal plans to take each month — its deadline pace, the amount
    /// the user picked, or its share of the stash as a fallback.
    private var plannedMonthly: Double {
        let need = goal.monthlyNeed()
        return goal.deadline != nil || goal.customMonthly > 0 ? need : allocatedMonthly
    }

    /// This goal's share of what's currently in the stash.
    private var allocatedMonthly: Double {
        let ordered = goals.sortedByPriority
        let amounts = GoalAllocator.allocate(
            budget: profiles.first?.stashBalance ?? 0,
            goals: ordered
        )
        guard let index = ordered.firstIndex(where: { $0 === goal }) else { return 0 }
        return amounts[index]
    }

    /// e.g. "12.000 EUR left" — the currency follows the user's selection.
    private var remainingText: String {
        let amount = "\(goal.remaining.serbianFormatted) \(currencyCode)"
        return String(format: String(localized: "goals.remaining"), amount)
    }

    /// e.g. "I saved this month (+5.000 EUR)".
    private var depositMonthText: String {
        let amount = "\(plannedMonthly.serbianFormatted) \(currencyCode)"
        return String(format: String(localized: "goals.deposit_month_cta"), amount)
    }

    private var etaText: String {
        if goal.remaining <= 0 {
            return String(localized: "goals.eta_done")
        }
        guard let months = GoalAllocator.monthsToGoal(remaining: goal.remaining, monthly: plannedMonthly) else {
            return String(localized: "goals.eta_set_monthly")
        }
        return String(format: String(localized: "goals.eta"), months)
    }
}

// MARK: - Deposit sheet

private struct DepositSheet: View {
    @Bindable var vm: GoalDetailVM
    let goal: SavingsGoal
    let currencyCode: String
    let availableInStash: Double
    @Environment(\.modelContext) private var modelContext

    private var canDeposit: Bool { vm.depositText.parsedSerbianNumber > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("goals.deposit_title")
                    .font(.sectionHeaderStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: String(format: String(localized: "goals.deposit_available"),
                                      "\(availableInStash.serbianFormatted) \(currencyCode)"))
                    .font(.noteStyle)
                    .foregroundColor(availableInStash > 0 ? .onSurfaceVariant : .appError)
            }
            HStack {
                TextField("0", text: $vm.depositText)
                    .font(.inputValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                    .thousandsGrouped($vm.depositText)
                Text(verbatim: currencyCode)
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            .frame(height: Size.field)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surface))
            .cornerRadius(Radius.xl)

            Button {
                Task { await vm.applyCustomDeposit(to: goal, in: modelContext) }
            } label: {
                Text("goals.deposit_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.field)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canDeposit)
            .opacity(canDeposit ? 1 : Opacity.muted)
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }
}
