//
//  SpendingVM.swift
//  stash
//
//  Backs the "add spending" sheet: logs a spend into a category, renames the
//  category, or deletes it.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class SpendingVM {

    var amountText: String = ""
    var note: String = ""
    var renameText: String = ""
    var isRenaming: Bool = false

    var amount: Double { amountText.parsedSerbianNumber }
    var canSave: Bool { amount > 0 }

    func save(_ category: SpendingCategory, in context: ModelContext) async {
        guard canSave else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        context.insert(SpendingEntry(
            amount: amount,
            categoryName: category.name,
            categoryIcon: category.icon,
            note: trimmedNote
        ))
        try? context.save()
    }

    // MARK: - Rename

    /// Whether `renameText` is a name this category can actually take: not
    /// empty, and not one another category already holds.
    func canRename(_ category: SpendingCategory, in context: ModelContext) -> Bool {
        let wanted = SpendingCategory.folded(renameText)
        guard !wanted.isEmpty else { return false }
        guard wanted != SpendingCategory.folded(category.name) else {
            // Re-casing its own name is fine; nothing else changes.
            return renameText.trimmingCharacters(in: .whitespaces) != category.name
        }
        return !takenNames(besides: category, in: context).contains(wanted)
    }

    /// `true` when the typed name belongs to a different category.
    func renameIsDuplicate(_ category: SpendingCategory, in context: ModelContext) -> Bool {
        let wanted = SpendingCategory.folded(renameText)
        guard !wanted.isEmpty else { return false }
        return takenNames(besides: category, in: context).contains(wanted)
    }

    /// Renames the category and carries its spends across: they are matched by
    /// name, so leaving them behind would orphan every one of them.
    func rename(_ category: SpendingCategory, in context: ModelContext) async {
        guard canRename(category, in: context) else { return }
        let oldName = category.name
        let newName = renameText.trimmingCharacters(in: .whitespaces)
        let spends = (try? context.fetch(
            FetchDescriptor<SpendingEntry>(predicate: #Predicate { $0.categoryName == oldName })
        )) ?? []
        for spend in spends {
            spend.categoryName = newName
        }
        category.name = newName
        try? context.save()
    }

    private func takenNames(besides category: SpendingCategory,
                            in context: ModelContext) -> Set<String> {
        let all = (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? []
        return Set(all.filter { $0.persistentModelID != category.persistentModelID }
            .map { SpendingCategory.folded($0.name) })
    }

    // MARK: - Delete

    /// Deletes the category and every spend logged under it.
    func deleteCategory(_ category: SpendingCategory, in context: ModelContext) async {
        let name = category.name
        let spends = (try? context.fetch(
            FetchDescriptor<SpendingEntry>(predicate: #Predicate { $0.categoryName == name })
        )) ?? []
        for spend in spends {
            context.delete(spend)
        }
        context.delete(category)
        try? context.save()
    }
}
