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
    var priority: GoalPriority = .medium
    var hasDeadline: Bool = false
    var deadline: Date = .now

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
        priority = goal.priority
        hasDeadline = goal.deadline != nil
        deadline = goal.deadline ?? .now
    }

    var isEditing: Bool { editingGoal != nil }
    var targetAmount: Double { amountText.parsedSerbianNumber }

    /// Whole calendar months from this month until the deadline (at least 1).
    var monthsUntilDeadline: Int {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month], from: .now)
        let end = calendar.dateComponents([.year, .month], from: deadline)
        let months = ((end.year ?? 0) - (now.year ?? 0)) * 12 + ((end.month ?? 0) - (now.month ?? 0))
        return max(1, months)
    }

    /// What this goal would need each month to land on the deadline — shown as
    /// guidance while adding, since the actual monthly amount comes from the
    /// shared goals budget.
    var deadlineMonthly: Double {
        guard hasDeadline, targetAmount > 0 else { return 0 }
        return (targetAmount / Double(monthsUntilDeadline)).rounded(.up)
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    /// Spends the goal's price straight from the stash (no goal is created).
    /// Used when the user already has enough saved and buys the item now.
    func buyNow(in context: ModelContext) async {
        guard !isEditing, targetAmount > 0 else { return }
        let profile = UserProfile.current(in: context)
        guard profile.stashBalance >= targetAmount else { return }
        profile.stashBalance -= targetAmount
        try? context.save()
    }

    func save(to context: ModelContext) async {
        guard canSave else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let resolvedEmoji = emoji.isEmpty ? "🎯" : emoji

        if let goal = editingGoal {
            goal.name = trimmedName
            goal.emoji = resolvedEmoji
            goal.targetAmount = targetAmount
            // Keep whatever has been saved so far, but never above the new target.
            goal.savedAmount = min(goal.savedAmount, targetAmount)
            goal.priority = priority
            goal.deadline = hasDeadline ? deadline : nil
        } else {
            context.insert(SavingsGoal(
                name: trimmedName,
                emoji: resolvedEmoji,
                targetAmount: targetAmount,
                priority: priority,
                deadline: hasDeadline ? deadline : nil,
                sortOrder: sortOrder
            ))
        }
        try? context.save()
    }
}
