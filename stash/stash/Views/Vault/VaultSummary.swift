//
//  VaultSummary.swift
//  stash
//
//  Aggregate savings figures across all goals, shown on the Vault tab.
//

import Foundation

struct VaultSummary {
    let totalSaved: Double
    let totalTarget: Double
    let monthlyAllocated: Double
    let goalCount: Int
    let completedCount: Int

    init(goals: [SavingsGoal], budget: Double) {
        totalSaved = goals.reduce(0) { $0 + $1.savedAmount }
        totalTarget = goals.reduce(0) { $0 + $1.targetAmount }
        let allocations = GoalAllocator.allocate(
            budget: budget,
            items: goals.map { .init(weight: $0.priority.weight, desired: $0.desiredMonthly) }
        )
        monthlyAllocated = allocations.reduce(0, +)
        goalCount = goals.count
        completedCount = goals.filter { $0.targetAmount > 0 && $0.remaining <= 0 }.count
    }

    /// Overall completion across all goals in 0...1.
    var progress: Double {
        guard totalTarget > 0 else { return 0 }
        return min(totalSaved / totalTarget, 1)
    }
}
