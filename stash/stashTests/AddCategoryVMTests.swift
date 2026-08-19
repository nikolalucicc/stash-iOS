//
//  AddCategoryVMTests.swift
//  stashTests
//
//  Two categories sharing a name would share their spends, so names must be
//  unique — see AddCategoryVM.isDuplicate.
//

import XCTest
import SwiftData
@testable import stash

@MainActor
final class AddCategoryVMTests: XCTestCase {

    // ModelContainer is Sendable and set up serially before the @MainActor tests
    // run, so nonisolated access is safe (XCTest's setUp is nonisolated).
    nonisolated(unsafe) private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            SpendingEntry.self, SpendingCategory.self,
            configurations: config
        )
    }

    private var context: ModelContext { container.mainContext }

    private var allCategories: [SpendingCategory] {
        (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? []
    }

    private func seed(_ name: String) {
        context.insert(SpendingCategory(name: name, icon: "tag.fill"))
        try? context.save()
    }

    private func loadedVM() -> AddCategoryVM {
        let vm = AddCategoryVM()
        vm.loadExistingNames(from: context)
        return vm
    }

    func testAFreshNameCanBeSaved() async {
        seed("Food")
        let vm = loadedVM()
        vm.name = "Travel"
        XCTAssertFalse(vm.isDuplicate)
        XCTAssertTrue(vm.canSave)

        await vm.save(in: context)
        XCTAssertEqual(allCategories.count, 2)
    }

    func testTheSameNameIsRejected() async {
        seed("Food")
        let vm = loadedVM()
        vm.name = "Food"
        XCTAssertTrue(vm.isDuplicate)
        XCTAssertFalse(vm.canSave)

        await vm.save(in: context)
        XCTAssertEqual(allCategories.count, 1, "Nothing was inserted")
    }

    func testCasingAndSpacingDoNotMakeANewName() {
        seed("Food")
        let vm = loadedVM()
        vm.name = "  food "
        XCTAssertTrue(vm.isDuplicate, "Same name, different shell")
        XCTAssertFalse(vm.canSave)
    }

    func testAnEmptyNameIsNotFlaggedAsDuplicate() {
        seed("Food")
        let vm = loadedVM()
        XCTAssertFalse(vm.isDuplicate, "Nothing typed yet is not an error")
        XCTAssertFalse(vm.canSave)
    }

    func testSaveRechecksNamesAddedAfterTheSheetOpened() async {
        let vm = loadedVM()
        vm.name = "Food"
        XCTAssertTrue(vm.canSave, "The name was free when the sheet opened")

        seed("Food")
        await vm.save(in: context)

        XCTAssertEqual(allCategories.count, 1, "The stale list must not let a duplicate through")
    }
}
