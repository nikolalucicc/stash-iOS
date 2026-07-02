//
//  UserProfile.swift
//  stash
//
//  Locally-persisted financial profile, captured during onboarding.
//

import Foundation
import SwiftData

/// The user's on-device financial profile: salary, saving preferences, currency
/// and the list of fixed expenses entered during onboarding.
///
/// There is exactly one `UserProfile` per device — use `UserProfile.current(in:)`
/// to fetch it (or create it on first use).
@Model
final class UserProfile {
    var monthlySalary: Double
    var paydayPeriod: String
    var savingMethodRaw: String
    var savingPercentage: Double
    var savingFixedAmount: Double
    var currencyRaw: String
    var onboardingCompleted: Bool
    /// Max total the user is willing to put toward wishlist goals each month.
    /// Starts at 0 — the user sets it from the goals budget sheet.
    var goalsMonthlyBudget: Double = 0
    /// Accumulated general savings the user has set aside (not tied to goals).
    var stashBalance: Double = 0
    /// Whether the first-run feature tour has been shown.
    var walkthroughCompleted: Bool = false
    /// "yyyy-MM" of the month the payday saving was last confirmed into the stash.
    var lastSavingConfirmedMonth: String = ""
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \FixedExpenseEntity.profile)
    var expenses: [FixedExpenseEntity] = []

    init(
        monthlySalary: Double = 0,
        paydayPeriod: String = "",
        savingMethodRaw: String = SavingMethod.percentage.rawValue,
        savingPercentage: Double = 0,
        savingFixedAmount: Double = 0,
        currencyRaw: String = Currency.rsd.rawValue,
        onboardingCompleted: Bool = false,
        goalsMonthlyBudget: Double = 0,
        stashBalance: Double = 0,
        walkthroughCompleted: Bool = false,
        lastSavingConfirmedMonth: String = ""
    ) {
        self.monthlySalary = monthlySalary
        self.paydayPeriod = paydayPeriod
        self.savingMethodRaw = savingMethodRaw
        self.savingPercentage = savingPercentage
        self.savingFixedAmount = savingFixedAmount
        self.currencyRaw = currencyRaw
        self.onboardingCompleted = onboardingCompleted
        self.goalsMonthlyBudget = goalsMonthlyBudget
        self.stashBalance = stashBalance
        self.walkthroughCompleted = walkthroughCompleted
        self.lastSavingConfirmedMonth = lastSavingConfirmedMonth
        self.createdAt = .now
    }
}

// MARK: - Typed accessors

extension UserProfile {
    /// Saving method derived from the stored raw value (defaults to `.percentage`).
    var savingMethod: SavingMethod {
        get { SavingMethod(rawValue: savingMethodRaw) ?? .percentage }
        set { savingMethodRaw = newValue.rawValue }
    }

    /// Selected currency derived from the stored raw value (defaults to `.rsd`).
    var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? .rsd }
        set { currencyRaw = newValue.rawValue }
    }

    /// The amount set aside each month, derived from the chosen saving method.
    var monthlySaving: Double {
        switch savingMethod {
        case .percentage: return monthlySalary * savingPercentage / 100
        case .fixed:      return savingFixedAmount
        }
    }

    /// Adds this month's planned saving to the stash balance.
    func addMonthlySavingToStash() {
        stashBalance += monthlySaving
    }

    /// "yyyy-MM" key used to remember which month's saving was confirmed.
    static func monthKey(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", parts.year ?? 0, parts.month ?? 0)
    }

    /// Day of the month the salary is expected, from the chosen payday period.
    func paydayDay(reference: Date, calendar: Calendar = .current) -> Int {
        switch paydayPeriod {
        case String(localized: "onboarding.step1.payday_middle"):
            return 15
        case String(localized: "onboarding.step1.payday_end"):
            return calendar.range(of: .day, in: .month, for: reference)?.count ?? 28
        default:
            return 1
        }
    }

    /// Whether the payday saving reminder should be shown: there's a saving to
    /// set aside, the salary has landed this month, and it isn't confirmed yet.
    func isPaydayDue(reference: Date = .now, calendar: Calendar = .current) -> Bool {
        guard monthlySaving > 0 else { return false }
        guard lastSavingConfirmedMonth != Self.monthKey(reference, calendar: calendar) else { return false }
        return calendar.component(.day, from: reference) >= paydayDay(reference: reference, calendar: calendar)
    }

    /// Confirms the saving was set aside: adds it to the stash and stamps the month.
    func confirmMonthlySaving(reference: Date = .now, calendar: Calendar = .current) {
        addMonthlySavingToStash()
        lastSavingConfirmedMonth = Self.monthKey(reference, calendar: calendar)
    }
}

// MARK: - Lookup

extension UserProfile {
    /// Returns the single on-device profile, creating (and inserting) one if it
    /// doesn't exist yet.
    static func current(in context: ModelContext) -> UserProfile {
        if let existing = try? context.fetch(FetchDescriptor<UserProfile>()).first {
            return existing
        }
        let profile = UserProfile()
        context.insert(profile)
        return profile
    }

    /// Returns the existing on-device profile, or `nil` if onboarding hasn't
    /// produced one yet. Use this for read-only lookups (e.g. pre-filling forms)
    /// where creating a new profile would be premature.
    static func existing(in context: ModelContext) -> UserProfile? {
        try? context.fetch(FetchDescriptor<UserProfile>()).first
    }
}
