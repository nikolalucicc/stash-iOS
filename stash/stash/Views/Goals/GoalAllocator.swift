//
//  GoalAllocator.swift
//  stash
//
//  Splits a monthly budget across goals: everyone gets their desired amount
//  when it fits, otherwise the budget is shared proportionally to each goal's
//  priority weight × desired amount.
//

import Foundation

enum GoalAllocator {

    struct Item {
        let weight: Int
        let desired: Double
    }

    /// Monthly amount allocated to each item, in the same order as the input.
    static func allocate(budget: Double, items: [Item]) -> [Double] {
        guard budget > 0, !items.isEmpty else { return items.map { _ in 0 } }

        let desired = items.map { max(0, $0.desired) }
        let totalDesired = desired.reduce(0, +)

        // Everything fits — fund each goal fully.
        if totalDesired <= budget {
            return desired
        }

        // Over budget — share by priority weight × desired amount.
        let weighted = zip(items, desired).map { Double($0.weight) * $1 }
        let weightedSum = weighted.reduce(0, +)
        guard weightedSum > 0 else { return items.map { _ in 0 } }
        return weighted.map { budget * $0 / weightedSum }
    }

    /// Whole months needed to reach `remaining` at `monthly` (nil if `monthly <= 0`).
    static func monthsToGoal(remaining: Double, monthly: Double) -> Int? {
        guard monthly > 0, remaining > 0 else { return remaining <= 0 ? 0 : nil }
        return Int((remaining / monthly).rounded(.up))
    }
}
