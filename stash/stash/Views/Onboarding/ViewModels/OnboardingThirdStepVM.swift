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
        let lowercased = name.lowercased()
        if lowercased.contains("rent") || lowercased.contains("apartment") ||
           lowercased.contains("lease") || lowercased.contains("housing") { return "house.fill" }
        if lowercased.contains("gym") || lowercased.contains("fitness") ||
           lowercased.contains("sport") || lowercased.contains("workout") { return "dumbbell.fill" }
        if lowercased.contains("netflix") || lowercased.contains("hbo") ||
           lowercased.contains("streaming") || lowercased.contains("prime") ||
           lowercased.contains("disney") { return "play.rectangle.fill" }
        if lowercased.contains("electricity") || lowercased.contains("electric") ||
           lowercased.contains("power") || lowercased.contains("utility") { return "bolt.fill" }
        if lowercased.contains("internet") || lowercased.contains("wifi") ||
           lowercased.contains("broadband") { return "wifi" }
        if lowercased.contains("phone") || lowercased.contains("mobile") ||
           lowercased.contains("cellular") { return "phone.fill" }
        if lowercased.contains("installment") || lowercased.contains("loan") ||
           lowercased.contains("credit") || lowercased.contains("mortgage") { return "banknote" }
        if lowercased.contains("insurance") { return "shield.fill" }
        return "tag.fill"
    }
}
