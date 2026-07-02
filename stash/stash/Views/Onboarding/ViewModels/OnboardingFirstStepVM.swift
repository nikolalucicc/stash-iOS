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
}
