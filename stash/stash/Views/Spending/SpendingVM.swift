//
//  SpendingVM.swift
//  stash
//
//  Backs the "add spending" sheet: logs a spend into a category.
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
        context.insert(SpendingEntry(amount: amount, category: category, note: trimmedNote))
        try? context.save()
    }
}
