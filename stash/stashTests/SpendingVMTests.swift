//
//  SpendingVMTests.swift
//  stashTests
//
//  Unit tests for logging spending, categories, and the free-money calculation.
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
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            SpendingEntry.self, SpendingCategory.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    private var allEntries: [SpendingEntry] {
        (try? context.fetch(FetchDescriptor<SpendingEntry>())) ?? []
    }

    private var allCategories: [SpendingCategory] {
        (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? []
    }

    func testSaveSnapshotsCategoryOntoEntry() async {
        let category = SpendingCategory(name: "Food", icon: "fork.knife")
        context.insert(category)
        let vm = SpendingVM()
        vm.amountText = "1.200"
        vm.note = "Lunch"

        await vm.save(category, in: context)

        XCTAssertEqual(allEntries.count, 1)
        XCTAssertEqual(allEntries.first?.amount, 1_200)
        XCTAssertEqual(allEntries.first?.categoryName, "Food")
        XCTAssertEqual(allEntries.first?.categoryIcon, "fork.knife")
        XCTAssertEqual(allEntries.first?.note, "Lunch")
    }

    func testSaveIgnoredWhenAmountZero() async {
        let category = SpendingCategory(name: "Food", icon: "fork.knife")
        context.insert(category)
        let vm = SpendingVM()
        vm.amountText = ""
        await vm.save(category, in: context)
        XCTAssertTrue(allEntries.isEmpty)
    }

    func testDeleteCategoryAlsoDeletesItsSpends() async {
        let category = SpendingCategory(name: "Fun", icon: "gamecontroller.fill")
        context.insert(category)
        context.insert(SpendingEntry(amount: 500, categoryName: "Fun", categoryIcon: "gamecontroller.fill"))
        context.insert(SpendingEntry(amount: 800, categoryName: "Food", categoryIcon: "fork.knife"))

        await SpendingVM().deleteCategory(category, in: context)

        XCTAssertTrue(allCategories.isEmpty)
        XCTAssertEqual(allEntries.count, 1, "Only the deleted category's spends are removed")
        XCTAssertEqual(allEntries.first?.categoryName, "Food")
    }

    func testAddCategoryVMCreatesCategory() async {
        let vm = AddCategoryVM()
        vm.name = "Coffee"
        vm.icon = "cup.and.saucer.fill"

        await vm.save(in: context)

        XCTAssertEqual(allCategories.count, 1)
        XCTAssertEqual(allCategories.first?.name, "Coffee")
        XCTAssertEqual(allCategories.first?.icon, "cup.and.saucer.fill")
    }

    func testSeedDefaultsInsertsOnceThenIsIdempotent() {
        SpendingCategory.seedDefaultsIfNeeded(in: context)
        let count = allCategories.count
        XCTAssertGreaterThan(count, 0)

        SpendingCategory.seedDefaultsIfNeeded(in: context)
        XCTAssertEqual(allCategories.count, count, "Seeding again should not duplicate")
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
