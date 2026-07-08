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
        profile.stashBalance *= rate
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

    /// Clears the walkthrough flag so the first-run tour shows again.
    func replayWalkthrough(in context: ModelContext) {
        let profile = UserProfile.current(in: context)
        profile.walkthroughCompleted = false
        try? context.save()
    }

    /// Wipes every stored record (profile, goals, expenses, stash) so the user
    /// starts onboarding completely fresh.
    func restartOnboarding(in context: ModelContext) async {
        for goal in (try? context.fetch(FetchDescriptor<SavingsGoal>())) ?? [] {
            context.delete(goal)
        }
        for expense in (try? context.fetch(FetchDescriptor<FixedExpenseEntity>())) ?? [] {
            context.delete(expense)
        }
        for spend in (try? context.fetch(FetchDescriptor<SpendingEntry>())) ?? [] {
            context.delete(spend)
        }
        for category in (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? [] {
            context.delete(category)
        }
        for profile in (try? context.fetch(FetchDescriptor<UserProfile>())) ?? [] {
            context.delete(profile)
        }
        try? context.save()
    }
}
