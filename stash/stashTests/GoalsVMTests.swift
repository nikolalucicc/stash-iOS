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

    func testDepositAddsTheAllocatedAmount() async {
        let goal = SavingsGoal(name: "Trip", targetAmount: 100_000)
        context.insert(goal)
        let vm = GoalDetailVM()
        await vm.deposit(5_000, to: goal, in: context)
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

    // MARK: - Ordering

    func testGoalsSortByPriorityHighFirst() {
        let low = SavingsGoal(name: "Low", targetAmount: 1, priority: .low)
        let high = SavingsGoal(name: "High", targetAmount: 1, priority: .high)
        let medium = SavingsGoal(name: "Medium", targetAmount: 1, priority: .medium)
        let sorted = [low, high, medium].sortedByPriority
        XCTAssertEqual(sorted.map(\.name), ["High", "Medium", "Low"])
    }

    // MARK: - GoalsBudgetVM

    func testBudgetGoesToTheHighestPriorityFirst() {
        let vm = GoalsBudgetVM()
        vm.budgetText = "20.000"
        // Neither has a deadline, so both want everything that's left — the
        // high-priority goal takes the whole budget.
        let first = SavingsGoal(name: "A", targetAmount: 100_000, priority: .high)
        let second = SavingsGoal(name: "B", targetAmount: 100_000, priority: .low)
        XCTAssertEqual(vm.allocations(for: [first, second]), [20_000, 0])
    }

    func testBudgetFlowsDownOnceHigherPrioritiesAreCovered() {
        let vm = GoalsBudgetVM()
        vm.budgetText = "20.000"
        // A only needs 5.000 to finish, so 15.000 is left for B.
        let first = SavingsGoal(name: "A", targetAmount: 100_000, savedAmount: 95_000, priority: .high)
        let second = SavingsGoal(name: "B", targetAmount: 100_000, priority: .low)
        XCTAssertEqual(vm.allocations(for: [first, second]), [5_000, 15_000])
    }

    func testBudgetSaveLoadRoundTrip() async {
        let vm = GoalsBudgetVM()
        vm.budgetText = "30.000"
        await vm.save(to: context)
        let reloaded = GoalsBudgetVM()
        await reloaded.load(from: context)
        XCTAssertEqual(reloaded.budget, 30_000)
    }
}
