//
//  GoalAllocatorTests.swift
//  stashTests
//
//  Unit tests for the goal budget allocation logic.
//

import XCTest
@testable import stash

final class GoalAllocatorTests: XCTestCase {

    func testEmptyGoalsReturnsEmpty() {
        XCTAssertEqual(GoalAllocator.allocate(budget: 10_000, items: []), [])
    }

    func testZeroBudgetAllocatesNothing() {
        let items = [GoalAllocator.Item(weight: 3, desired: 5_000)]
        XCTAssertEqual(GoalAllocator.allocate(budget: 0, items: items), [0])
    }

    func testWithinBudgetEveryoneGetsDesired() {
        let items = [
            GoalAllocator.Item(weight: 3, desired: 5_000),
            GoalAllocator.Item(weight: 1, desired: 4_000)
        ]
        XCTAssertEqual(GoalAllocator.allocate(budget: 15_000, items: items), [5_000, 4_000])
    }

    func testOverBudgetSplitsByPriorityWeight() {
        // desired 10000 each (sum 20000) exceeds budget 12000.
        // weighted: high 3*10000=30000, low 1*10000=10000, sum 40000.
        let items = [
            GoalAllocator.Item(weight: 3, desired: 10_000),
            GoalAllocator.Item(weight: 1, desired: 10_000)
        ]
        let result = GoalAllocator.allocate(budget: 12_000, items: items)
        XCTAssertEqual(result[0], 9_000, accuracy: 0.001)
        XCTAssertEqual(result[1], 3_000, accuracy: 0.001)
    }

    func testOverBudgetAllocationSumsToBudget() {
        let items = [
            GoalAllocator.Item(weight: 3, desired: 10_000),
            GoalAllocator.Item(weight: 2, desired: 8_000),
            GoalAllocator.Item(weight: 1, desired: 5_000)
        ]
        let result = GoalAllocator.allocate(budget: 15_000, items: items)
        XCTAssertEqual(result.reduce(0, +), 15_000, accuracy: 0.001)
    }

    // MARK: - monthsToGoal

    func testMonthsToGoalRoundsUp() {
        XCTAssertEqual(GoalAllocator.monthsToGoal(remaining: 25_000, monthly: 10_000), 3)
    }

    func testMonthsToGoalNilWhenNoContribution() {
        XCTAssertNil(GoalAllocator.monthsToGoal(remaining: 10_000, monthly: 0))
    }

    func testMonthsToGoalZeroWhenAlreadyReached() {
        XCTAssertEqual(GoalAllocator.monthsToGoal(remaining: 0, monthly: 5_000), 0)
    }
}
