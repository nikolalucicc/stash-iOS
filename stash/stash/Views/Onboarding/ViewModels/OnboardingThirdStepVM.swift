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
            icon: icon(for: trimmedName)
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

    private func icon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("rent") || n.contains("apartment") || n.contains("lease") || n.contains("housing") { return "house.fill" }
        if n.contains("gym") || n.contains("fitness") || n.contains("sport") || n.contains("workout") { return "dumbbell.fill" }
        if n.contains("netflix") || n.contains("hbo") || n.contains("streaming") || n.contains("prime") || n.contains("disney") { return "play.rectangle.fill" }
        if n.contains("electricity") || n.contains("electric") || n.contains("power") || n.contains("utility") { return "bolt.fill" }
        if n.contains("internet") || n.contains("wifi") || n.contains("broadband") { return "wifi" }
        if n.contains("phone") || n.contains("mobile") || n.contains("cellular") { return "phone.fill" }
        if n.contains("installment") || n.contains("loan") || n.contains("credit") || n.contains("mortgage") { return "banknote" }
        if n.contains("insurance") { return "shield.fill" }
        return "tag.fill"
    }
}
