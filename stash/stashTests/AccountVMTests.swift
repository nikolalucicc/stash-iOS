//
//  AccountVMTests.swift
//  stashTests
//
//  Unit tests for AccountVM settings actions.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class AccountVMTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    func testRestartOnboardingClearsFlag() async {
        let profile = UserProfile.current(in: context)
        profile.onboardingCompleted = true
        await AccountVM().restartOnboarding(in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.onboardingCompleted, false)
    }

    func testSetCurrencyUpdatesProfile() async {
        _ = UserProfile.current(in: context)
        await AccountVM().setCurrency(.eur, in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.currency, .eur)
    }
}
