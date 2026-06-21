//
//  AddGoalVM.swift
//  stash
//
//  Backs the "new goal" form and persists a SavingsGoal.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AddGoalVM {

    var name: String = ""
    var emoji: String = "🎯"
    var amountText: String = ""
    var priority: GoalPriority = .medium
    var hasDeadline: Bool = false
    var deadline: Date = .now
    var desiredMonthly: Double = 5_000

    private let sortOrder: Int

    init(sortOrder: Int) {
        self.sortOrder = sortOrder
    }

    var targetAmount: Double { amountText.parsedSerbianNumber }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    func save(to context: ModelContext) async {
        guard canSave else { return }
        let goal = SavingsGoal(
            name: name.trimmingCharacters(in: .whitespaces),
            emoji: emoji.isEmpty ? "🎯" : emoji,
            targetAmount: targetAmount,
            priority: priority,
            deadline: hasDeadline ? deadline : nil,
            desiredMonthly: desiredMonthly,
            sortOrder: sortOrder
        )
        context.insert(goal)
        try? context.save()
    }
}
