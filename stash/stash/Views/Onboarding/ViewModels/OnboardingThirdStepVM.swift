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

    func addExpense() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        let amount = newAmountText.parsedSerbianNumber
        guard !trimmedName.isEmpty, amount > 0 else { return }
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
