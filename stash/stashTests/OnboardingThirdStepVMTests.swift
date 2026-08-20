//
//  OnboardingThirdStepVMTests.swift
//  stashTests
//
//  Unit tests for OnboardingThirdStepVM (fixed expenses).
//

import XCTest
@testable import stash

@MainActor
final class OnboardingThirdStepVMTests: XCTestCase {

    func testAddExpenseAppendsValidEntry() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.newAmountText = "45.000"
        vm.addExpense()
        XCTAssertEqual(vm.expenses.count, 1)
        XCTAssertEqual(vm.expenses.first?.name, "Rent")
        XCTAssertEqual(vm.expenses.first?.amount, 45_000)
    }

    func testAddExpenseResetsForm() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.newAmountText = "45.000"
        vm.showAddSheet = true
        vm.addExpense()
        XCTAssertEqual(vm.newName, "")
        XCTAssertEqual(vm.newAmountText, "")
        XCTAssertFalse(vm.showAddSheet)
    }

    func testAddExpenseIgnoresEmptyName() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "   "
        vm.newAmountText = "10.000"
        vm.addExpense()
        XCTAssertTrue(vm.expenses.isEmpty)
    }

    func testAddExpenseIgnoresZeroAmount() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.newAmountText = "0"
        vm.addExpense()
        XCTAssertTrue(vm.expenses.isEmpty)
    }

    func testTotalSumsAllExpenses() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.newAmountText = "45.000"
        vm.addExpense()
        vm.newName = "Internet"
        vm.newAmountText = "3.000"
        vm.addExpense()
        XCTAssertEqual(vm.total, 48_000)
        XCTAssertEqual(vm.totalFormatted, "48.000")
    }

    func testDeleteRemovesExpense() throws {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.newAmountText = "45.000"
        vm.addExpense()
        let expense = try XCTUnwrap(vm.expenses.first)
        vm.delete(expense)
        XCTAssertTrue(vm.expenses.isEmpty)
    }

    // MARK: - Icon matching

    func testIconForRent() {
        XCTAssertEqual(icon(for: "Rent", in: OnboardingThirdStepVM()), "house.fill")
    }

    func testIconForGym() {
        XCTAssertEqual(icon(for: "Gym membership", in: OnboardingThirdStepVM()), "dumbbell.fill")
    }

    func testIconForStreaming() {
        XCTAssertEqual(icon(for: "Netflix", in: OnboardingThirdStepVM()), "play.rectangle.fill")
    }

    func testIconFallback() {
        XCTAssertEqual(icon(for: "Something else", in: OnboardingThirdStepVM()), "tag.fill")
    }

    // MARK: - Add validation

    func testAddNeedsBothANameAndAnAmount() {
        let vm = OnboardingThirdStepVM()
        XCTAssertFalse(vm.canAddExpense, "Nothing entered yet")

        vm.newName = "Rent"
        XCTAssertFalse(vm.canAddExpense, "An expense without an amount is not an expense")

        vm.newName = "  "
        vm.newAmountText = "950"
        XCTAssertFalse(vm.canAddExpense, "Whitespace is not a name")

        vm.newName = "Rent"
        XCTAssertTrue(vm.canAddExpense)
    }

    func testAddDoesNothingWhileTheFormIsIncomplete() {
        let vm = OnboardingThirdStepVM()
        vm.newName = "Rent"
        vm.addExpense()
        XCTAssertTrue(vm.expenses.isEmpty, "No amount, nothing added")

        vm.newAmountText = "950"
        vm.addExpense()
        XCTAssertEqual(vm.expenses.count, 1)
    }

    /// Drives the private icon mapping through `addExpense` and returns the icon.
    private func icon(for name: String, in vm: OnboardingThirdStepVM) -> String? {
        vm.newName = name
        vm.newAmountText = "1.000"
        vm.addExpense()
        return vm.expenses.last?.icon
    }
}
