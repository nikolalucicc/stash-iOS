//
//  VaultSummaryTests.swift
//  stashTests
//
//  Unit tests for the Vault aggregate figures.
//

import XCTest
@testable import stash

@MainActor
final class VaultSummaryTests: XCTestCase {

    private func makeGoals() -> [SavingsGoal] {
        [
            SavingsGoal(name: "A", targetAmount: 100_000, savedAmount: 50_000, priority: .high),
            SavingsGoal(name: "B", targetAmount: 20_000, savedAmount: 20_000, priority: .low)
        ]
    }

    func testTotalsAndProgress() {
        let summary = VaultSummary(goals: makeGoals(), available: 15_000)
        XCTAssertEqual(summary.totalSaved, 70_000)
        XCTAssertEqual(summary.totalTarget, 120_000)
        XCTAssertEqual(summary.progress, 70_000 / 120_000, accuracy: 0.0001)
    }

    func testCounts() {
        let summary = VaultSummary(goals: makeGoals(), available: 15_000)
        XCTAssertEqual(summary.goalCount, 2)
        XCTAssertEqual(summary.completedCount, 1) // B is fully saved
    }

    func testMonthlyAllocatedIsCappedByTheBudget() {
        // A still needs 50.000 and has no deadline, B is done — so A soaks up
        // the whole budget and nothing is left over.
        let summary = VaultSummary(goals: makeGoals(), available: 15_000)
        XCTAssertEqual(summary.monthlyAllocated, 15_000)
    }

    func testMonthlyAllocatedStopsAtWhatIsNeeded() {
        // Only 4.000 left to save, so a 15.000 budget only pays out 4.000.
        let goals = [SavingsGoal(name: "A", targetAmount: 10_000, savedAmount: 6_000, priority: .high)]
        let summary = VaultSummary(goals: goals, available: 15_000)
        XCTAssertEqual(summary.monthlyAllocated, 4_000)
    }

    func testEmptyVault() {
        let summary = VaultSummary(goals: [], available: 15_000)
        XCTAssertEqual(summary.totalSaved, 0)
        XCTAssertEqual(summary.progress, 0)
        XCTAssertEqual(summary.goalCount, 0)
    }
}
