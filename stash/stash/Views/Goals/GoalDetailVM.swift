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

    /// Adds the goal's planned monthly amount to its savings (capped at target).
    func applyMonthly(to goal: SavingsGoal, in context: ModelContext) async {
        deposit(goal.desiredMonthly, to: goal, in: context)
    }

    /// Adds a user-entered amount to the goal's savings.
    func applyCustomDeposit(to goal: SavingsGoal, in context: ModelContext) async {
        deposit(depositText.parsedSerbianNumber, to: goal, in: context)
        depositText = ""
        showDepositSheet = false
    }

    func delete(_ goal: SavingsGoal, in context: ModelContext) async {
        context.delete(goal)
        try? context.save()
    }

    private func deposit(_ amount: Double, to goal: SavingsGoal, in context: ModelContext) {
        guard amount > 0 else { return }
        goal.savedAmount = min(goal.savedAmount + amount, goal.targetAmount)
        try? context.save()
    }
}
