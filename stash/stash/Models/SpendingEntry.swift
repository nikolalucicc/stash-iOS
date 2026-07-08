//
//  SpendingEntry.swift
//  stash
//
//  A single logged spend, deducted from the month's free money. The category
//  name/icon are snapshotted for display; deleting a category also deletes its
//  spends (matched by name).
//

import Foundation
import SwiftData

@Model
final class SpendingEntry {
    var amount: Double = 0
    var categoryName: String = ""
    var categoryIcon: String = "tag.fill"
    var note: String = ""
    var createdAt: Date

    init(amount: Double, categoryName: String, categoryIcon: String, note: String = "") {
        self.amount = amount
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.note = note
        self.createdAt = .now
    }
}
