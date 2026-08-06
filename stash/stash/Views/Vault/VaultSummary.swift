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

    init(goals: [SavingsGoal], available: Double) {
        totalSaved = goals.reduce(0) { $0 + $1.savedAmount }
        totalTarget = goals.reduce(0) { $0 + $1.targetAmount }
        let allocations = GoalAllocator.allocate(budget: available, goals: goals)
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
