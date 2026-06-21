//
//  GoalsBudgetVM.swift
//  stash
//
//  Backs the goals-budget sheet: edits the monthly budget and previews how
//  it splits across goals by priority.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class GoalsBudgetVM {

    var budgetText: String = ""

    var budget: Double { budgetText.parsedSerbianNumber }

    func load(from context: ModelContext) async {
        guard let profile = UserProfile.existing(in: context) else { return }
        budgetText = profile.goalsMonthlyBudget.serbianFormatted
    }

    func save(to context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = budget
        try? context.save()
    }

    /// Monthly amount allocated to each goal, in the same order as `goals`.
    func allocations(for goals: [SavingsGoal]) -> [Double] {
        GoalAllocator.allocate(
            budget: budget,
            items: goals.map { .init(weight: $0.priority.weight, desired: $0.desiredMonthly) }
        )
    }

    /// Budget left after every goal is funded (0 when over budget).
    func unallocated(for goals: [SavingsGoal]) -> Double {
        max(0, budget - allocations(for: goals).reduce(0, +))
    }
}
