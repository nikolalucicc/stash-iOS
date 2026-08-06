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
    /// What the user actually sets aside each month, for the over-budget warning.
    private(set) var monthlySaving: Double = 0

    var budget: Double { budgetText.parsedSerbianNumber }

    /// `true` when the goals budget promises more than the monthly saving covers.
    var exceedsMonthlySaving: Bool { monthlySaving > 0 && budget > monthlySaving }

    func load(from context: ModelContext) async {
        guard let profile = UserProfile.existing(in: context) else { return }
        budgetText = profile.goalsMonthlyBudget.serbianFormatted
        monthlySaving = profile.monthlySaving
    }

    func save(to context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = budget
        try? context.save()
    }

    /// Monthly amount allocated to each goal, in the same order as `goals`.
    func allocations(for goals: [SavingsGoal]) -> [Double] {
        GoalAllocator.allocate(budget: budget, goals: goals)
    }

    /// Budget left after every goal is funded (0 when over budget).
    func unallocated(for goals: [SavingsGoal]) -> Double {
        max(0, budget - allocations(for: goals).reduce(0, +))
    }
}
