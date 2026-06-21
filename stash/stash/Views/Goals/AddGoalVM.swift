//
//  AddGoalVM.swift
//  stash
//
//  Backs the "new / edit goal" form and persists a SavingsGoal.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AddGoalVM {

    var name: String = ""
    var emoji: String = "🎯"
    var amountText: String = ""
    var savedText: String = ""
    var priority: GoalPriority = .medium
    var hasDeadline: Bool = false
    var deadline: Date = .now
    var desiredMonthly: Double = 5_000

    private let sortOrder: Int
    private let editingGoal: SavingsGoal?

    /// Create mode.
    init(sortOrder: Int) {
        self.sortOrder = sortOrder
        self.editingGoal = nil
    }

    /// Edit mode — prefill from an existing goal.
    init(editing goal: SavingsGoal) {
        self.sortOrder = goal.sortOrder
        self.editingGoal = goal
        name = goal.name
        emoji = goal.emoji
        amountText = goal.targetAmount.serbianFormatted
        savedText = goal.savedAmount > 0 ? goal.savedAmount.serbianFormatted : ""
        priority = goal.priority
        hasDeadline = goal.deadline != nil
        deadline = goal.deadline ?? .now
        desiredMonthly = goal.desiredMonthly
    }

    var isEditing: Bool { editingGoal != nil }
    var targetAmount: Double { amountText.parsedSerbianNumber }
    var savedAmount: Double { min(savedText.parsedSerbianNumber, targetAmount) }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    func save(to context: ModelContext) async {
        guard canSave else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let resolvedEmoji = emoji.isEmpty ? "🎯" : emoji

        if let goal = editingGoal {
            goal.name = trimmedName
            goal.emoji = resolvedEmoji
            goal.targetAmount = targetAmount
            goal.savedAmount = savedAmount
            goal.priority = priority
            goal.deadline = hasDeadline ? deadline : nil
            goal.desiredMonthly = desiredMonthly
        } else {
            context.insert(SavingsGoal(
                name: trimmedName,
                emoji: resolvedEmoji,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                priority: priority,
                deadline: hasDeadline ? deadline : nil,
                desiredMonthly: desiredMonthly,
                sortOrder: sortOrder
            ))
        }
        try? context.save()
    }
}
