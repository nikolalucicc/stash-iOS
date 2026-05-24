//
//  OnboardingFourthStepVM.swift
//  stash
//
//  Created by Nikola on 24. 5. 2026..
//

import Foundation

enum Currency: CaseIterable {
    case rsd, eur, usd

    var name: String {
        switch self {
        case .rsd: return String(localized: "currency.rsd_name")
        case .eur: return String(localized: "currency.eur_name")
        case .usd: return String(localized: "currency.usd_name")
        }
    }

    var code: String {
        switch self {
        case .rsd: return "RSD"
        case .eur: return "EUR"
        case .usd: return "USD"
        }
    }

    var flag: String {
        switch self {
        case .rsd: return "🇷🇸"
        case .eur: return "🇪🇺"
        case .usd: return "🇺🇸"
        }
    }
}

@Observable
@MainActor
class OnboardingFourthStepVM {
    var selectedCurrency: Currency = .rsd
}
