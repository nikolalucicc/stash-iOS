//
//  OnboardingFirstStepVM.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import Foundation

@Observable
@MainActor
class OnboardingFirstStepVM {
    var salaryText: String = ""
    var selectedPeriod: String = PayPeriod.beginning.label
    let paydayOptions: [String] = PayPeriod.allCases.map { $0.label }

    var salary: Double { salaryText.parsedSerbianNumber }

    /// Everything downstream is a share of the salary, so it has to be entered.
    var canContinue: Bool { salary > 0 }
}
