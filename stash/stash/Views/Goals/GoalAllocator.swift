//
//  GoalAllocator.swift
//  stash
//
//  Splits the monthly goals budget across goals: higher priorities are funded
//  first, and no goal gets more than it needs, so leftover budget flows down.
//

import Foundation

enum GoalAllocator {

    struct Item {
        let weight: Int
        /// What the goal wants this month (see `SavingsGoal.monthlyNeed`).
        let need: Double
    }

    /// Monthly amount allocated to each item, in the same order as the input.
    ///
    /// Priorities are funded as tiers: the highest tier takes what it needs and
    /// the rest passes down. When a tier can't be covered in full, its share is
    /// split proportionally to each goal's need.
    static func allocate(budget: Double, items: [Item]) -> [Double] {
        var allocations = [Double](repeating: 0, count: items.count)
        guard budget > 0 else { return allocations }

        var available = budget
        let tiers = Set(items.map(\.weight)).sorted(by: >)

        for tier in tiers {
            guard available > 0 else { break }
            let indices = items.indices.filter { items[$0].weight == tier && items[$0].need > 0 }
            let tierNeed = indices.reduce(0) { $0 + items[$1].need }
            guard tierNeed > 0 else { continue }

            if tierNeed <= available {
                for index in indices { allocations[index] = items[index].need }
                available -= tierNeed
            } else {
                for index in indices {
                    allocations[index] = available * items[index].need / tierNeed
                }
                available = 0
            }
        }
        return allocations
    }

    /// Allocations for real goals, ordered the same as `goals`.
    static func allocate(budget: Double, goals: [SavingsGoal], reference: Date = .now) -> [Double] {
        allocate(
            budget: budget,
            items: goals.map { .init(weight: $0.priority.weight, need: $0.monthlyNeed(reference: reference)) }
        )
    }

    /// Whole months needed to reach `remaining` at `monthly` (nil if `monthly <= 0`).
    static func monthsToGoal(remaining: Double, monthly: Double) -> Int? {
        guard monthly > 0, remaining > 0 else { return remaining <= 0 ? 0 : nil }
        return Int((remaining / monthly).rounded(.up))
    }
}
