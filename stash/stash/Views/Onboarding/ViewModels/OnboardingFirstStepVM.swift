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
    var salaryText: String = "85,000"
    var selectedPeriod: String = String(localized: "onboarding.step1.payday_beginning")
    let paydayOptions: [String] = [
        String(localized: "onboarding.step1.payday_beginning"),
        String(localized: "onboarding.step1.payday_middle"),
        String(localized: "onboarding.step1.payday_end")
    ]
}
