//
//  AccountVM.swift
//  stash
//
//  Settings actions on the user's profile: currency and redoing onboarding.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AccountVM {

    func setCurrency(_ currency: Currency, in context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.currency = currency
        try? context.save()
    }

    /// Sends the user back through onboarding (data is kept).
    func restartOnboarding(in context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.onboardingCompleted = false
        try? context.save()
    }
}
