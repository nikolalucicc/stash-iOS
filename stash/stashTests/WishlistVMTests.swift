//
//  WishlistVMTests.swift
//  stashTests
//
//  Unit tests for the goal monthly need and the monthly budget distribution.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class WishlistVMTests: XCTestCase {

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

    private func months(_ count: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: count, to: .now) ?? .now
    }

    // MARK: - monthlyNeed

    func testDeadlineGoalNeedsRemainingSplitOverMonths() {
        let goal = SavingsGoal(name: "Trip", targetAmount: 12_000, savedAmount: 2_000,
                               deadline: months(5))
        XCTAssertEqual(goal.monthsUntilDeadline(), 5)
        XCTAssertEqual(goal.monthlyNeed(), 2_000, "10.000 left over 5 months")
    }

    func testDeadlineNeedRisesAsTheDeadlineApproaches() {
        let goal = SavingsGoal(name: "Trip", targetAmount: 12_000, deadline: months(2))
        // Same goal, same money left — fewer months means a bigger monthly need.
        XCTAssertEqual(goal.monthlyNeed(), 6_000)
    }

    func testGoalWithoutDeadlineWantsEverythingLeft() {
        let goal = SavingsGoal(name: "Car", targetAmount: 9_000, savedAmount: 1_000)
        XCTAssertNil(goal.monthsUntilDeadline())
        XCTAssertEqual(goal.monthlyNeed(), 8_000)
    }

    func testCompletedGoalNeedsNothing() {
        let goal = SavingsGoal(name: "Done", targetAmount: 5_000, savedAmount: 5_000)
        XCTAssertEqual(goal.monthlyNeed(), 0)
    }

    // MARK: - Distribution

    func testDistributePaysEachGoalItsShare() async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = 8_000
        let high = SavingsGoal(name: "A", targetAmount: 50_000, priority: .high, deadline: months(10))
        let low = SavingsGoal(name: "B", targetAmount: 50_000, priority: .low)
        context.insert(high)
        context.insert(low)

        await WishlistVM().distribute(to: [high, low], in: context)

        XCTAssertEqual(high.savedAmount, 5_000, "High priority takes its 50.000/10 first")
        XCTAssertEqual(low.savedAmount, 3_000, "The rest flows to the lower priority")
    }

    func testDistributeNeverOverfillsAGoal() async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = 10_000
        let goal = SavingsGoal(name: "A", targetAmount: 5_000, savedAmount: 4_000)
        context.insert(goal)

        await WishlistVM().distribute(to: [goal], in: context)

        XCTAssertEqual(goal.savedAmount, 5_000)
    }

    func testDistributeOnlyRunsOncePerMonth() async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = 3_000
        let goal = SavingsGoal(name: "A", targetAmount: 50_000)
        context.insert(goal)
        let vm = WishlistVM()

        await vm.distribute(to: [goal], in: context)
        await vm.distribute(to: [goal], in: context)

        XCTAssertEqual(goal.savedAmount, 3_000, "The second distribution is a no-op")
        XCTAssertTrue(vm.isDistributed(profile))
    }

    func testCannotDistributeWithoutABudget() async {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = 0
        let goal = SavingsGoal(name: "A", targetAmount: 50_000)
        context.insert(goal)

        XCTAssertFalse(WishlistVM().canDistribute(profile, goals: [goal]))
        await WishlistVM().distribute(to: [goal], in: context)
        XCTAssertEqual(goal.savedAmount, 0)
    }

    func testCannotDistributeWhenEveryGoalIsDone() {
        let profile = UserProfile.current(in: context)
        profile.goalsMonthlyBudget = 5_000
        let goal = SavingsGoal(name: "A", targetAmount: 5_000, savedAmount: 5_000)
        context.insert(goal)

        XCTAssertFalse(WishlistVM().canDistribute(profile, goals: [goal]))
    }
}
