//
//  SpendingVM.swift
//  stash
//
//  Backs the "add spending" sheet: logs a spend into a category, or deletes
//  the category.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class SpendingVM {

    var amountText: String = ""
    var note: String = ""

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
