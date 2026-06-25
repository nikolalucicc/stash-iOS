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
}
