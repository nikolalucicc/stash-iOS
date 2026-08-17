//
//  OnboardingFirstStepVMTests.swift
//  stashTests
//
//  Unit tests for OnboardingFirstStepVM.
//

import XCTest
@testable import stash

@MainActor
final class OnboardingFirstStepVMTests: XCTestCase {

    func testSalaryStartsEmpty() {
        let vm = OnboardingFirstStepVM()
        XCTAssertEqual(vm.salaryText, "")
    }

    func testCannotContinueWithoutASalary() {
        let vm = OnboardingFirstStepVM()
        XCTAssertFalse(vm.canContinue, "Everything downstream is a share of the salary")

        vm.salaryText = "0"
        XCTAssertFalse(vm.canContinue)

        vm.salaryText = "85.000"
        XCTAssertTrue(vm.canContinue)
        XCTAssertEqual(vm.salary, 85_000)
    }

    func testPaydayOptionsHasThreeChoices() {
        let vm = OnboardingFirstStepVM()
        XCTAssertEqual(vm.paydayOptions.count, 3)
    }

    func testDefaultSelectedPeriodIsFirstOption() {
        let vm = OnboardingFirstStepVM()
        XCTAssertEqual(vm.selectedPeriod, vm.paydayOptions.first)
    }

    func testPaydayOptionsAreUnique() {
        let vm = OnboardingFirstStepVM()
        XCTAssertEqual(Set(vm.paydayOptions).count, vm.paydayOptions.count)
    }
}
