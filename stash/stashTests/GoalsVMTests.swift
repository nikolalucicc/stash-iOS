//
//  GoalsVMTests.swift
//  stashTests
//
//  Unit tests for AddGoalVM (initial amount, edit) and GoalDetailVM (deposits).
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class GoalsVMTests: XCTestCase {

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

    // MARK: - AddGoalVM

    func testEditingKeepsSavedAmountButNeverAboveTheNewTarget() async {
        let goal = SavingsGoal(name: "Laptop", targetAmount: 100_000, savedAmount: 40_000)
        context.insert(goal)
        let vm = AddGoalVM(editing: goal)
        vm.amountText = "30.000"

        await vm.save(to: context)

        XCTAssertEqual(goal.targetAmount, 30_000)
        XCTAssertEqual(goal.savedAmount, 30_000, "Saved is clamped to the smaller target")
    }

    func testCannotSaveWithoutNameOrAmount() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "10.000"
        XCTAssertFalse(vm.canSave)
        vm.name = "Bike"
        XCTAssertTrue(vm.canSave)
    }

    func testCreateInsertsGoalStartingFromZero() async {
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "Laptop"
        vm.amountText = "100.000"
        await vm.save(to: context)

        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals.first?.savedAmount, 0)
    }

    func testEditUpdatesExistingGoal() async {
        let goal = SavingsGoal(name: "Old", targetAmount: 50_000)
        context.insert(goal)
        let vm = AddGoalVM(editing: goal)
        vm.name = "New name"
        vm.amountText = "80.000"
        await vm.save(to: context)

        XCTAssertEqual(goal.name, "New name")
        XCTAssertEqual(goal.targetAmount, 80_000)
        XCTAssertTrue(vm.isEditing)
    }

    // MARK: - GoalDetailVM

    func testDepositMovesMoneyOutOfTheStash() async {
        let profile = UserProfile.current(in: context)
        profile.stashBalance = 20_000
        let goal = SavingsGoal(name: "Trip", targetAmount: 100_000)
        context.insert(goal)

        await GoalDetailVM().deposit(5_000, to: goal, in: context)

        XCTAssertEqual(goal.savedAmount, 5_000)
        XCTAssertEqual(profile.stashBalance, 15_000)
    }

    func testDepositWorksEvenWithAnEmptyStash() async {
        let profile = UserProfile.current(in: context)
        profile.stashBalance = 0
        let goal = SavingsGoal(name: "Trip", targetAmount: 100_000)
        context.insert(goal)

        await GoalDetailVM().deposit(5_000, to: goal, in: context)

        XCTAssertEqual(goal.savedAmount, 5_000, "Money added directly still counts")
        XCTAssertEqual(profile.stashBalance, 0)
    }

    func testDepositDrainsTheStashFirst() async {
        let profile = UserProfile.current(in: context)
        profile.stashBalance = 2_000
        let goal = SavingsGoal(name: "Trip", targetAmount: 100_000)
        context.insert(goal)

        await GoalDetailVM().deposit(5_000, to: goal, in: context)

        XCTAssertEqual(goal.savedAmount, 5_000)
        XCTAssertEqual(profile.stashBalance, 0, "The stash covers what it can")
    }

    func testDepositCapsAtTarget() async {
        UserProfile.current(in: context).stashBalance = 20_000
        let goal = SavingsGoal(name: "Phone", targetAmount: 10_000, savedAmount: 9_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        vm.depositText = "5.000"
        await vm.applyCustomDeposit(to: goal, in: context)
        XCTAssertEqual(goal.savedAmount, 10_000)
        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 19_000, "Only 1.000 was needed")
    }

    func testDeleteRemovesGoal() async {
        let goal = SavingsGoal(name: "Gone", targetAmount: 1_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        await vm.delete(goal, in: context)
        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertTrue(goals.isEmpty)
    }

    // MARK: - Ordering

    func testGoalsSortByPriorityHighFirst() {
        let low = SavingsGoal(name: "Low", targetAmount: 1, priority: .low)
        let high = SavingsGoal(name: "High", targetAmount: 1, priority: .high)
        let medium = SavingsGoal(name: "Medium", targetAmount: 1, priority: .medium)
        let sorted = [low, high, medium].sortedByPriority
        XCTAssertEqual(sorted.map(\.name), ["High", "Medium", "Low"])
    }




}
