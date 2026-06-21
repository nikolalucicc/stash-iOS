//
//  SavingsGoal.swift
//  stash
//
//  A wishlist savings goal the user contributes to each month.
//

import Foundation
import SwiftData

enum GoalPriority: String, CaseIterable {
    case low, medium, high

    /// Relative weight used when the monthly budget can't cover every goal.
    var weight: Int {
        switch self {
        case .high:   return 3
        case .medium: return 2
        case .low:    return 1
        }
    }

    var label: String {
        switch self {
        case .low:    return String(localized: "goals.priority.low")
        case .medium: return String(localized: "goals.priority.medium")
        case .high:   return String(localized: "goals.priority.high")
        }
    }
}

@Model
final class SavingsGoal {
    var name: String
    var emoji: String
    var targetAmount: Double
    var savedAmount: Double
    var priorityRaw: String
    var deadline: Date?
    var desiredMonthly: Double
    var sortOrder: Int
    var createdAt: Date

    init(
        name: String,
        emoji: String = "🎯",
        targetAmount: Double,
        savedAmount: Double = 0,
        priority: GoalPriority = .medium,
        deadline: Date? = nil,
        desiredMonthly: Double = 5_000,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.emoji = emoji
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.priorityRaw = priority.rawValue
        self.deadline = deadline
        self.desiredMonthly = desiredMonthly
        self.sortOrder = sortOrder
        self.createdAt = .now
    }
}

// MARK: - Derived

extension SavingsGoal {
    var priority: GoalPriority {
        get { GoalPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    /// Completion ratio in 0...1.
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(max(savedAmount / targetAmount, 0), 1)
    }

    var remaining: Double { max(0, targetAmount - savedAmount) }
}
