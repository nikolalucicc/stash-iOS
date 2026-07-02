//
//  SpendingVMTests.swift
//  stashTests
//
//  Unit tests for logging spending and the free-money calculation.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class SpendingVMTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self, SpendingEntry.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    private var allEntries: [SpendingEntry] {
        (try? context.fetch(FetchDescriptor<SpendingEntry>())) ?? []
    }

    func testSaveInsertsEntry() async {
        let vm = SpendingVM()
        vm.amountText = "1.200"
        vm.note = "Lunch"

        await vm.save(.food, in: context)

        XCTAssertEqual(allEntries.count, 1)
        XCTAssertEqual(allEntries.first?.amount, 1_200)
        XCTAssertEqual(allEntries.first?.category, .food)
        XCTAssertEqual(allEntries.first?.note, "Lunch")
    }

    func testSaveIgnoredWhenAmountZero() async {
        let vm = SpendingVM()
        vm.amountText = ""
        await vm.save(.food, in: context)
        XCTAssertTrue(allEntries.isEmpty)
    }

    func testFreeMoneyIsSalaryMinusSavingAndFixed() {
        let profile = UserProfile.current(in: context)
        profile.monthlySalary = 100_000
        profile.savingMethod = .fixed
        profile.savingFixedAmount = 20_000
        profile.expenses = [FixedExpenseEntity(name: "Rent", note: "", amount: 30_000, icon: "house")]

        XCTAssertEqual(profile.freeMoney, 50_000)
    }
}
