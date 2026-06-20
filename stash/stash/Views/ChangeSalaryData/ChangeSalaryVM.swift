//
//  ChangeSalaryVM.swift
//  stash
//
//  Backs the salary settings screen — loads the persisted profile, lets the
//  user edit salary / payday / saving preferences, and writes them back.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class ChangeSalaryVM {

    var salaryText: String = ""
    var selectedPeriod: String = String(localized: "onboarding.step1.payday_beginning")
    var savingMethod: SavingMethod = .percentage
    var percentageText: String = "25"
    var fixedAmountText: String = Double(20_000).serbianFormatted

    let paydayOptions: [String] = [
        String(localized: "onboarding.step1.payday_beginning"),
        String(localized: "onboarding.step1.payday_middle"),
        String(localized: "onboarding.step1.payday_end")
    ]

    // MARK: - Derived

    var monthlySalary: Double { salaryText.parsedSerbianNumber }

    /// The monthly saving implied by the current (unsaved) inputs.
    var projectedSaving: Double {
        switch savingMethod {
        case .percentage:
            let percentage = Double(percentageText) ?? 0
            return monthlySalary * percentage / 100
        case .fixed:
            return fixedAmountText.parsedSerbianNumber
        }
    }

    var projectedSavingFormatted: String { projectedSaving.serbianFormatted }

    // MARK: - Validation

    /// `true` when the entered saving would exceed the salary — invalid input.
    var savingExceedsSalary: Bool {
        monthlySalary > 0 && projectedSaving > monthlySalary
    }

    /// Whether the current form can be persisted.
    var canSave: Bool {
        monthlySalary > 0 && projectedSaving <= monthlySalary
    }

    // MARK: - Persistence

    /// Pre-fills the form from the persisted profile, if one exists.
    func load(from context: ModelContext) async {
        guard let profile = UserProfile.existing(in: context) else { return }
        salaryText = profile.monthlySalary.serbianFormatted
        if paydayOptions.contains(profile.paydayPeriod) {
            selectedPeriod = profile.paydayPeriod
        }
        savingMethod = profile.savingMethod
        if profile.savingPercentage > 0 {
            percentageText = String(format: "%.0f", profile.savingPercentage)
        }
        if profile.savingFixedAmount > 0 {
            fixedAmountText = profile.savingFixedAmount.serbianFormatted
        }
    }

    /// Writes the edited values back into the persisted profile.
    /// No-op when the form is invalid (e.g. saving greater than salary).
    func save(to context: ModelContext) async {
        guard canSave else { return }
        let profile = UserProfile.current(in: context)
        profile.monthlySalary = monthlySalary
        profile.paydayPeriod = selectedPeriod
        profile.savingMethod = savingMethod
        profile.savingPercentage = Double(percentageText) ?? profile.savingPercentage
        profile.savingFixedAmount = fixedAmountText.parsedSerbianNumber
        try? context.save()
    }
}
