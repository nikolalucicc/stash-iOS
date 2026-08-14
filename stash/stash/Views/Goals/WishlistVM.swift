//
//  WishlistVM.swift
//  stash
//
//  Backs the Goals tab: splits what's in the stash across goals and moves it
//  over in one go, once per month.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class WishlistVM {

    /// Amount each goal would get from `available`, ordered like `goals`.
    func allocations(for goals: [SavingsGoal], available: Double) -> [Double] {
        GoalAllocator.allocate(budget: available, goals: goals)
    }

    /// Whether the stash has already been shared out this month.
    func isDistributed(_ profile: UserProfile?, reference: Date = .now) -> Bool {
        guard let profile else { return false }
        return profile.lastGoalsDistributionMonth == UserProfile.monthKey(reference)
    }

    /// Whether there is money in the stash and a goal that still needs it.
    func canDistribute(_ profile: UserProfile?, goals: [SavingsGoal]) -> Bool {
        guard let profile, profile.stashBalance > 0, !isDistributed(profile) else { return false }
        return goals.contains { $0.remaining > 0 }
    }

    /// Moves each goal's share out of the stash and into the goal, then stamps
    /// the month so it only happens once per month.
    func distribute(to goals: [SavingsGoal], in context: ModelContext, reference: Date = .now) async {
        let profile = UserProfile.current(in: context)
        guard canDistribute(profile, goals: goals) else { return }

        for (goal, share) in zip(goals, allocations(for: goals, available: profile.stashBalance))
        where share > 0 {
            let moved = profile.takeFromStash(min(share, goal.remaining))
            goal.savedAmount += moved
        }
        profile.lastGoalsDistributionMonth = UserProfile.monthKey(reference)
        try? context.save()
    }
}
