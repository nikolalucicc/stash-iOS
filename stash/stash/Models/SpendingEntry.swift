//
//  SpendingEntry.swift
//  stash
//
//  A single logged spend, deducted from the month's free money.
//

import Foundation
import SwiftData

@Model
final class SpendingEntry {
    var amount: Double
    var categoryRaw: String
    var note: String
    var createdAt: Date

    init(amount: Double, category: SpendingCategory, note: String = "") {
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.note = note
        self.createdAt = .now
    }

    /// Category derived from the stored raw value (defaults to `.other`).
    var category: SpendingCategory {
        get { SpendingCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
