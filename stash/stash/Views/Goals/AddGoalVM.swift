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
    var monthlyText: String = ""

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
        monthlyText = goal.desiredMonthly > 0 ? goal.desiredMonthly.serbianFormatted : ""
    }

    var isEditing: Bool { editingGoal != nil }
    var targetAmount: Double { amountText.parsedSerbianNumber }
    var savedAmount: Double { min(savedText.parsedSerbianNumber, targetAmount) }
    /// Whole calendar months from this month until the deadline (at least 1).
    var monthsUntilDeadline: Int {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month], from: .now)
        let end = calendar.dateComponents([.year, .month], from: deadline)
        let months = ((end.year ?? 0) - (now.year ?? 0)) * 12 + ((end.month ?? 0) - (now.month ?? 0))
        return max(1, months)
    }

    /// Monthly amount needed to reach the target by the deadline (price / months).
    var deadlineMonthly: Double {
        guard hasDeadline, targetAmount > 0 else { return 0 }
        return (targetAmount / Double(monthsUntilDeadline)).rounded(.up)
    }

    /// With a deadline the monthly amount is derived; otherwise it's user-entered.
    var desiredMonthly: Double {
        hasDeadline ? deadlineMonthly : monthlyText.parsedSerbianNumber
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
