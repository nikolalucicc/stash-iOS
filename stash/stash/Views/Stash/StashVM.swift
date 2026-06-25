//
//  StashVM.swift
//  stash
//
//  Manages the general savings balance ("stash") — money the user set aside
//  that isn't tied to a goal.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class StashVM {

    var amountText: String = ""

    var amount: Double { amountText.parsedSerbianNumber }

    /// Adds the entered amount to the running balance.
    func add(in context: ModelContext) async {
        guard amount > 0 else { return }
        let profile = UserProfile.current(in: context)
        profile.stashBalance += amount
        amountText = ""
        try? context.save()
    }

    /// Sets the balance to the entered amount (e.g. entering the current total).
    func setBalance(in context: ModelContext) async {
        let profile = UserProfile.current(in: context)
        profile.stashBalance = max(0, amount)
        amountText = ""
        try? context.save()
    }
}
