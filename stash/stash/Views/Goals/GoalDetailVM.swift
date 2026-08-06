//
//  GoalDetailVM.swift
//  stash
//
//  Savings actions for a single goal: log this month's planned contribution,
//  add a custom deposit, or delete the goal. Saved amount only grows when the
//  user confirms a real deposit.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class GoalDetailVM {

    var showDepositSheet: Bool = false
    var depositText: String = ""

    /// Adds this month's allocated amount to the goal's savings (capped at target).
    func deposit(_ amount: Double, to goal: SavingsGoal, in context: ModelContext) async {
        apply(amount, to: goal, in: context)
    }

    /// Adds a user-entered amount to the goal's savings.
    func applyCustomDeposit(to goal: SavingsGoal, in context: ModelContext) async {
        apply(depositText.parsedSerbianNumber, to: goal, in: context)
        depositText = ""
        showDepositSheet = false
    }

    func delete(_ goal: SavingsGoal, in context: ModelContext) async {
        context.delete(goal)
        try? context.save()
    }

    /// Moves money out of the stash into the goal. Capped by what the goal still
    /// needs and by what's actually in the stash, so nothing is created twice.
    private func apply(_ amount: Double, to goal: SavingsGoal, in context: ModelContext) {
        guard amount > 0 else { return }
        let profile = UserProfile.current(in: context)
        let moved = profile.takeFromStash(min(amount, goal.remaining))
        guard moved > 0 else { return }
        goal.savedAmount += moved
        try? context.save()
    }
}
