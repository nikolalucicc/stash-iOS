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

    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func save(in context: ModelContext) async {
        guard canSave else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        context.insert(SpendingCategory(name: trimmedName, icon: icon))
        try? context.save()
    }
}
