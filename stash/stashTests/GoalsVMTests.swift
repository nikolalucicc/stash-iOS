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

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    // MARK: - AddGoalVM

    func testInitialSavedAmountCapsAtTarget() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "10.000"
        vm.savedText = "15.000"
        XCTAssertEqual(vm.savedAmount, 10_000)
    }

    func testCannotSaveWithoutNameOrAmount() {
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "10.000"
        XCTAssertFalse(vm.canSave)
        vm.name = "Bike"
        XCTAssertTrue(vm.canSave)
    }

    func testCreateInsertsGoalWithInitialSaved() async {
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "Laptop"
        vm.amountText = "100.000"
        vm.savedText = "20.000"
        await vm.save(to: context)

        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals.first?.savedAmount, 20_000)
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

    func testApplyMonthlyAddsPlannedAmount() async {
        let goal = SavingsGoal(name: "Trip", targetAmount: 100_000, desiredMonthly: 5_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        await vm.applyMonthly(to: goal, in: context)
        XCTAssertEqual(goal.savedAmount, 5_000)
    }

    func testDepositCapsAtTarget() async {
        let goal = SavingsGoal(name: "Phone", targetAmount: 10_000, savedAmount: 9_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        vm.depositText = "5.000"
        await vm.applyCustomDeposit(to: goal, in: context)
        XCTAssertEqual(goal.savedAmount, 10_000)
    }

    func testDeleteRemovesGoal() async {
        let goal = SavingsGoal(name: "Gone", targetAmount: 1_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        await vm.delete(goal, in: context)
        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertTrue(goals.isEmpty)
    }
}
