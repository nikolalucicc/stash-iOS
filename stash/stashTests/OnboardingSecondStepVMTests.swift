//
//  OnboardingSecondStepVMTests.swift
//  stashTests
//
//  Unit tests for OnboardingSecondStepVM (saving calculation + validation).
//

import XCTest
@testable import stash

@MainActor
final class OnboardingSecondStepVMTests: XCTestCase {

    func testPercentageSavingCalculation() {
        let vm = OnboardingSecondStepVM(monthlySalary: 100_000)
        vm.savingMethod = .percentage
        vm.percentageText = "25"
        XCTAssertEqual(vm.monthlySaving, 25_000)
    }

    func testFixedSavingCalculation() {
        let vm = OnboardingSecondStepVM(monthlySalary: 100_000)
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertEqual(vm.monthlySaving, 20_000)
    }

    func testMonthlySavingFormatted() {
        let vm = OnboardingSecondStepVM(monthlySalary: 100_000)
        vm.savingMethod = .percentage
        vm.percentageText = "25"
        XCTAssertEqual(vm.monthlySavingFormatted, "25.000")
    }

    func testInvalidPercentageDefaultsToZero() {
        let vm = OnboardingSecondStepVM(monthlySalary: 100_000)
        vm.savingMethod = .percentage
        vm.percentageText = "abc"
        XCTAssertEqual(vm.monthlySaving, 0)
    }

    // MARK: - Validation

    func testSavingExceedsSalaryIsTrueWhenFixedAboveSalary() {
        let vm = OnboardingSecondStepVM(monthlySalary: 3_000)
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertTrue(vm.savingExceedsSalary)
        XCTAssertFalse(vm.canContinue)
    }

    func testValidSavingCanContinue() {
        let vm = OnboardingSecondStepVM(monthlySalary: 100_000)
        vm.savingMethod = .percentage
        vm.percentageText = "25"
        XCTAssertFalse(vm.savingExceedsSalary)
        XCTAssertTrue(vm.canContinue)
    }

    func testSavingEqualToSalaryIsAllowed() {
        let vm = OnboardingSecondStepVM(monthlySalary: 20_000)
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertFalse(vm.savingExceedsSalary)
        XCTAssertTrue(vm.canContinue)
    }

    func testZeroSalaryCannotContinue() {
        let vm = OnboardingSecondStepVM(monthlySalary: 0)
        XCTAssertFalse(vm.canContinue)
    }
}
