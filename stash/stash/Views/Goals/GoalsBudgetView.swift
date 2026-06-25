//
//  GoalsBudgetView.swift
//  stash
//
//  Sheet for setting the monthly goals budget with a live allocation preview.
//

import SwiftUI
import SwiftData

struct GoalsBudgetView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.sortOrder) private var goals: [SavingsGoal]
    @Query private var profiles: [UserProfile]

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }
    @State private var vm = GoalsBudgetVM()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    intro
                    budgetField
                    infoBox
                    allocationPreview
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
            footer
        }
        .background(Color.surfaceContainerLow)
        .task { await vm.load(from: modelContext) }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("goals.budget_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            Text("goals.budget_intro")
                .font(.bodyStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var budgetField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("goals.budget_input_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
                .padding(.leading, 4)
            HStack {
                TextField("0", text: bindable.budgetText)
                    .font(.displayValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                Text(verbatim: currencyCode)
                    .font(.sectionHeaderStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.appPrimary.opacity(0.4), lineWidth: 0.5)
            )
        }
    }

    private var infoBox: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundColor(.appPrimary)
            Text("goals.budget_info")
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(Radius.xl)
    }

    @ViewBuilder
    private var allocationPreview: some View {
        VStack(alignment: .leading, spacing: Spacing.gutter) {
            Text("goals.allocation_header")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            if goals.isEmpty {
                Text("goals.budget_empty")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            } else {
                let sorted = goals.sortedByPriority
                let amounts = vm.allocations(for: sorted)
                ForEach(Array(zip(sorted, amounts)), id: \.0.id) { goal, amount in
                    allocationRow(goal: goal, amount: amount)
                }
                let leftover = vm.unallocated(for: sorted)
                if leftover > 0 {
                    unallocatedRow(leftover)
                }
            }
        }
    }

    private func allocationRow(goal: SavingsGoal, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(verbatim: "\(goal.emoji)  \(goal.name)")
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
                Spacer()
                Text(verbatim: "\(amount.serbianFormatted) \(currencyCode)")
                    .font(.navTitleStyle)
                    .foregroundColor(.appPrimary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.05))
                    Capsule().fill(Color.appPrimary)
                        .frame(width: proxy.size.width * fraction(amount))
                }
            }
            .frame(height: 6)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
    }

    private func unallocatedRow(_ amount: Double) -> some View {
        HStack {
            Text("goals.unallocated")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
            Spacer()
            Text(verbatim: "\(amount.serbianFormatted) \(currencyCode)")
                .font(.navTitleStyle)
                .foregroundColor(.onSurfaceVariant)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.02))
        .cornerRadius(Radius.xl)
    }

    private var footer: some View {
        Button {
            Task { await vm.save(to: modelContext); dismiss() }
        } label: {
            Text("goals.budget_save_cta")
                .font(.navTitleStyle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xl)
    }

    private func fraction(_ amount: Double) -> Double {
        guard vm.budget > 0 else { return 0 }
        return min(amount / vm.budget, 1)
    }
}

#Preview {
    GoalsBudgetView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
