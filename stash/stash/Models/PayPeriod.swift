//
//  PayPeriod.swift
//  stash
//
//  When the user's salary lands each month. Stored language-independently as a
//  raw value; the dropdown shows the localized `label`.
//

import Foundation

enum PayPeriod: String, CaseIterable {
    case beginning, middle, end

    /// Localized label shown in the payday dropdown.
    var label: String {
        switch self {
        case .beginning: return String(localized: "onboarding.step1.payday_beginning")
        case .middle:    return String(localized: "onboarding.step1.payday_middle")
        case .end:       return String(localized: "onboarding.step1.payday_end")
        }
    }

    /// Resolves a case from a localized label (defaults to `.beginning`).
    static func from(label: String) -> PayPeriod {
        allCases.first { $0.label == label } ?? .beginning
    }

    /// Day of the month the salary is expected, for the month containing `date`.
    func day(in date: Date, calendar: Calendar = .current) -> Int {
        switch self {
        case .beginning: return 1
        case .middle:    return 15
        case .end:       return calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        }
    }
}
