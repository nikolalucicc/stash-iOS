//
//  AddGoalVMTests.swift
//  stashTests
//
//  Unit tests for the "buy now from stash" path.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class AddGoalVMTests: XCTestCase {

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

    func testBuyNowDeductsFromStash() async {
        UserProfile.current(in: context).stashBalance = 50_000
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "PS5"
        vm.amountText = "40000"

        await vm.buyNow(in: context)

        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 10_000)
        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertTrue(goals.isEmpty, "Buying now should not create a goal")
    }

    func testBuyNowIgnoredWhenStashTooLow() async {
        UserProfile.current(in: context).stashBalance = 30_000
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "40000"

        await vm.buyNow(in: context)

        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 30_000)
    }

    func testDeadlineMonthlyDividesPriceByMonths() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "13000"
        vm.hasDeadline = true
        vm.deadline = Calendar.current.date(byAdding: .month, value: 13, to: .now) ?? .now

        XCTAssertEqual(vm.monthsUntilDeadline, 13)
        XCTAssertEqual(vm.deadlineMonthly, 1_000)
    }

    func testDeadlineMonthlyRoundsUp() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "10000"
        vm.hasDeadline = true
        vm.deadline = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now

        // 10000 / 3 = 3333.3 → rounded up so the goal is fully covered
        XCTAssertEqual(vm.deadlineMonthly, 3_334)
    }

    func testCannotSaveWithoutAPace() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "Bike"
        vm.amountText = "10.000"
        XCTAssertFalse(vm.canSave, "No deadline and no monthly amount")

        vm.monthlyText = "200"
        XCTAssertTrue(vm.canSave)
    }

    func testADeadlineIsEnoughOfAPace() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "Bike"
        vm.amountText = "10.000"
        vm.hasDeadline = true
        vm.deadline = Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now
        XCTAssertTrue(vm.canSave, "The deadline works out the monthly amount")
    }

    func testCannotSaveWithoutANameOrAmount() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.monthlyText = "200"
        vm.amountText = "10.000"
        XCTAssertFalse(vm.canSave, "No name")

        vm.name = "   "
        XCTAssertFalse(vm.canSave, "Whitespace is not a name")

        vm.name = "Bike"
        vm.amountText = ""
        XCTAssertFalse(vm.canSave, "No target amount")
    }

    func testNoDeadlineMeansNoDeadlineGuidance() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "13000"
        vm.hasDeadline = false

        XCTAssertEqual(vm.deadlineMonthly, 0)
    }
}
