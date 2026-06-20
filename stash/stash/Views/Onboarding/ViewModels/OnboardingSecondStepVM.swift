//
//  OnboardingSecondStepVM.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import Foundation

enum SavingMethod: String, CaseIterable {
    case percentage
    case fixed

    var label: String {
        switch self {
        case .percentage: return String(localized: "onboarding.step2.percentage_method")
        case .fixed:      return String(localized: "onboarding.step2.fixed_method")
        }
    }

    var inputLabel: String {
        switch self {
        case .percentage: return String(localized: "onboarding.step2.percentage_label")
        case .fixed:      return String(localized: "onboarding.step2.fixed_label")
        }
    }

    var inputUnit: String {
        switch self {
        case .percentage: return "%"
        case .fixed:      return String(localized: "common.rsd")
        }
    }
}

@Observable
@MainActor
class OnboardingSecondStepVM {

    var savingMethod: SavingMethod = .percentage
    var percentageText: String = "25"
    var fixedAmountText: String = Double(20_000).serbianFormatted
    var monthlySalary: Double

    init(monthlySalary: Double = 85_000) {
        self.monthlySalary = monthlySalary
    }

    var monthlySaving: Double {
        switch savingMethod {
        case .percentage:
            let pct = Double(percentageText) ?? 0
            return monthlySalary * pct / 100
        case .fixed:
            return fixedAmountText.parsedSerbianNumber
        }
    }

    var monthlySavingFormatted: String {
        monthlySaving.serbianFormatted
    }

    /// `true` when the entered saving would exceed the salary — invalid input.
    var savingExceedsSalary: Bool {
        monthlySalary > 0 && monthlySaving > monthlySalary
    }

    /// Whether the user can proceed to the next step.
    var canContinue: Bool {
        monthlySalary > 0 && monthlySaving <= monthlySalary
    }
}
