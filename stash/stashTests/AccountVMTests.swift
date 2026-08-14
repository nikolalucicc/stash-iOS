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

    func testReplayWalkthroughClearsFlag() {
        let profile = UserProfile.current(in: context)
        profile.walkthroughCompleted = true
        AccountVM().replayWalkthrough(in: context)
        XCTAssertEqual(UserProfile.existing(in: context)?.walkthroughCompleted, false)
    }

    func testRestartOnboardingWipesEverything() async {
        let profile = UserProfile.current(in: context)
        profile.onboardingCompleted = true
        profile.stashBalance = 5_000
        profile.expenses = [FixedExpenseEntity(name: "Rent", note: "", amount: 500, icon: "house")]
        context.insert(SavingsGoal(name: "G", targetAmount: 10_000))

        await AccountVM().restartOnboarding(in: context)

        XCTAssertNil(UserProfile.existing(in: context))
        XCTAssertEqual((try? context.fetch(FetchDescriptor<SavingsGoal>()))?.count, 0)
        XCTAssertEqual((try? context.fetch(FetchDescriptor<FixedExpenseEntity>()))?.count, 0)
    }

    func testApplyRateMultipliesAllAmounts() {
        let profile = UserProfile.current(in: context)
        profile.monthlySalary = 100_000
        profile.savingFixedAmount = 20_000
        profile.stashBalance = 50_000
        let goal = SavingsGoal(name: "G", targetAmount: 50_000, savedAmount: 10_000)
        context.insert(goal)

        AccountVM().applyRate(0.01, in: context)

        XCTAssertEqual(profile.monthlySalary, 1_000, accuracy: 0.001)
        XCTAssertEqual(profile.savingFixedAmount, 200, accuracy: 0.001)
        XCTAssertEqual(profile.stashBalance, 500, accuracy: 0.001)
        XCTAssertEqual(goal.targetAmount, 500, accuracy: 0.001)
        XCTAssertEqual(goal.savedAmount, 100, accuracy: 0.001)
    }

    func testSameCurrencyRateIsOne() async throws {
        let rate = try await ExchangeRateService.rate(from: .eur, to: .eur)
        XCTAssertEqual(rate, 1)
    }
}
