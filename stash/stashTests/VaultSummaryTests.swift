//
//  VaultSummaryTests.swift
//  stashTests
//
//  Unit tests for the Vault aggregate figures.
//

import XCTest
@testable import stash

final class VaultSummaryTests: XCTestCase {

    private func makeGoals() -> [SavingsGoal] {
        [
            SavingsGoal(name: "A", targetAmount: 100_000, savedAmount: 50_000,
                        priority: .high, desiredMonthly: 5_000),
            SavingsGoal(name: "B", targetAmount: 20_000, savedAmount: 20_000,
                        priority: .low, desiredMonthly: 3_000)
        ]
    }

    func testTotalsAndProgress() {
        let summary = VaultSummary(goals: makeGoals(), budget: 15_000)
        XCTAssertEqual(summary.totalSaved, 70_000)
        XCTAssertEqual(summary.totalTarget, 120_000)
        XCTAssertEqual(summary.progress, 70_000 / 120_000, accuracy: 0.0001)
    }

    func testCounts() {
        let summary = VaultSummary(goals: makeGoals(), budget: 15_000)
        XCTAssertEqual(summary.goalCount, 2)
        XCTAssertEqual(summary.completedCount, 1) // B is fully saved
    }

    func testMonthlyAllocatedWithinBudget() {
        // desired 5000 + 3000 = 8000 <= budget 15000 -> each gets desired
        let summary = VaultSummary(goals: makeGoals(), budget: 15_000)
        XCTAssertEqual(summary.monthlyAllocated, 8_000)
    }

    func testEmptyVault() {
        let summary = VaultSummary(goals: [], budget: 15_000)
        XCTAssertEqual(summary.totalSaved, 0)
        XCTAssertEqual(summary.progress, 0)
        XCTAssertEqual(summary.goalCount, 0)
    }
}
