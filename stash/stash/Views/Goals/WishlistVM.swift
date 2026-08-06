//
//  WishlistVM.swift
//  stash
//
//  Backs the Goals tab: splits the monthly budget across goals and pays it out
//  in one go, once per month.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class WishlistVM {

    /// Monthly amount each goal gets from the budget, ordered like `goals`.
    func allocations(for goals: [SavingsGoal], budget: Double) -> [Double] {
        GoalAllocator.allocate(budget: budget, goals: goals)
    }

    /// Whether this month's budget has already been paid into the goals.
    func isDistributed(_ profile: UserProfile?, reference: Date = .now) -> Bool {
        guard let profile else { return false }
        return profile.lastGoalsDistributionMonth == UserProfile.monthKey(reference)
    }

    /// Whether there is anything to distribute (a budget and a goal that needs it).
    func canDistribute(_ profile: UserProfile?, goals: [SavingsGoal]) -> Bool {
        guard let profile, profile.goalsMonthlyBudget > 0, !isDistributed(profile) else { return false }
        return goals.contains { $0.remaining > 0 }
    }

    /// Pays each goal its allocated share and stamps the month so it only
    /// happens once per month.
    func distribute(to goals: [SavingsGoal], in context: ModelContext, reference: Date = .now) async {
        let profile = UserProfile.current(in: context)
        guard canDistribute(profile, goals: goals) else { return }

        for (goal, amount) in zip(goals, allocations(for: goals, budget: profile.goalsMonthlyBudget))
        where amount > 0 {
            goal.savedAmount = min(goal.savedAmount + amount, goal.targetAmount)
        }
        profile.lastGoalsDistributionMonth = UserProfile.monthKey(reference)
        try? context.save()
    }
}
