//
//  OnboardingThirdStepVM.swift
//  stash
//
//  Created by Nikola on 24. 5. 2026..
//

import Foundation

struct FixedExpense: Identifiable {
    let id: UUID = UUID()
    var name: String
    var note: String
    var amount: Double
    var icon: String
}

@Observable
@MainActor
class OnboardingThirdStepVM {

    var expenses: [FixedExpense] = []
    var showAddSheet: Bool = false
    var newName: String = ""
    var newAmountText: String = ""

    var total: Double { expenses.reduce(0) { $0 + $1.amount } }
    var totalFormatted: String { total.serbianFormatted }

    var newExpenseName: String { newName.trimmingCharacters(in: .whitespaces) }
    var newExpenseAmount: Double { newAmountText.parsedSerbianNumber }

    /// An expense needs both halves; without them Add has nothing to add.
    var canAddExpense: Bool { !newExpenseName.isEmpty && newExpenseAmount > 0 }

    func addExpense() {
        let trimmedName = newExpenseName
        let amount = newExpenseAmount
        guard canAddExpense else { return }
        expenses.append(FixedExpense(
            name: trimmedName,
            note: String(localized: "onboarding.step3.default_note"),
            amount: amount,
            icon: ExpenseIcon.suggested(for: trimmedName)
        ))
        resetForm()
    }

    func cancelAdd() {
        resetForm()
    }

    func delete(_ expense: FixedExpense) {
        expenses.removeAll { $0.id == expense.id }
    }

    private func resetForm() {
        newName = ""
        newAmountText = ""
        showAddSheet = false
    }

}
