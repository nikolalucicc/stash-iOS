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

    /// Puts money straight into the goal, capped at what it still needs. If the
    /// stash happens to hold money, it's drawn from there first so the same
    /// savings aren't counted twice; anything beyond that is money the user is
    /// adding directly.
    private func apply(_ amount: Double, to goal: SavingsGoal, in context: ModelContext) {
        let added = min(amount, goal.remaining)
        guard added > 0 else { return }
        let profile = UserProfile.current(in: context)
        _ = profile.takeFromStash(added)
        goal.savedAmount += added
        try? context.save()
    }
}
