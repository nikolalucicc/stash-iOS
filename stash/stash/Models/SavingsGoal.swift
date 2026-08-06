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
    /// `nonisolated` — pure value math, used by the (nonisolated) sort comparator.
    nonisolated var weight: Int {
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
    var sortOrder: Int
    var createdAt: Date

    init(
        name: String,
        emoji: String = "🎯",
        targetAmount: Double,
        savedAmount: Double = 0,
        priority: GoalPriority = .medium,
        deadline: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.emoji = emoji
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.priorityRaw = priority.rawValue
        self.deadline = deadline
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

    /// Whole calendar months from this month until the deadline (at least 1),
    /// or `nil` when the goal has no deadline.
    func monthsUntilDeadline(reference: Date = .now, calendar: Calendar = .current) -> Int? {
        guard let deadline else { return nil }
        let now = calendar.dateComponents([.year, .month], from: reference)
        let end = calendar.dateComponents([.year, .month], from: deadline)
        let months = ((end.year ?? 0) - (now.year ?? 0)) * 12 + ((end.month ?? 0) - (now.month ?? 0))
        return max(1, months)
    }

    /// How much this goal wants each month.
    ///
    /// With a deadline it's what's left spread over the months that remain —
    /// recomputed every month, so a missed month raises the next one. Without a
    /// deadline the goal simply wants everything that's left, so it soaks up
    /// whatever budget the higher-priority goals didn't use.
    func monthlyNeed(reference: Date = .now, calendar: Calendar = .current) -> Double {
        guard remaining > 0 else { return 0 }
        guard let months = monthsUntilDeadline(reference: reference, calendar: calendar) else {
            return remaining
        }
        return (remaining / Double(months)).rounded(.up)
    }
}

// MARK: - Ordering

extension SavingsGoal {
    /// Sort comparator: highest priority first, then oldest first (stable).
    static func byPriority(_ lhs: SavingsGoal, _ rhs: SavingsGoal) -> Bool {
        if lhs.priority.weight != rhs.priority.weight {
            return lhs.priority.weight > rhs.priority.weight
        }
        return lhs.createdAt < rhs.createdAt
    }
}

extension Array where Element == SavingsGoal {
    /// Goals ordered by priority (high → low), then oldest first.
    var sortedByPriority: [SavingsGoal] {
        sorted(by: SavingsGoal.byPriority)
    }
}
