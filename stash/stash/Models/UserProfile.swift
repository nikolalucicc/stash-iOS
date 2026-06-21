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
    var goalsMonthlyBudget: Double = 15_000
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \FixedExpenseEntity.profile)
    var expenses: [FixedExpenseEntity] = []

    init(
        monthlySalary: Double = 85_000,
        paydayPeriod: String = "",
        savingMethodRaw: String = SavingMethod.percentage.rawValue,
        savingPercentage: Double = 25,
        savingFixedAmount: Double = 20_000,
        currencyRaw: String = Currency.rsd.rawValue,
        onboardingCompleted: Bool = false,
        goalsMonthlyBudget: Double = 15_000
    ) {
        self.monthlySalary = monthlySalary
        self.paydayPeriod = paydayPeriod
        self.savingMethodRaw = savingMethodRaw
        self.savingPercentage = savingPercentage
        self.savingFixedAmount = savingFixedAmount
        self.currencyRaw = currencyRaw
        self.onboardingCompleted = onboardingCompleted
        self.goalsMonthlyBudget = goalsMonthlyBudget
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
