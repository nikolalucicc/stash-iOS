//
//  OverCommitmentTests.swift
//  stashTests
//
//  Saving plus fixed expenses must not quietly exceed the salary.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class OverCommitmentTests: XCTestCase {

    // ModelContainer is Sendable and set up serially before the @MainActor tests
    // run, so nonisolated access is safe (XCTest's setUp is nonisolated).
    nonisolated(unsafe) private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    private func profile(salary: Double, saving: Double, expense: Double) -> UserProfile {
        let profile = UserProfile.current(in: context)
        profile.monthlySalary = salary
        profile.savingMethod = .fixed
        profile.savingFixedAmount = saving
        profile.expenses = [FixedExpenseEntity(name: "Rent", note: "", amount: expense, icon: "house")]
        return profile
    }

    func testWithinBudgetIsNotFlagged() {
        let profile = profile(salary: 100_000, saving: 20_000, expense: 30_000)
        XCTAssertFalse(profile.isOverCommitted)
        XCTAssertEqual(profile.uncommittedMoney, 50_000)
        XCTAssertEqual(profile.freeMoney, 50_000)
    }

    func testOverBudgetIsFlaggedWithTheShortfall() {
        let profile = profile(salary: 100_000, saving: 30_000, expense: 90_000)
        XCTAssertTrue(profile.isOverCommitted)
        XCTAssertEqual(profile.uncommittedMoney, -20_000, "20.000 short")
        XCTAssertEqual(profile.freeMoney, 0, "Free money still clamps at zero")
    }

    func testExactlyOnBudgetIsNotFlagged() {
        let profile = profile(salary: 100_000, saving: 40_000, expense: 60_000)
        XCTAssertFalse(profile.isOverCommitted)
        XCTAssertEqual(profile.uncommittedMoney, 0)
    }

    func testNoSalaryIsNotFlaggedAsOverCommitted() {
        let profile = profile(salary: 0, saving: 0, expense: 0)
        XCTAssertFalse(profile.isOverCommitted, "Nothing entered yet is not an error")
    }
}
