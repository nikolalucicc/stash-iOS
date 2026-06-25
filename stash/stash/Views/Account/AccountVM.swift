//
//  AccountVM.swift
//  stash
//
//  Settings actions on the user's profile: currency (with live conversion)
//  and redoing onboarding.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AccountVM {

    var isConverting: Bool = false
    var conversionFailed: Bool = false

    /// Fetches the live rate and converts every stored amount into the new
    /// currency. Leaves everything unchanged if the rate can't be fetched.
    func setCurrency(_ newCurrency: Currency, in context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        let old = profile.currency
        guard old != newCurrency else { return }

        isConverting = true
        conversionFailed = false
        defer { isConverting = false }

        do {
            let rate = try await ExchangeRateService.rate(from: old, to: newCurrency)
            applyRate(rate, in: context)
            profile.currency = newCurrency
            try? context.save()
        } catch {
            conversionFailed = true
        }
    }

    /// Multiplies every stored monetary amount by `rate`.
    func applyRate(_ rate: Double, in context: ModelContext) {
        let profile = UserProfile.current(in: context)
        profile.monthlySalary *= rate
        profile.savingFixedAmount *= rate
        profile.goalsMonthlyBudget *= rate
        for expense in profile.expenses {
            expense.amount *= rate
        }
        let goals = (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? []
        for goal in goals {
            goal.targetAmount *= rate
            goal.savedAmount *= rate
            goal.desiredMonthly *= rate
        }
    }

    /// Sends the user back through onboarding (data is kept).
    func restartOnboarding(in context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.onboardingCompleted = false
        try? context.save()
    }
}
