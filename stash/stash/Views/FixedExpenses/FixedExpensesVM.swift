//
//  FixedExpensesVM.swift
//  stash
//
//  Create / edit / delete the user's fixed monthly expenses.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class FixedExpensesVM {

    var nameText: String = ""
    var amountText: String = ""
    /// The expense being edited; `nil` while adding a new one.
    var editing: FixedExpenseEntity?

    var trimmedName: String { nameText.trimmingCharacters(in: .whitespaces) }
    var amount: Double { amountText.parsedSerbianNumber }
    var isEditing: Bool { editing != nil }
    var canSave: Bool { !trimmedName.isEmpty && amount > 0 }

    /// Resets the form for a new expense.
    func startAdd() {
        editing = nil
        nameText = ""
        amountText = ""
    }

    /// Pre-fills the form from an existing expense.
    func startEdit(_ expense: FixedExpenseEntity) {
        editing = expense
        nameText = expense.name
        amountText = expense.amount.serbianFormatted
    }

    /// Inserts a new expense or updates the one being edited.
    func save(to context: ModelContext) async {
        guard canSave else { return }
        if let expense = editing {
            expense.name = trimmedName
            expense.amount = amount
            expense.icon = ExpenseIcon.suggested(for: trimmedName)
        } else {
            let profile = UserProfile.current(in: context)
            let expense = FixedExpenseEntity(
                name: trimmedName,
                note: String(localized: "onboarding.step3.default_note"),
                amount: amount,
                icon: ExpenseIcon.suggested(for: trimmedName)
            )
            profile.expenses.append(expense)
        }
        try? context.save()
        startAdd()
    }

    func delete(_ expense: FixedExpenseEntity, from context: ModelContext) async {
        context.delete(expense)
        try? context.save()
    }
}
