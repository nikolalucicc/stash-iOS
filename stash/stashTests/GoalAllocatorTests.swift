//
//  GoalAllocatorTests.swift
//  stashTests
//
//  Unit tests for the goal budget allocation logic.
//

import XCTest
@testable import stash

@MainActor
final class GoalAllocatorTests: XCTestCase {

    func testEmptyGoalsReturnsEmpty() {
        XCTAssertEqual(GoalAllocator.allocate(budget: 10_000, items: []), [])
    }

    func testZeroBudgetAllocatesNothing() {
        let items = [GoalAllocator.Item(weight: 3, need: 5_000)]
        XCTAssertEqual(GoalAllocator.allocate(budget: 0, items: items), [0])
    }

    func testWithinBudgetEveryoneGetsWhatTheyNeed() {
        let items = [
            GoalAllocator.Item(weight: 3, need: 5_000),
            GoalAllocator.Item(weight: 1, need: 4_000)
        ]
        XCTAssertEqual(GoalAllocator.allocate(budget: 15_000, items: items), [5_000, 4_000])
    }

    func testNobodyGetsMoreThanTheyNeed() {
        let items = [GoalAllocator.Item(weight: 3, need: 4_000)]
        XCTAssertEqual(GoalAllocator.allocate(budget: 15_000, items: items), [4_000])
    }

    func testHigherPriorityIsFundedFirst() {
        // 12.000 budget: the high-priority goal takes its full 10.000,
        // the low-priority one gets the 2.000 that's left.
        let items = [
            GoalAllocator.Item(weight: 3, need: 10_000),
            GoalAllocator.Item(weight: 1, need: 10_000)
        ]
        let result = GoalAllocator.allocate(budget: 12_000, items: items)
        XCTAssertEqual(result[0], 10_000, accuracy: 0.001)
        XCTAssertEqual(result[1], 2_000, accuracy: 0.001)
    }

    func testLowerPriorityGetsNothingWhenBudgetRunsOut() {
        let items = [
            GoalAllocator.Item(weight: 3, need: 10_000),
            GoalAllocator.Item(weight: 1, need: 5_000)
        ]
        let result = GoalAllocator.allocate(budget: 6_000, items: items)
        XCTAssertEqual(result[0], 6_000, accuracy: 0.001)
        XCTAssertEqual(result[1], 0, accuracy: 0.001)
    }

    func testTierSharesProportionallyWhenItCannotBeCovered() {
        // Same priority, needs 10.000 and 5.000, only 9.000 available → 2:1 split.
        let items = [
            GoalAllocator.Item(weight: 2, need: 10_000),
            GoalAllocator.Item(weight: 2, need: 5_000)
        ]
        let result = GoalAllocator.allocate(budget: 9_000, items: items)
        XCTAssertEqual(result[0], 6_000, accuracy: 0.001)
        XCTAssertEqual(result[1], 3_000, accuracy: 0.001)
    }

    func testOverBudgetAllocationSumsToBudget() {
        let items = [
            GoalAllocator.Item(weight: 3, need: 10_000),
            GoalAllocator.Item(weight: 2, need: 8_000),
            GoalAllocator.Item(weight: 1, need: 5_000)
        ]
        let result = GoalAllocator.allocate(budget: 15_000, items: items)
        XCTAssertEqual(result.reduce(0, +), 15_000, accuracy: 0.001)
    }

    func testLeftoverBudgetIsNotHandedOut() {
        let items = [
            GoalAllocator.Item(weight: 3, need: 3_000),
            GoalAllocator.Item(weight: 1, need: 2_000)
        ]
        let result = GoalAllocator.allocate(budget: 15_000, items: items)
        XCTAssertEqual(result.reduce(0, +), 5_000, accuracy: 0.001)
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
