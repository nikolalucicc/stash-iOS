//
//  AddGoalVMTests.swift
//  stashTests
//
//  Unit tests for the "buy now from stash" path.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class AddGoalVMTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    func testBuyNowDeductsFromStash() async {
        UserProfile.current(in: context).stashBalance = 50_000
        let vm = AddGoalVM(sortOrder: 0)
        vm.name = "PS5"
        vm.amountText = "40000"

        await vm.buyNow(in: context)

        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 10_000)
        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        XCTAssertTrue(goals.isEmpty, "Buying now should not create a goal")
    }

    func testBuyNowIgnoredWhenStashTooLow() async {
        UserProfile.current(in: context).stashBalance = 30_000
        let vm = AddGoalVM(sortOrder: 0)
        vm.amountText = "40000"

        await vm.buyNow(in: context)

        XCTAssertEqual(UserProfile.existing(in: context)?.stashBalance, 30_000)
    }
}
