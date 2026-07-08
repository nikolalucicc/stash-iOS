//
//  SpendingCategory.swift
//  stash
//
//  A spending category the user can add to and delete. Seeded with a few
//  defaults the first time the Spending tab is opened.
//

import Foundation
import SwiftData

@Model
final class SpendingCategory {
    var name: String = ""
    var icon: String = "tag.fill"
    var createdAt: Date

    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
        self.createdAt = .now
    }

    /// Inserts the default categories once, if none exist yet.
    static func seedDefaultsIfNeeded(in context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<SpendingCategory>())) ?? []
        guard existing.isEmpty else { return }
        for preset in defaults {
            context.insert(SpendingCategory(name: preset.name, icon: preset.icon))
        }
        try? context.save()
    }

    private static var defaults: [(name: String, icon: String)] {
        [
            (String(localized: "spending.category.food"), "fork.knife"),
            (String(localized: "spending.category.transport"), "car.fill"),
            (String(localized: "spending.category.fun"), "gamecontroller.fill"),
            (String(localized: "spending.category.shopping"), "bag.fill"),
            (String(localized: "spending.category.health"), "cross.fill"),
            (String(localized: "spending.category.other"), "ellipsis.circle.fill")
        ]
    }

    /// SF Symbols offered when creating a custom category.
    static let iconChoices: [String] = [
        "tag.fill", "fork.knife", "car.fill", "gamecontroller.fill", "bag.fill",
        "cross.fill", "house.fill", "gift.fill", "airplane", "cup.and.saucer.fill",
        "creditcard.fill", "pawprint.fill", "book.fill", "dumbbell.fill"
    ]
}
