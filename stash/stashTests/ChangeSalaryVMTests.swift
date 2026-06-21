//
//  ChangeSalaryVMTests.swift
//  stashTests
//
//  Unit tests for ChangeSalaryVM — derived values, validation, and the
//  async load/save against an in-memory SwiftData store.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class ChangeSalaryVMTests: XCTestCase {

    /// Held for the test's lifetime — a `ModelContext` does not keep its
    /// container's store alive, so letting the container deallocate makes
    /// subsequent fetches trap.
    private var container: ModelContainer?

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self,
            configurations: config
        )
        self.container = container
        return container.mainContext
    }

    // MARK: - Derived

    func testProjectedSavingPercentage() {
        let vm = ChangeSalaryVM()
        vm.salaryText = "100.000"
        vm.savingMethod = .percentage
        vm.percentageText = "25"
        XCTAssertEqual(vm.projectedSaving, 25_000)
    }

    func testProjectedSavingFixed() {
        let vm = ChangeSalaryVM()
        vm.salaryText = "100.000"
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertEqual(vm.projectedSaving, 20_000)
    }

    // MARK: - Validation

    func testSavingExceedsSalary() {
        let vm = ChangeSalaryVM()
        vm.salaryText = "3.000"
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertTrue(vm.savingExceedsSalary)
        XCTAssertFalse(vm.canSave)
    }

    func testCanSaveWithValidInput() {
        let vm = ChangeSalaryVM()
        vm.salaryText = "100.000"
        vm.savingMethod = .percentage
        vm.percentageText = "25"
        XCTAssertTrue(vm.canSave)
    }

    func testCannotSaveWithZeroSalary() {
        let vm = ChangeSalaryVM()
        vm.salaryText = ""
        XCTAssertFalse(vm.canSave)
    }

    // MARK: - Persistence

    func testLoadPrefillsFromProfile() async throws {
        let context = try makeContext()
        let profile = UserProfile.current(in: context)
        profile.monthlySalary = 50_000
        profile.savingMethod = .percentage
        profile.savingPercentage = 30

        let vm = ChangeSalaryVM()
        await vm.load(from: context)

        XCTAssertEqual(vm.monthlySalary, 50_000)
        XCTAssertEqual(vm.percentageText, "30")
        XCTAssertEqual(vm.savingMethod, .percentage)
    }

    func testSaveWritesValidValues() async throws {
        let context = try makeContext()
        let vm = ChangeSalaryVM()
        vm.salaryText = "100.000"
        vm.savingMethod = .percentage
        vm.percentageText = "25"

        await vm.save(to: context)

        let profile = UserProfile.existing(in: context)
        XCTAssertEqual(profile?.monthlySalary, 100_000)
        XCTAssertEqual(profile?.savingPercentage, 25)
    }

    func testSaveIsNoOpWhenInvalid() async throws {
        let context = try makeContext()
        let vm = ChangeSalaryVM()
        vm.salaryText = "3.000"
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"

        await vm.save(to: context)

        XCTAssertNil(UserProfile.existing(in: context))
    }
}
