//
//  AddCategoryVM.swift
//  stash
//
//  Backs the "new category" sheet.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AddCategoryVM {

    var name: String = ""
    var icon: String = SpendingCategory.iconChoices.first ?? "tag.fill"

    /// Names already taken, folded for comparison. Loaded when the sheet opens.
    private var takenNames: Set<String> = []

    var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }

    /// Spends are matched to their category by name, so two categories sharing
    /// one name would share their spends — and deleting either would take both.
    var isDuplicate: Bool {
        !trimmedName.isEmpty && takenNames.contains(SpendingCategory.folded(trimmedName))
    }

    var canSave: Bool { !trimmedName.isEmpty && !isDuplicate }

    func loadExistingNames(from context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? []
        takenNames = Set(existing.map { SpendingCategory.folded($0.name) })
    }

    func save(in context: ModelContext) async {
        guard canSave else { return }
        // The list was read when the sheet opened; check again before inserting.
        loadExistingNames(from: context)
        guard !isDuplicate else { return }
        context.insert(SpendingCategory(name: trimmedName, icon: icon))
        try? context.save()
    }

}
