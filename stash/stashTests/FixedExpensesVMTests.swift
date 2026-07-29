//
//  FixedExpensesVMTests.swift
//  stashTests
//
//  Unit tests for fixed-expense CRUD.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class FixedExpensesVMTests: XCTestCase {

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

    private var allExpenses: [FixedExpenseEntity] {
        (try? context.fetch(FetchDescriptor<FixedExpenseEntity>())) ?? []
    }

    func testSaveCreatesExpenseOnProfile() async {
        let vm = FixedExpensesVM()
        vm.nameText = "  Rent "
        vm.amountText = "30.000"

        await vm.save(to: context)

        XCTAssertEqual(allExpenses.count, 1)
        XCTAssertEqual(allExpenses.first?.name, "Rent", "Name is trimmed")
        XCTAssertEqual(allExpenses.first?.amount, 30_000)
        XCTAssertEqual(allExpenses.first?.icon, "house.fill", "Icon derived from the name")
        XCTAssertEqual(UserProfile.existing(in: context)?.fixedExpensesTotal, 30_000)
    }

    func testSaveIgnoredWhenNameOrAmountMissing() async {
        let vm = FixedExpensesVM()
        vm.nameText = ""
        vm.amountText = "500"
        await vm.save(to: context)

        vm.nameText = "Gym"
        vm.amountText = ""
        await vm.save(to: context)

        XCTAssertTrue(allExpenses.isEmpty)
    }

    func testStartEditPrefillsAndSaveUpdatesInPlace() async {
        let profile = UserProfile.current(in: context)
        let expense = FixedExpenseEntity(name: "Gym", note: "", amount: 3_000, icon: "dumbbell.fill")
        profile.expenses.append(expense)

        let vm = FixedExpensesVM()
        vm.startEdit(expense)
        XCTAssertTrue(vm.isEditing)
        XCTAssertEqual(vm.nameText, "Gym")
        XCTAssertEqual(vm.amountText, "3.000")

        vm.nameText = "Netflix"
        vm.amountText = "1.200"
        await vm.save(to: context)

        XCTAssertEqual(allExpenses.count, 1, "Editing must not insert a second expense")
        XCTAssertEqual(allExpenses.first?.name, "Netflix")
        XCTAssertEqual(allExpenses.first?.amount, 1_200)
        XCTAssertEqual(allExpenses.first?.icon, "play.rectangle.fill", "Icon re-derived on edit")
    }

    func testStartAddClearsEditingState() {
        let expense = FixedExpenseEntity(name: "Gym", note: "", amount: 3_000, icon: "dumbbell.fill")
        context.insert(expense)
        let vm = FixedExpensesVM()
        vm.startEdit(expense)

        vm.startAdd()

        XCTAssertFalse(vm.isEditing)
        XCTAssertEqual(vm.nameText, "")
        XCTAssertEqual(vm.amountText, "")
    }

    func testDeleteRemovesExpense() async {
        let profile = UserProfile.current(in: context)
        let expense = FixedExpenseEntity(name: "Rent", note: "", amount: 30_000, icon: "house.fill")
        profile.expenses.append(expense)
        try? context.save()

        await FixedExpensesVM().delete(expense, from: context)

        XCTAssertTrue(allExpenses.isEmpty)
        XCTAssertEqual(UserProfile.existing(in: context)?.fixedExpensesTotal, 0)
    }

    func testSuggestedIconFallsBackForUnknownName() {
        XCTAssertEqual(ExpenseIcon.suggested(for: "Something odd"), ExpenseIcon.fallback)
    }
}
