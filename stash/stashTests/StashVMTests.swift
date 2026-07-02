//
//  StashVMTests.swift
//  stashTests
//
//  Unit tests for the general savings balance.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class StashVMTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    func testAddIncrementsBalance() async {
        UserProfile.current(in: context).stashBalance = 1_000
        let vm = StashVM()
        vm.amountText = "500"
        await vm.add(in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 1_500)
    }

    func testSetBalanceReplaces() async {
        UserProfile.current(in: context).stashBalance = 1_000
        let vm = StashVM()
        vm.amountText = "300"
        await vm.setBalance(in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 300)
    }

    func testAddIgnoresZeroOrEmpty() async {
        UserProfile.current(in: context).stashBalance = 750
        let vm = StashVM()
        vm.amountText = ""
        await vm.add(in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 750)
    }

    func testPaydayAddsFixedMonthlySavingToStash() {
        let profile = UserProfile.current(in: context)
        profile.savingMethod = .fixed
        profile.savingFixedAmount = 1_150
        profile.stashBalance = 3_500

        profile.addMonthlySavingToStash()

        XCTAssertEqual(profile.stashBalance, 4_650)
    }

    func testPaydayAddsPercentageMonthlySavingToStash() {
        let profile = UserProfile.current(in: context)
        profile.savingMethod = .percentage
        profile.monthlySalary = 100_000
        profile.savingPercentage = 10
        profile.stashBalance = 0

        profile.addMonthlySavingToStash()

        XCTAssertEqual(profile.stashBalance, 10_000)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private func savingProfile(payday: String) -> UserProfile {
        let profile = UserProfile.current(in: context)
        profile.savingMethod = .fixed
        profile.savingFixedAmount = 1_000
        profile.paydayPeriod = payday
        return profile
    }

    func testPaydayDueFromBeginningOfMonth() {
        let profile = savingProfile(payday: String(localized: "onboarding.step1.payday_beginning"))
        XCTAssertTrue(profile.isPaydayDue(reference: date(2026, 7, 3)))
    }

    func testPaydayNotDueBeforeMidMonthPayday() {
        let profile = savingProfile(payday: String(localized: "onboarding.step1.payday_middle"))
        XCTAssertFalse(profile.isPaydayDue(reference: date(2026, 7, 10)))
        XCTAssertTrue(profile.isPaydayDue(reference: date(2026, 7, 15)))
    }

    func testPaydayNotDueAfterConfirmingThisMonth() {
        let profile = savingProfile(payday: String(localized: "onboarding.step1.payday_beginning"))
        let reference = date(2026, 7, 20)
        profile.confirmMonthlySaving(reference: reference)
        XCTAssertFalse(profile.isPaydayDue(reference: reference))
    }

    func testPaydayNotDueWithoutMonthlySaving() {
        let profile = savingProfile(payday: String(localized: "onboarding.step1.payday_beginning"))
        profile.savingFixedAmount = 0
        XCTAssertFalse(profile.isPaydayDue(reference: date(2026, 7, 10)))
    }

    func testConfirmMonthlySavingStampsMonthAndAdds() {
        let profile = savingProfile(payday: String(localized: "onboarding.step1.payday_beginning"))
        profile.savingFixedAmount = 1_150
        profile.stashBalance = 3_500

        profile.confirmMonthlySaving(reference: date(2026, 8, 1))

        XCTAssertEqual(profile.stashBalance, 4_650)
        XCTAssertEqual(profile.lastSavingConfirmedMonth, "2026-08")
    }
}
