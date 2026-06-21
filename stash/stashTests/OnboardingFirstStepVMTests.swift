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

    func testDefaultSalaryText() {
        let vm = OnboardingFirstStepVM()
        XCTAssertEqual(vm.salaryText, "85.000")
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
