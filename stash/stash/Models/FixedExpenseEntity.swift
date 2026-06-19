//
//  FixedExpenseEntity.swift
//  stash
//
//  Locally-persisted fixed/recurring expense entered during onboarding.
//

import Foundation
import SwiftData

/// A persisted recurring expense (rent, subscriptions, installments...) tied to
/// the user's `UserProfile`.
///
/// This mirrors the lightweight `FixedExpense` view-model struct used while the
/// user is editing — `FixedExpenseEntity` is the storage-layer counterpart.
@Model
final class FixedExpenseEntity {
    var name: String
    var note: String
    var amount: Double
    var icon: String
    var createdAt: Date
    var profile: UserProfile?

    init(name: String, note: String, amount: Double, icon: String) {
        self.name = name
        self.note = note
        self.amount = amount
        self.icon = icon
        self.createdAt = .now
    }
}
